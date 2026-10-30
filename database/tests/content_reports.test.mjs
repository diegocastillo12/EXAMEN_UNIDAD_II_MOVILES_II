import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {test} from 'node:test';
import {PGlite} from '@electric-sql/pglite';
import {postgis} from '@electric-sql/pglite-postgis';
const bundle=await readFile(new URL('../run_all.sql',import.meta.url),'utf8');
const owner='11111111-1111-4111-8111-111111111129',reporter='22222222-2222-4222-8222-222222222229',reviewer='33333333-3333-4333-8333-333333333329';
const pet='bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbb29',target='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa29';
const uuid=n=>`cccccccc-cccc-4ccc-8ccc-${String(n).padStart(12,'0')}`;
async function setup(t){
 const db=await PGlite.create({extensions:{postgis}});t.after(()=>db.close());
 await db.exec(`create role anon;create role authenticated;create role service_role bypassrls;create schema auth;create schema storage;
 create table storage.buckets(id text primary key,name text,public boolean,file_size_limit bigint,allowed_mime_types text[]);
 create table storage.objects(id uuid primary key,bucket_id text references storage.buckets(id),name text,metadata jsonb,unique(bucket_id,name));
 alter table storage.objects enable row level security;grant usage on schema storage to authenticated,anon;grant select,insert,update,delete on storage.objects to authenticated;grant select on storage.objects to anon;
 create table auth.users(id uuid primary key,aud text,role text,email text,raw_user_meta_data jsonb);
 create function auth.uid() returns uuid language sql stable as $$select(nullif(current_setting('request.jwt.claims',true),'')::jsonb->>'sub')::uuid$$;
 grant usage on schema auth to authenticated;`);
 await db.exec(bundle);
 await db.query('insert into auth.users(id) values($1),($2),($3)',[owner,reporter,reviewer]);
 await db.query("insert into public.pets(id,owner_id,name,species,size,age_months,traits,active_case_count,case_history_at) values($1,$2,'Luna','dog','small',12,'Blanca',1,now())",[pet,owner]);
 await db.query("insert into public.pet_photos(id,pet_id,owner_id,status,processed_at,content_hash,is_primary) values($1,$1,$2,'published',now(),repeat('a',64),true)",[pet,owner]);
 await db.query("insert into public.lost_cases(id,owner_id,pet_id,pet_version,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,pet_name,species,size,age_months,traits,photo_ids) values($1,$2,$3,1,now(),-12,-77,'PRIVATE',-12,-77,'Luna','dog','small',12,'Blanca',array[$3]::uuid[])",[target,owner,pet]);
 await db.query("insert into public.found_cases(id,owner_id,status,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,species,traits,photo_ids,published_at,report_kind) values($1,$2,'active',now(),-12,-77,'PRIVATE',-12,-77,'cat','Negra',array[$3]::uuid[],now(),'possible_loss')",[target,owner,pet]);
 await db.query("insert into public.found_case_photos(id,case_id,owner_id,status,processed_at,content_hash) values($1,$2,$3,'ready',now(),repeat('a',64))",[pet,target,owner]);
 for(const [bucket,parent] of [['pet-photo-renditions',pet],['found-photo-renditions',target]])await db.query("insert into storage.objects values(gen_random_uuid(),$1,$2,'{\"mimetype\":\"image/jpeg\",\"size\":100}')",[bucket,`${owner}/${parent}/${pet}.jpg`]);
 const actor=async user=>{await db.exec('reset role');await db.query("select set_config('request.jwt.claims',$1,false)",[JSON.stringify({sub:user,role:'authenticated'})]);await db.exec('set role authenticated');};
 const submit=(n=1,kind='lost',id=target,reason='Contenido engañoso',note='Descripción del problema')=>db.query('select public.submit_content_report($1,$2,$3,$4,$5) v',[uuid(n),kind,id,reason,note]).then(r=>r.rows[0].v);
 const read=n=>db.query('select public.read_content_report($1) v',[uuid(n)]).then(r=>r.rows[0].v);
 return {db,actor,submit,read};
}

test('HU14.1 authenticated submissions validate visibility, Unicode, idempotency and unchanged lifecycle',async t=>{
 const {db,actor,submit,read}=await setup(t);
 await db.exec('set role anon');await assert.rejects(submit(),/permission denied/);await assert.rejects(read(1),/permission denied/);
 await actor(reporter);
 for(const reason of ['', '\u00a0\u3000','🐾'.repeat(501)])await assert.rejects(submit(1,'lost',target,reason),/report_invalid/);
 await assert.rejects(submit(1,'lost',target,'Motivo','x'.repeat(1001)),/report_invalid/);
 await assert.rejects(submit(1,'unknown'),/report_invalid/);
 await assert.rejects(submit(1,'lost',uuid(999)),/report_forbidden/);
 const original=await submit();assert.equal(original.reporter_id,reporter);assert.equal(original.resource_kind,'lost');assert.ok(original.submitted_at);
 assert.deepEqual(await submit(),original);
 assert.deepEqual(await submit(1,'lost',target,' Contenido engañoso ',' Descripción del problema '),original);
 await assert.rejects(submit(1,'lost',target,'Otro motivo'),/report_conflict/);
 await assert.rejects(submit(1,'found'),/report_conflict/);
 assert.deepEqual(await read(1),original);
 const found=await submit(2,'found',target,'🐾'.repeat(500),'🐾'.repeat(1000));assert.equal(found.resource_kind,'found');
 assert.equal((await submit(3,'lost',target,'Motivo','  ')).evidence_note,null);
 await db.exec('reset role');
 assert.equal((await db.query('select status from public.lost_cases where id=$1',[target])).rows[0].status,'active');
 assert.equal((await db.query('select status from public.found_cases where id=$1',[target])).rows[0].status,'active');
 assert.equal((await db.query('select active_case_count from public.pets where id=$1',[pet])).rows[0].active_case_count,1);
 assert.equal((await db.query('select count(*)::int n from public.case_closures')).rows[0].n,0);
 await db.query('update public.lost_cases set deleted_at=now() where id=$1',[target]);
 await actor(reporter);assert.deepEqual(await submit(),original);await assert.rejects(submit(4),/report_forbidden/);
 await db.exec('reset role');await db.exec(bundle);await db.exec(bundle);await actor(reporter);assert.deepEqual(await read(1),original);
});

test('HU14.1 private evidence requires reporter or server-assigned reviewer; no client role escalation',async t=>{
 const {db,actor,submit,read}=await setup(t);await actor(reporter);const original=await submit();
 for(const sql of [
  'select * from public.content_reports',
  "update public.content_reports set reason='tampered'",'delete from public.content_reports',
  `insert into public.content_report_reviewers values('${reporter}')`,
  'select * from public.content_report_reviewers',
  `select public.authorize_report_resource('lost','${target}')`,
 ])await assert.rejects(db.query(sql),/permission denied/);
 await actor(owner);await assert.rejects(read(1),/report_forbidden/);await assert.rejects(submit(),/report_forbidden/);
 await actor(reviewer);await assert.rejects(read(1),/report_forbidden/);
 await db.exec('reset role');await db.query('insert into public.content_report_reviewers values($1)',[reviewer]);
 await actor(reviewer);assert.deepEqual(await read(1),original);
 await db.exec('reset role');await db.query('delete from public.content_report_reviewers where user_id=$1',[reviewer]);
 await actor(reviewer);await assert.rejects(read(1),/report_forbidden/);await assert.rejects(read(999),/report_forbidden/);
 await db.exec('reset role;set role service_role');await assert.rejects(db.query('select * from public.content_reports'),/permission denied/);
});

test('HU14.1 private sighting can be reported only by its authorized reader; concurrent retries persist once',async t=>{
 const {db,actor,submit}=await setup(t);
 const sighting=uuid(800);
 await db.query("insert into public.public_sightings(id,case_source,case_id,request_hash,actor_hash,observed_at,latitude,longitude,location_source,comment,is_late) values($1,'lost',$2,repeat('a',64),repeat('b',64),now(),-12,-77,'manual','private evidence',false)",[sighting,target]);
 await actor(reporter);await assert.rejects(submit(10,'sighting',sighting),/report_forbidden/);
 await actor(owner);const receipts=await Promise.all([submit(10,'sighting',sighting),submit(10,'sighting',sighting)]);
 assert.deepEqual(receipts[0],receipts[1]);
 await db.exec('reset role');assert.equal((await db.query('select count(*)::int n from public.content_reports')).rows[0].n,1);
 assert.equal((await db.query('select comment from public.public_sightings where id=$1',[sighting])).rows[0].comment,'private evidence');
 assert.equal((await db.query('select count(*)::int n from public.sighting_reviews')).rows[0].n,0);
});
