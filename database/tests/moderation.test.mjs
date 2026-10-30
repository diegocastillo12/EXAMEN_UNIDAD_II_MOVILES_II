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


test('HU14.3 role checks, private access audit and append-only CAS decisions',async t=>{
 const {db,actor,submit}=await setup(t);await actor(reporter);await submit();
 const detail=()=>db.query('select public.read_moderation_report($1) v',[uuid(1)]).then(r=>r.rows[0].v);
 const decide=(n=2,version=0,resourceVersion=0,action='hide',reason='Contenido engañoso')=>db.query('select public.decide_content_report($1,$2,$3,$4,$5,$6) v',[uuid(n),uuid(1),version,resourceVersion,action,reason]).then(r=>r.rows[0].v);
 for(const sql of ['select public.require_content_reviewer()', 'select public.list_moderation_reports()', 'select public.read_moderation_report($1)', 'select public.read_moderation_evidence($1)']) await assert.rejects(db.query(sql,sql.includes('$1')?[uuid(1)]:[]),/moderation_forbidden/);
 await assert.rejects(decide(),/moderation_forbidden/);
 await db.exec('reset role');await db.query('insert into public.content_report_reviewers values($1)',[reviewer]);await actor(reviewer);
 const queue=(await db.query('select public.list_moderation_reports() v')).rows[0].v;assert.equal(queue.items.length,1);assert.equal(queue.items[0].reason,undefined);
 const d=await detail();assert.equal(d.report.evidence_note,'Descripción del problema');assert.equal(d.report_version,0);assert.equal(d.resource_version,0);assert.equal(d.resource.title,'Luna');assert.equal(d.resource.latitude,undefined);
 assert.ok((await db.query('select public.read_moderation_evidence($1) v',[uuid(1)])).rows[0].v.path);
 for(const reason of ['', '\u00a0\u3000','🐾'.repeat(501)])await assert.rejects(decide(2,0,0,'hide',reason),/moderation_invalid/);
 const receipt=await decide();assert.equal(receipt.actor_id,reviewer);assert.equal(receipt.hidden,true);assert.equal(receipt.report_version,1);
 assert.deepEqual(await decide(),receipt);await assert.rejects(decide(2,0,0,'show'),/moderation_conflict/);await assert.rejects(decide(3),/moderation_conflict/);
 const after=await detail();assert.equal(after.hidden,true);assert.equal(after.history.length,1);
 assert.equal((await db.query('select public.list_moderation_reports() v')).rows[0].v.items.length,0);
 assert.equal((await db.query('select public.list_moderation_reports(true) v')).rows[0].v.items.length,1);
 const shown=await decide(3,1,1,'show','Revisado y permitido');assert.equal(shown.hidden,false);assert.equal((await detail()).history.length,2);
 for(const table of ['content_visibility','content_report_resolutions','content_moderation_decisions','content_moderation_access'])await assert.rejects(db.query('select * from public.'+table),/permission denied/);
 await db.exec('reset role');
 const logs=(await db.query('select action from public.content_moderation_access where actor_id=$1',[reviewer])).rows;
 for(const action of ['queue','detail','evidence','decision'])assert.ok(logs.some(r=>r.action===action));
 assert.equal((await db.query('select active_case_count from public.pets where id=$1',[pet])).rows[0].active_case_count,1);
 assert.equal((await db.query('select status from public.lost_cases where id=$1',[target])).rows[0].status,'active');
 await db.exec(bundle);await db.exec(bundle);await actor(reviewer);assert.deepEqual(await decide(3,1,1,'show','Revisado y permitido'),shown);
 await db.exec('reset role');await db.query('delete from public.content_report_reviewers where user_id=$1',[reviewer]);await actor(reviewer);await assert.rejects(detail(),/moderation_forbidden/);await assert.rejects(decide(4,2,2),/moderation_forbidden/);
});

test('HU14.3 hidden resources disappear from public projections, QR, saved/explore and photo permission without closing',async t=>{
 const {db,actor,submit}=await setup(t);
 for(const [source,slug] of [['lost','a'],['found','b']])await db.query('insert into public.case_public_links(case_source,case_id,owner_id,public_slug) values($1,$2,$3,$4)',[source,target,owner,slug.repeat(64)]);
 await actor(reporter);await submit();await submit(2,'found');await db.exec('reset role');await db.query('insert into public.content_report_reviewers values($1)',[reviewer]);
 for(const [kind,n,slug] of [['lost',1,'a'],['found',2,'b']]){
  await actor(reviewer);await db.query('select public.decide_content_report($1,$2,0,0,$3,$4)',[uuid(n+100),uuid(n),'hide','Ocultar publicación']);
  await actor(reporter);assert.equal((await db.query('select * from public.'+(kind==='lost'?'read_recovery_pet_case':'read_recovery_report')+'($1)',[target])).rows.length,0);
  const map=(await db.query("select public.explore_cases(p_latitude=>-12,p_longitude=>-77,p_radius_meters=>5000) v")).rows[0].v;assert.ok(!map.items.some(i=>i.id===target&&i.source===kind));
  const name=owner+'/'+(kind==='lost'?pet:target)+'/'+pet+'.jpg';
  assert.equal((await db.query('select public.'+(kind==='lost'?'is_public_case_rendition':'can_read_found_photo')+'($1) v',[name])).rows[0].v,false);
  await db.exec('reset role;set role service_role');assert.deepEqual((await db.query('select public.read_qr_case($1) v',[slug.repeat(64)])).rows[0].v,{state:'unavailable'});
  const report={id:uuid(n+500),observedAt:new Date(Date.now()-60000).toISOString(),point:{latitude:-12,longitude:-77,source:'manual',accuracy:null},comment:''};
  await assert.rejects(db.query('select public.submit_app_sighting($1,$2,$3,$4,$5,$6,$7)',[kind,target,reporter,report,'a'.repeat(64),'b'.repeat(64),null]),/sighting_closed/);
  await db.exec('reset role');assert.equal((await db.query('select status from public.'+(kind==='lost'?'lost_cases':'found_cases')+' where id=$1',[target])).rows[0].status,'active');
 }
 await actor(reviewer);await db.query('select public.decide_content_report($1,$2,1,1,$3,$4)',[uuid(300),uuid(1),'show','Restaurar']);
 await actor(reporter);assert.equal((await db.query('select * from public.read_recovery_pet_case($1)',[target])).rows.length,1);
});

test('HU14.3 private sightings are hidden from normal review; evidence remains available to audited moderators',async t=>{
 const {db,actor,submit}=await setup(t);const sighting=uuid(800);
 await db.query('insert into public.case_public_links(case_source,case_id,owner_id,public_slug) values($1,$2,$3,$4)',['lost',target,owner,'c'.repeat(64)]);
 await db.query("insert into public.public_sightings(id,case_source,case_id,request_hash,actor_hash,observed_at,latitude,longitude,location_source,comment,is_late,evidence_jpeg) values($1,'lost',$2,repeat('a',64),repeat('b',64),now(),-12,-77,'manual','private evidence',false,decode('ffd8ffd9','hex'))",[sighting,target]);
 await actor(owner);await submit(1,'sighting',sighting);await submit(2,'sighting',sighting);
 await db.exec('reset role');await db.query('insert into public.content_report_reviewers values($1)',[reviewer]);await actor(reviewer);
 const decide=(n,report,rv,cv)=>db.query('select public.decide_content_report($1,$2,$3,$4,$5,$6)',[uuid(n),uuid(report),rv,cv,'hide','Evidencia problemática']);
 await decide(10,1,0,0);await assert.rejects(decide(11,2,0,0),/moderation_conflict/);
 assert.equal((await db.query('select public.read_moderation_evidence($1) v',[uuid(1)])).rows[0].v.jpeg.replace(/\s/g,''),'/9j/2Q==');
 await actor(owner);await assert.rejects(db.query('select public.read_sighting_review($1)',[sighting]),/timeline_forbidden/);await assert.rejects(db.query('select public.read_sighting_evidence($1)',[sighting]),/timeline_forbidden/);
 assert.equal((await db.query('select public.read_case_timeline($1,$2) v',['lost',target])).rows[0].v.items.filter(i=>i.kind==='sighting').length,0);
 await db.exec('reset role');assert.equal((await db.query('select count(*)::int n from public.content_moderation_decisions')).rows[0].n,1);
});

test('HU14.3 queue paginates without overlap; notices inherit hidden searches and competing reports preserve one decision',async t=>{
 const {db,actor,submit}=await setup(t);const notice=uuid(900);
 await db.query("insert into public.found_cases(id,owner_id,status,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,species,traits,photo_ids,published_at,report_kind,target_lost_case_id) values($1,$2,'active',now(),-12,-77,'PRIVATE',-12,-77,'dog','Aviso vinculado',array[]::uuid[],now(),'sighting',$3)",[notice,owner,target]);
 await actor(reporter);assert.equal((await db.query('select * from public.read_recovery_report($1)',[notice])).rows.length,1);
 for(let n=1;n<=22;n++)await submit(n);
 await db.exec('reset role');await db.query('insert into public.content_report_reviewers values($1)',[reviewer]);await actor(reviewer);
 const first=(await db.query('select public.list_moderation_reports() v')).rows[0].v;
 assert.equal(first.items.length,20);assert.ok(first.next);
 const second=(await db.query('select public.list_moderation_reports(false,$1,$2) v',[first.next.time,first.next.id])).rows[0].v;
 assert.equal(second.items.length,2);assert.equal(second.next,null);assert.equal(new Set([...first.items,...second.items].map(i=>i.id)).size,22);
 const decide=(n,report,rv,cv,action)=>db.query('select public.decide_content_report($1,$2,$3,$4,$5,$6) v',[uuid(n),uuid(report),rv,cv,action,'Revisión concurrente']).then(r=>r.rows[0].v);
 const attempts=await Promise.allSettled([decide(100,1,0,0,'hide'),decide(101,2,0,0,'hide')]);assert.equal(attempts.filter(r=>r.status==='fulfilled').length,1);assert.match(String(attempts.find(r=>r.status==='rejected').reason),/moderation_conflict/);
 await actor(reporter);assert.equal((await db.query('select * from public.read_recovery_report($1)',[notice])).rows.length,0);
 await db.exec('reset role');
 await assert.rejects(db.query("insert into public.found_cases(id,owner_id,status,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,species,traits,photo_ids,published_at,report_kind,target_lost_case_id) select $1,owner_id,status,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,species,traits,photo_ids,published_at,report_kind,target_lost_case_id from public.found_cases where id=$2",[uuid(901),notice]),/case_unavailable/);
 await actor(reviewer);const winner=attempts.find(r=>r.status==='fulfilled').value;
 await db.query('select public.decide_content_report($1,$2,1,1,$3,$4)',[uuid(102),winner.report_id,'show','Restauración autorizada']);
 await actor(reporter);assert.equal((await db.query('select * from public.read_recovery_report($1)',[notice])).rows.length,1);
});
