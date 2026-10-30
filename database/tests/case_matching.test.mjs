import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { test } from 'node:test';
import { PGlite } from '@electric-sql/pglite';
import { postgis } from '@electric-sql/pglite-postgis';
const id=n=>`a0000000-0000-4000-8000-${String(n).padStart(12,'0')}`;
const owner=id(1),reporter=id(2),other=id(3),lost=id(10),found=id(11),linked=id(12),pet=id(20),photo=id(21),foundPhoto=id(22);
const base=await readFile(new URL('../run_all.sql',import.meta.url),'utf8');
const plan=JSON.parse(await readFile(new URL('../migration_plans/040_case_matching.json',import.meta.url),'utf8'));
const increment=(await Promise.all(plan.sources.map(path=>readFile(new URL('../'+path,import.meta.url),'utf8')))).join('\n');
async function setup(t){
 const db=new PGlite({extensions:{postgis}});t.after(()=>db.close());
 await db.exec(`create role authenticated;create role anon;create role service_role;create schema auth;create schema storage;
 create table storage.buckets(id text primary key,name text,public boolean,file_size_limit bigint,allowed_mime_types text[]);
 create table storage.objects(id uuid default gen_random_uuid(),bucket_id text references storage.buckets(id),name text,metadata jsonb,unique(bucket_id,name));
 alter table storage.objects enable row level security;grant usage on schema storage to authenticated,anon;
 grant select,insert,update,delete on storage.objects to authenticated;grant select on storage.objects to anon;
 create table auth.users(id uuid primary key,aud text,role text,email text,raw_user_meta_data jsonb);
 create function auth.uid() returns uuid language sql stable as $$select(nullif(current_setting('request.jwt.claims',true),'')::jsonb->>'sub')::uuid$$;
 grant usage on schema auth to authenticated;`);
 await db.exec(base);await db.exec(increment);
 await db.query('insert into auth.users(id) values($1),($2),($3)',[owner,reporter,other]);
 await db.exec('update public.profiles set onboarding_completed_at=now()');
 await db.query("insert into public.pets(id,owner_id,name,species,size,age_months,traits) values($1,$2,'Luna','dog','small',12,'white ears')",[pet,owner]);
 await db.query("insert into public.pet_photos(id,pet_id,owner_id,status,processed_at,content_hash) values($1,$2,$3,'published',now(),repeat('a',64))",[photo,pet,owner]);
 await db.query("insert into public.lost_cases(id,owner_id,pet_id,pet_version,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,pet_name,species,size,age_months,traits,photo_ids) values($1,$2,$3,1,now(),-18.12345,-70.12345,'PRIVATE ADDRESS',-18.12,-70.12,'Luna','dog','small',12,'white ears',array[$4]::uuid[])",[lost,owner,pet,photo]);
 for(const [caseId,kind,target]of[[found,'independent_found',null],[linked,'with_reporter',lost]]){
  await db.query("insert into public.found_cases(id,owner_id,status,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,species,traits,photo_ids,published_at,report_kind,target_lost_case_id) values($1,$2,'active',now(),-18.12345,-70.12345,'PRIVATE FIND',-18.12,-70.12,'dog','white ears',array[$3]::uuid[],now(),$4,$5)",[caseId,reporter,caseId===found?foundPhoto:id(23),kind,target]);
  await db.query("insert into public.found_case_photos(id,case_id,owner_id,content_hash,status,processed_at) values($1,$2,$3,repeat('b',64),'ready',now())",[caseId===found?foundPhoto:id(23),caseId,reporter]);
 }
 const actor=async(user,role='service_role')=>{await db.exec('reset role');await db.query("select set_config('request.jwt.claims',$1,false)",[JSON.stringify({sub:user,role})]);await db.exec('set role '+role);};
 const context=async(user=owner)=>{await actor(user);return(await db.query("select public.read_case_match_context($1,'lost',$2) v",[user,lost])).rows[0].v;};
 return{db,actor,context};
}
test('matching actor ownership, public snapshots, independent candidates, no linked duplicates and client grants',async t=>{
 const{db,actor,context}=await setup(t);
 const value=await context();assert.equal(value.anchor.id,lost);assert.deepEqual(value.candidates.map(c=>c.id),[found]);
 assert.doesNotMatch(JSON.stringify(value),/PRIVATE ADDRESS|PRIVATE FIND|-18\.12345|-70\.12345/);
 await assert.rejects(context(other),/matching_forbidden/);
 for(const role of['anon','authenticated']){
  await actor(owner,role);await assert.rejects(db.query("select public.read_case_match_context($1,'lost',$2)",[owner,lost]),/permission denied/);
  await assert.rejects(db.query('select * from public.case_match_embeddings'),/permission denied/);
  await assert.rejects(db.query('select * from public.case_match_reviews'),/permission denied/);
 }
 await db.exec('reset role');await db.exec(increment);await db.exec(increment);await context();
});
test('matching normalized index, stale-write rejection, removal and current visibility',async t=>{
 const{db,actor,context}=await setup(t);const c=await context(),candidate=c.candidates[0];
 const vector=[1,...Array(511).fill(0)];
 const save=(revision=candidate.revision,values=vector)=>db.query("select public.store_case_match_embedding($1,'found',$2,$3,$4,repeat('b',64),$5::real[])",[owner,found,revision,foundPhoto,values]);
 await save();await save();assert.equal((await context()).candidates[0].photos[0].embedding.length,512);
 await assert.rejects(save('0'.repeat(32)),/matching_conflict/);
 await assert.rejects(save(candidate.revision,[1,2]),/matching_invalid/);
 await assert.rejects(save(candidate.revision,Array(512).fill(1)),/matching_invalid/);
 await db.exec('reset role');await db.query("update public.found_case_photos set status='removed' where id=$1",[foundPhoto]);
 assert.equal((await db.query('select count(*) n from public.case_match_embeddings')).rows[0].n,0);
 assert.equal((await context()).candidates.length,0);await assert.rejects(save(),/matching_conflict/);
 await db.exec('reset role');await db.query("update public.found_case_photos set status='ready' where id=$1",[foundPhoto]);
 await db.query("insert into public.content_visibility(resource_kind,resource_id,hidden,version) values('found',$1,true,1)",[found]);
 assert.equal((await context()).candidates.length,0);
});
test('matching human reviews are append-only, idempotent and cannot close or assign ownership',async t=>{
 const{db,context}=await setup(t);const c=await context(),candidate=c.candidates[0];
 const review=(command,decision,revision=candidate.revision)=>db.query("select public.review_case_match($1,$2,'lost',$3,$4,'found',$5,$6,$7)",[owner,command,lost,c.anchor.revision,found,revision,decision]);
 await review(id(50),'confirmed');await review(id(50),'confirmed');await review(id(51),'dismissed');await review(id(50),'confirmed');
 assert.equal((await context()).reviews[0].decision,'dismissed');
 await assert.rejects(review(id(50),'dismissed'),/matching_conflict/);
 await assert.rejects(review(id(52),'confirmed','0'.repeat(32)),/matching_conflict/);
 await db.exec('reset role');assert.equal((await db.query('select count(*) n from public.case_match_reviews')).rows[0].n,2);
 assert.equal((await db.query('select owner_id,status from public.lost_cases where id=$1',[lost])).rows[0].status,'active');
 assert.equal((await db.query('select pet_id from public.found_cases where id=$1',[found])).rows[0].pet_id,null);
});
test('independent found publication requires its own photos and no target, retries safely and preserves linked flow',async t=>{
 const{db,actor,context}=await setup(t);const find=id(80),image=id(81),at='2026-10-24T12:00:00Z';
 await actor(reporter,'authenticated');
 await assert.rejects(db.query("select public.prepare_recovery_report($1,array[$2]::uuid[],'independent_found',$3,false)",[find,image,lost]),/found_invalid/);
 await db.query("select public.prepare_recovery_report($1,array[$2]::uuid[],'independent_found',null,false)",[find,image]);
 await db.exec('reset role');await db.query("insert into public.found_case_photos(id,case_id,owner_id,content_hash,status,processed_at) values($1,$2,$3,repeat('c',64),'ready',now())",[image,find,reporter]);
 await actor(reporter,'authenticated');
 const publish=()=>db.query("select * from public.publish_recovery_report($1,'independent_found',null,false,$2,-18.12345,-70.12345,'Private find','dog',null,'small',null,'white ears','with_me',array[$3]::uuid[])",[find,at,image]);
 const published=(await publish()).rows[0];assert.equal(published.report_kind,'independent_found');assert.equal(published.custody,'with_me');assert.equal((await publish()).rows[0].target_lost_case_id,null);
 assert.equal((await context()).candidates.length,2);
 await db.exec('reset role');await db.query('insert into public.user_blocks(owner_id,blocked_id,label,enabled) values($1,$2,\'Reportante\',true)',[owner,reporter]);
 assert.equal((await context()).candidates.length,0);
 await db.exec('reset role');await db.query('update public.lost_cases set status=\'resolved\' where id=$1',[lost]);
 await assert.rejects(context(),/matching_forbidden/);
});
test('independent finds retain owner-only posters, public sharing/QR, subscription and timeline authorization',async t=>{
 const{db,actor}=await setup(t);
 await db.query("insert into storage.objects(bucket_id,name,metadata) values('found-photo-renditions',$1,$2::jsonb)",[`${reporter}/${found}/${foundPhoto}.jpg`,JSON.stringify({size:200,mimetype:'image/jpeg'})]);
 await actor(reporter,'authenticated');
 const poster=(await db.query("select public.prepare_case_poster('found',$1) v",[found])).rows[0].v;
 assert.equal(poster.report_kind,'independent_found');assert.doesNotMatch(JSON.stringify(poster),/PRIVATE FIND|latitude|longitude|custody/);
 assert.equal((await db.query("select public.can_read_case_timeline('found',$1) v",[found])).rows[0].v,true);
 await actor(owner,'authenticated');
 await assert.rejects(db.query("select public.prepare_case_poster('found',$1)",[found]),/poster_unauthorized/);
 const share=(await db.query("select public.prepare_case_share('found',$1) v",[found])).rows[0].v;assert.equal(share.public_slug,poster.public_slug);
 assert.equal((await db.query("select public.can_read_case_timeline('found',$1) v",[found])).rows[0].v,false);
 await db.query("select public.set_alert_subscription($1,'found',$2,true,0)",[id(90),found]);
 await actor(owner,'service_role');const qr=(await db.query('select public.read_qr_case($1) v',[poster.public_slug])).rows[0].v;
 assert.equal(qr.state,'active');assert.equal(qr.kind,'found');assert.doesNotMatch(JSON.stringify(qr),/PRIVATE FIND|-18\.12345|-70\.12345/);
 await actor(reporter,'authenticated');await db.query("select public.revoke_case_public_link('found',$1)",[found]);
 await actor(owner,'service_role');assert.equal((await db.query('select public.read_qr_case($1) v',[poster.public_slug])).rows[0].v.state,'unavailable');
});
