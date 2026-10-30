import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { test } from 'node:test';
import { PGlite } from '@electric-sql/pglite';
import { postgis } from '@electric-sql/pglite-postgis';
const bundle = await readFile(new URL('../run_all.sql', import.meta.url), 'utf8');
const patch = await readFile(new URL('../patchs/039_patch_pilot_statistics.sql', import.meta.url), 'utf8');
const admin = '11111111-1111-4111-8111-111111111150', ordinary = '22222222-2222-4222-8222-222222222250', reviewer = '33333333-3333-4333-8333-333333333350';
const id = n => `dddddddd-dddd-4ddd-8ddd-${String(n).padStart(12, '0')}`;
async function setup(t) {
 const db = await PGlite.create({ extensions: { postgis } }); t.after(() => db.close());
 await db.exec(`create role anon; create role authenticated; create role service_role bypassrls; create schema auth; create schema storage;
 create table storage.buckets(id text primary key,name text,public boolean,file_size_limit bigint,allowed_mime_types text[]);
 create table storage.objects(id uuid primary key,bucket_id text references storage.buckets(id),name text,metadata jsonb,unique(bucket_id,name));
 alter table storage.objects enable row level security; grant usage on schema storage to authenticated,anon;
 grant select,insert,update,delete on storage.objects to authenticated; grant select on storage.objects to anon;
 create table auth.users(id uuid primary key,aud text,role text,email text,raw_user_meta_data jsonb);
 create function auth.uid() returns uuid language sql stable as $$select (nullif(current_setting('request.jwt.claims',true),'')::jsonb->>'sub')::uuid$$;
 grant usage on schema auth to authenticated;`);
 await db.exec(bundle);
 await db.query('insert into auth.users(id) values($1),($2),($3)', [admin, ordinary, reviewer]);
 await db.query('insert into public.platform_administrators values($1)', [admin]);
 await db.query('insert into public.content_report_reviewers values($1)', [reviewer]);
 const actor = async (user, role = 'authenticated') => {
  await db.exec('reset role'); await db.query("select set_config('request.jwt.claims',$1,false)", [JSON.stringify({ sub: user, role })]); await db.exec('set role ' + role);
 };
 const rpc = (from = '2026-10-24', to = from) => db.query('select public.read_pilot_statistics($1::date,$2::date) v', [from, to]).then(r => r.rows[0].v);
 return { db, actor, rpc };
}
test('HU16.1 independent admin permission, no table grants, revocation and repeatable patch', async t => {
 const { db, actor, rpc } = await setup(t);
 for (const [user, role] of [[null, 'anon'], [null, 'authenticated'], [ordinary, 'authenticated'], [reviewer, 'authenticated'], [admin, 'service_role']]) {
  await actor(user, role); await assert.rejects(rpc(), /permission denied|statistics_forbidden/);
 }
 await actor(admin);
 assert.equal((await db.query('select public.require_platform_administrator() v')).rows[0].v, admin);
 await assert.rejects(db.query('select * from public.platform_administrators'), /permission denied/);
 await assert.rejects(db.query('insert into public.platform_administrators values($1)', [ordinary]), /permission denied/);
 assert.deepEqual((await db.query('select * from public.lost_cases')).rows, []);
 await assert.rejects(db.query('select public.require_content_reviewer()'), /moderation_forbidden/);
 assert.deepEqual(await rpc(), { period: { from: '2026-10-24', to: '2026-10-24' }, timezone: 'America/Lima', publishedLost: 0, publishedFound: 0, sightings: 0, recovered: 0, cancelled: 0, archived: 0, reports: 0 });
 for (const dates of [[null, '2026-10-24'], ['2026-10-25', '2026-10-24'], ['2025-01-01', '2026-01-02'], ['infinity', 'infinity'], ['1999-12-31', '2000-01-01'], ['2099-12-31', '2100-01-01']]) await assert.rejects(rpc(...dates), /statistics_invalid/);
 await rpc('2024-01-01', '2024-12-31');
 await db.exec('reset role'); await db.exec(patch); await db.exec(patch); await actor(admin); await rpc();
 await db.exec('reset role'); await db.query('delete from public.platform_administrators where user_id=$1', [admin]); await actor(admin); await assert.rejects(rpc(), /statistics_forbidden/);
});
test('HU16.1 event counts in Lima, boundaries, drafts, historical withdrawals and no private projection', async t => {
 const { db, actor, rpc } = await setup(t);
 const inside = '2026-10-24T05:00:00Z', end = '2026-10-25T05:00:00Z', before = '2026-10-24T04:59:59.999Z';
 for (let n = 1; n <= 5; n++) {
  await db.query("insert into public.pets(id,owner_id,name,species,size,age_months,traits) values($1,$2,'PRIVATE NAME','dog','small',12,'PRIVATE HEALTH')", [id(n), ordinary]);
  await db.query("insert into public.lost_cases(id,owner_id,pet_id,pet_version,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,pet_name,species,size,age_months,traits,photo_ids,created_at) values($1,$2,$3,1,$4,-12.12345,-77.12345,'PRIVATE PLACE',-12,-77,'PRIVATE NAME','dog','small',12,'PRIVATE HEALTH',array[$3]::uuid[],$4)", [id(n + 10), ordinary, id(n), n === 4 ? before : n === 5 ? end : inside]);
 }
 // Three historical publications are still counted: two recovered, one cancelled.
 for (const n of [11, 12]) await db.query("insert into public.case_closures(command_id,case_source,case_id,actor_id,closed_at,reason) values($1,'lost',$2,$3,$4,'PRIVATE REASON')", [id(n + 50), id(n), ordinary, n === 11 ? inside : before]);
 await db.query("update public.lost_cases set status='resolved',deleted_at=$1 where id=any($2::uuid[])", [inside, [id(12), id(13)]]);
 await db.query("update public.lost_cases set status='resolved' where id=$1", [id(11)]);
 for (const [n, status, published] of [[30, 'active', inside], [31, 'active', end], [32, 'draft', null], [33, 'discarded', null]]) {
  await db.query("insert into public.found_cases(id,owner_id,status,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,species,traits,photo_ids,published_at,report_kind) values($1,$2,$3,$4,-12,-77,'PRIVATE PLACE',-12,-77,'cat','PRIVATE HEALTH',array[$5]::uuid[],$6,'possible_loss')", [id(n), ordinary, status, inside, id(1), published]);
 }
 await db.query("insert into public.public_sightings(id,case_source,case_id,request_hash,actor_hash,observed_at,received_at,latitude,longitude,location_source,comment,is_late) values($1,'lost',$2,repeat('a',64),repeat('b',64),$3,$4,-12.12345,-77.12345,'manual','PRIVATE COMMENT',true)", [id(40), id(14), before, inside]);
 for (const [n, time] of [[41, inside], [42, end]]) await db.query("insert into public.content_reports(id,reporter_id,resource_kind,resource_id,reason,submitted_at) values($1,$2,'lost',$3,'PRIVATE COMPLAINT',$4)", [id(n), ordinary, id(14), time]);
 await actor(admin);
 const result = await rpc();
 assert.deepEqual((await db.query('select * from public.lost_cases')).rows, [], 'Admin aggregate access does not expose other owners\' private rows');
 assert.deepEqual(result, { period: { from: '2026-10-24', to: '2026-10-24' }, timezone: 'America/Lima', publishedLost: 3, publishedFound: 1, sightings: 1, recovered: 1, cancelled: 1, archived: 1, reports: 1 });
 assert.doesNotMatch(JSON.stringify(result), /PRIVATE|latitude|longitude|owner|reporter|actor|reason|health|resource|dddddddd/);
 assert.equal((await rpc('2026-10-23')).recovered, 1);
 assert.equal((await rpc('2026-10-25')).publishedFound, 1);
 assert.equal((await rpc('2026-10-25')).publishedLost, 1);
 assert.equal((await rpc('2026-10-25')).reports, 1);
});
