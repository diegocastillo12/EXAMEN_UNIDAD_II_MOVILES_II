import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {test} from 'node:test';
import {PGlite} from '@electric-sql/pglite';
import {postgis} from '@electric-sql/pglite-postgis';
const bundle=await readFile(new URL('../run_all.sql',import.meta.url),'utf8');
const contactPatch=await readFile(new URL('../../supabase/migrations/20261023003600_block_case_contacts.sql',import.meta.url),'utf8');
const owner='11111111-1111-4111-8111-111111111142',reporter='22222222-2222-4222-8222-222222222242',other='33333333-3333-4333-8333-333333333342';
const pet='bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbb42',target='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa42';
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
 await db.query('insert into auth.users(id) values($1),($2),($3)',[owner,reporter,other]);
 await db.query("insert into public.pets(id,owner_id,name,species,size,age_months,traits,active_case_count,case_history_at) values($1,$2,'Luna','dog','small',12,'Blanca',1,now())",[pet,owner]);
 await db.query("insert into public.pet_photos(id,pet_id,owner_id,status,processed_at,content_hash,is_primary) values($1,$1,$2,'published',now(),repeat('a',64),true)",[pet,owner]);
 await db.query("insert into public.lost_cases(id,owner_id,pet_id,pet_version,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,pet_name,species,size,age_months,traits,photo_ids) values($1,$2,$3,1,now(),-12,-77,'PRIVATE',-12,-77,'Luna','dog','small',12,'Blanca',array[$3]::uuid[])",[target,owner,pet]);
 await db.query("insert into public.found_cases(id,owner_id,status,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,species,traits,photo_ids,published_at,report_kind) values($1,$2,'active',now(),-12,-77,'PRIVATE',-12,-77,'cat','Negra',array[$3]::uuid[],now(),'possible_loss')",[target,owner,pet]);
 await db.query("insert into public.found_case_photos(id,case_id,owner_id,status,processed_at,content_hash) values($1,$2,$3,'ready',now(),repeat('a',64))",[pet,target,owner]);
 for(const [bucket,parent] of [['pet-photo-renditions',pet],['found-photo-renditions',target]])await db.query("insert into storage.objects values(gen_random_uuid(),$1,$2,'{\"mimetype\":\"image/jpeg\",\"size\":100}')",[bucket,`${owner}/${parent}/${pet}.jpg`]);
 const actor=async user=>{await db.exec('reset role');await db.query("select set_config('request.jwt.claims',$1,false)",[JSON.stringify({sub:user,role:'authenticated'})]);await db.exec('set role authenticated');};
 const prepare=(kind='lost',id=target)=>db.query('select public.prepare_user_block($1,$2) v',[kind,id]).then(r=>r.rows[0].v);
 const set=(entry,enabled)=>db.query('select public.set_user_block($1,$2,$3) v',[entry.id,enabled,entry.version]).then(r=>r.rows[0].v);
 const list=before=>db.query('select public.list_user_blocks($1) v',[before??null]).then(r=>r.rows[0].v);
 return {db,actor,prepare,set,list};
}
test('HU14.2 owns only its relationship, derives the target without private profiles, CAS retry/unblock survives removed content and bundle replay',async t=>{
 const {db,actor,prepare,set,list}=await setup(t);
 await actor(owner);assert.equal(await prepare(),null);
 await actor(reporter);const entry=await prepare();assert.deepEqual(Object.keys(entry).sort(),['enabled','id','label','version']);assert.equal(entry.enabled,false);
 assert.equal((await prepare('found')).id,entry.id);assert.equal((await list()).items.length,0);
 for(const sql of ['select * from public.user_blocks','select public.users_have_block($1,$2)','select public.lock_user_pair($1,$2)'])await assert.rejects(db.query(sql,sql.includes('$1')?[owner,reporter]:[]),/permission denied/);
 const blocked=await set(entry,true);assert.equal(blocked.version,1);assert.deepEqual(await set(entry,true),blocked);
 assert.equal((await list()).items.length,1);
 await actor(other);assert.equal((await list()).items.length,0);await assert.rejects(set(blocked,false),/block_forbidden/);
 await actor(reporter);const unblocked=await set(blocked,false);assert.equal(unblocked.version,2);await assert.rejects(set(entry,true),/block_conflict/);
 const again=await set(unblocked,true);await db.exec('reset role');await db.query('update public.lost_cases set deleted_at=now() where id=$1',[target]);
 await db.exec(bundle);await db.exec(bundle);await actor(reporter);assert.equal((await list()).items[0].id,again.id);await set(again,false);assert.equal((await list()).items.length,0);
 await assert.rejects(prepare('profile'),/block_invalid/);await assert.rejects(prepare('lost',uuid(999)),/block_forbidden/);
 await db.exec('reset role;set role anon');await assert.rejects(list(),/permission denied/);await assert.rejects(prepare(),/permission denied/);
});
for(const source of ['lost','found'])test(`HU14.2 blocks contact and avatar access in both directions without changing consent: ${source}`,async t=>{
 const {db,actor,prepare,set}=await setup(t);
 const read=async()=>(await db.query('select public.read_case_contact($1,$2) v',[source,target])).rows[0].v;
 const avatars=async()=>(await db.query("select name from storage.objects where bucket_id='profile-avatars' and name=$1",[owner+'/avatar.jpg'])).rows;
 await db.query("insert into storage.objects values(gen_random_uuid(),'profile-avatars',$1,null)",[owner+'/avatar.jpg']);
 await actor(owner);await db.query('select public.set_case_contact($1,$2,true,$3,$4,true,0)',[source,target,'Lucía Torres','+51900000000']);
 await actor(reporter);assert.equal((await read()).contact.phone,'+51900000000');assert.equal((await avatars()).length,1);
 const first=await set(await prepare(source),true);assert.equal((await read()).contact,null);assert.equal((await avatars()).length,0);
 assert.equal((await read()).suggested_phone,null);assert.equal((await read()).can_edit,false);
 // A separate permissive policy cannot widen the existing restrictive avatar guard.
 await db.exec('reset role');await db.exec('create policy test_broad_block_contact on storage.objects for select to authenticated using(true)');
 await actor(reporter);assert.equal((await avatars()).length,0);
 await actor(other);assert.equal((await read()).contact.phone,'+51900000000');assert.equal((await avatars()).length,1);
 await actor(owner);assert.equal((await read()).contact.phone,'+51900000000');assert.equal((await read()).can_edit,true);assert.equal((await avatars()).length,1);
 await actor(reporter);await set(first,false);assert.equal((await read()).contact.phone,'+51900000000');assert.equal((await avatars()).length,1);
 // An inverse owner choice also suppresses the reader's access to every shared field.
 await db.exec('reset role');await db.query("insert into public.user_blocks(owner_id,blocked_id,label,enabled,version) values($1,$2,'Reportante',true,1)",[owner,reporter]);
 await db.exec(contactPatch);await db.exec(contactPatch);await db.exec(bundle);
 await actor(reporter);assert.equal((await read()).contact,null);assert.equal((await avatars()).length,0);
 await db.exec('reset role');const consent=(await db.query('select enabled,share_photo,version,phone from public.case_contacts where case_source=$1 and case_id=$2',[source,target])).rows[0];assert.deepEqual(consent,{enabled:true,share_photo:true,version:1,phone:'+51900000000'});
 await db.query('update public.user_blocks set enabled=false where owner_id=$1 and blocked_id=$2',[owner,reporter]);
 await actor(reporter);assert.equal((await read()).contact.phone,'+51900000000');
 await actor(owner);await db.query('select public.set_case_contact($1,$2,false,$3,$4,false,1)',[source,target,'','']);
 await actor(reporter);const next=await set(await prepare(source),true);await set(next,false);assert.equal((await read()).contact,null);
});
test('HU14.2 paginates only active choices and leaves the other account own block intact',async t=>{
 const {db,actor,prepare,set,list}=await setup(t);
 await actor(reporter);const a=await set(await prepare(),true);
 await db.exec('reset role');await db.query('insert into public.user_blocks(owner_id,blocked_id,label,enabled,version) values($1,$2,$3,true,1)',[owner,reporter,'Reportante',]);
 for(let n=1;n<=22;n++){await db.query('insert into auth.users(id) values($1)',[uuid(n)]);await db.query("insert into public.user_blocks(owner_id,blocked_id,label,enabled) values($1,$2,'Reportante',true)",[reporter,uuid(n)]);}
 await actor(reporter);const first=await list(),second=await list(first.next);assert.equal(first.items.length,20);assert.equal(second.items.length,3);assert.equal(second.next,null);assert.equal(new Set([...first.items,...second.items].map(e=>e.id)).size,23);
 await set(a,false);await db.exec('reset role');assert.equal((await db.query('select enabled from public.user_blocks where owner_id=$1 and blocked_id=$2',[owner,reporter])).rows[0].enabled,true);
});
test('HU14.2 enforces both directions for new notices and authenticated sightings, preserves receipts, history, public QR and reporting',async t=>{
 const {db,actor,prepare,set}=await setup(t);
 const report=(n)=>({id:uuid(n),observedAt:new Date(Date.now()-60000).toISOString(),point:{latitude:-12,longitude:-77,source:'manual',accuracy:null},comment:''});
 const first=report(50);
 const sighting=(source,who,data)=>db.query('select public.submit_app_sighting($1,$2,$3,$4,$5,$6,null) v',[source,target,who,data,'a'.repeat(64),'b'.repeat(64)]).then(r=>r.rows[0].v);
 await db.exec('set role service_role');const receipt=await sighting('lost',reporter,first);
 await actor(reporter);const blocked=await set(await prepare(),true);
 await db.exec('reset role;set role service_role');assert.deepEqual(await sighting('lost',reporter,first),receipt);
 for(const source of ['lost','found'])await assert.rejects(sighting(source,reporter,report(51)),/interaction_blocked/);
 // Anonymous endpoint deliberately remains usable and cannot assert an account.
 await db.exec('reset role');await db.query('insert into public.case_public_links(case_source,case_id,owner_id,public_slug) values($1,$2,$3,$4)',['lost',target,owner,'c'.repeat(64)]);
 await db.exec('set role service_role');assert.equal((await db.query('select public.read_qr_case($1) v',['c'.repeat(64)])).rows[0].v.state,'active');
 await db.query('select public.submit_public_sighting($1,$2,$3,$4,null)',['c'.repeat(64),report(52),'c'.repeat(64),'d'.repeat(64)]);
 await actor(reporter);assert.equal((await db.query('select * from public.read_recovery_pet_case($1)',[target])).rows.length,1);
 await db.query('select public.submit_content_report($1,$2,$3,$4,null)',[uuid(53),'lost',target,'Contenido problemático']);
 await db.exec('reset role');
 const notice=(id,who,community=false)=>db.query("insert into public.found_cases(id,owner_id,status,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,species,traits,photo_ids,published_at,report_kind,target_lost_case_id,target_community_case_id) values($1,$2,'active',now(),-12,-77,'PRIVATE',-12,-77,'dog','Aviso',array[]::uuid[],now(),'sighting',$3,$4)",[id,who,community?null:target,community?target:null]);
 for(const community of [false,true])await assert.rejects(notice(uuid(54),reporter,community),/interaction_blocked/);
 // Exercise the actual authenticated publication contract, including a retained draft.
 await actor(reporter);await db.query('select public.prepare_recovery_report($1,$2,$3,$4,false)',[uuid(59),[],'sighting',target]);
 await assert.rejects(db.query("select * from public.publish_recovery_report($1,'sighting',$2,false,now()-interval '1 minute',-12,-77,'Referencia','dog',null,null,null,'Lo vi',null,array[]::uuid[])",[uuid(59),target]),/interaction_blocked/);
 await db.exec('reset role');assert.equal((await db.query('select status from public.found_cases where id=$1',[uuid(59)])).rows[0].status,'draft');
 // The opposite contribution direction is stopped by the same directional choice.
 await db.query("insert into public.found_cases(id,owner_id,status,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,species,traits,photo_ids,published_at,report_kind) values($1,$2,'active',now(),-12,-77,'PRIVATE',-12,-77,'cat','Negra',array[$3]::uuid[],now(),'possible_loss')",[uuid(60),reporter,pet]);
 await assert.rejects(db.query("insert into public.found_cases(id,owner_id,status,occurred_at,latitude,longitude,place_reference,public_latitude,public_longitude,species,traits,photo_ids,published_at,report_kind,target_community_case_id) values($1,$2,'active',now(),-12,-77,'PRIVATE',-12,-77,'cat','Aviso',array[]::uuid[],now(),'with_reporter',$3)",[uuid(61),owner,uuid(60)]),/interaction_blocked/);
 await db.exec('set role service_role');await assert.rejects(db.query('select public.submit_app_sighting($1,$2,$3,$4,$5,$6,null)',['found',uuid(60),owner,report(62),'a'.repeat(64),'e'.repeat(64)]),/interaction_blocked/);
 await db.exec('reset role');
 await notice(uuid(55),other);
 await actor(reporter);await set(blocked,false);await db.exec('reset role');await notice(uuid(56),reporter);
 await actor(owner);const fromSighting=await prepare('sighting',first.id);assert.ok(fromSighting);await set(fromSighting,true);
 const anonymous=await prepare('sighting',uuid(52));assert.equal(anonymous,null);
 await actor(other);await assert.rejects(prepare('sighting',first.id),/case_unauthorized|timeline_forbidden/);
 await db.exec('reset role;set role service_role');await assert.rejects(sighting('lost',reporter,report(57)),/interaction_blocked/);
 await db.exec('reset role');await notice(uuid(58),other);assert.equal((await db.query('select count(*)::int n from public.public_sightings')).rows[0].n,2);
 assert.equal((await db.query('select active_case_count from public.pets where id=$1',[pet])).rows[0].active_case_count,1);
});
