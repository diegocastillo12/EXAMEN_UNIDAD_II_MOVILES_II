import assert from 'node:assert/strict';
import {test}from'node:test';
import {matchModel,unitEmbedding,rankMatches,MatchFailure,FindCaseMatches,ReadMatchSearches,ReviewCaseMatch}from'../shared/features/matching/domain/matching.ts';
import{matchResult,HttpMatchingRepository}from'../shared/features/matching/data/http_matching_repository.ts';
import{ServerMatchingRepository}from'../server/features/matching/data/server_matching_repository.ts';
import{MatchingViewModel}from'../shared/features/matching/presentation/matching_view_model.ts';
import{validateReport}from'../shared/features/recovery/domain/recovery.ts';
const id=n=>`a0000000-0000-4000-8000-${String(n).padStart(12,'0')}`;
const vector=[1,...Array(511).fill(0)],ref={source:'lost',id:id(1)};
const item=(n,embedding=vector)=>({ref:{source:'found',id:id(n)},revision:'a'.repeat(32),name:'Mascota',species:'dog',occurredAt:'2026-10-24T12:00:00Z',latitude:-18.12,longitude:-70.12,photos:[{id:id(n+50),path:`${id(9)}/${id(n)}/${id(n+50)}.jpg`,hash:'b'.repeat(64),embedding}]});
const domainAnchor={...item(1),ref};
const row=c=>({source:c.ref.source,id:c.ref.id,revision:c.revision,name:c.name,species:c.species,occurred_at:c.occurredAt,latitude:c.latitude,longitude:c.longitude,photos:c.photos,owner:'PRIVATE_OWNER'});
const result={anchor:ref,revision:'a'.repeat(32),model:matchModel.version,candidates:[{ref:{source:'found',id:id(2)},revision:'b'.repeat(32),name:'Mascota',distanceMeters:25,daysApart:1,review:null}],pendingPhotos:0,complete:true};
test('visual ranking uses normalized embeddings, case grouping, species and soft distance/time without inventing identity probability',()=>{
 for(const v of[[],Array(512).fill(0),Array(512).fill(NaN),Array(512).fill(1e308)])assert.throws(()=>unitEmbedding(v));
 const candidates=[{...item(2),photos:[...item(2).photos,...item(2).photos]},...Array.from({length:8},(_,i)=>item(i+3)),{...item(30),species:'cat'},item(31,null)];
 const ranked=rankMatches(domainAnchor,candidates);assert.equal(ranked.length,5);assert.equal(ranked[0].item.ref.id,id(2));assert.equal(new Set(ranked.map(c=>c.item.ref.id)).size,5);
 assert.ok(ranked.every(r=>r.item.species==='dog'));assert.deepEqual(rankMatches({...domainAnchor,photos:[]},candidates),[]);
});
test('matching repository bounds indexing, continues persisted work, rechecks lifecycle and never returns vectors, paths or owner IDs',async()=>{
 let calls=0,saves=0,reads=0,removed=false;const anchor={...domainAnchor,photos:domainAnchor.photos.map(p=>({...p,embedding:null}))},candidate=item(2,null);
 const source={async rpc(name,p){if(name==='read_case_match_context'){reads++;return{anchor:row(anchor),candidates:removed?[]:[row(candidate)],reviews:[]};}if(name==='store_case_match_embedding'){saves++;const c=p.p_source==='lost'?anchor:candidate;c.photos[0].embedding=p.p_embedding;}},async photo(){calls++;return new Uint8Array([255,216,255]);}};
 const repository=new ServerMatchingRepository(source,{async encode(){return vector;}},id(9),1);
 const first=await repository.search(ref);assert.equal(first.complete,false);assert.equal(first.pendingPhotos,1);assert.deepEqual(first.candidates,[]);
 const second=await repository.search(ref);assert.equal(second.complete,true);assert.equal(second.candidates.length,1);assert.equal(calls,2);assert.equal(saves,2);assert.equal(reads,4);
 assert.doesNotMatch(JSON.stringify(second),/PRIVATE|embedding|photo_hash|path|score/);
 removed=true;assert.equal((await repository.search(ref)).candidates.length,0);assert.equal(calls,2);
});
test('matching DTO strips private extras; HTTP binds account and validates acknowledged review',async()=>{
 const clean=matchResult({...result,owner:'PRIVATE',embedding:vector});assert.doesNotMatch(JSON.stringify(clean),/PRIVATE|embedding/);
 for(const v of[{...result,candidates:Array(6).fill(result.candidates[0])},{...result,model:'other'},{...result,pendingPhotos:-1}])assert.throws(()=>matchResult(v));
 let request;const repository=new HttpMatchingRepository(id(9),async(_,options)=>{request=options;return new Response(JSON.stringify(result));});
 await repository.search(ref);assert.equal(request.headers['X-Account-Actor'],id(9));assert.equal(request.credentials,'same-origin');
 const fail=new HttpMatchingRepository(id(9),async()=>new Response('PRIVATE',{status:403}));await assert.rejects(fail.search(ref),e=>e.kind==='forbidden'&&!e.message.includes('PRIVATE'));
});
test('matching view model deduplicates actions, reuses an ambiguous review command and drops late account data',async()=>{
 let reject=false,release,pending;const commands=[];
 const repository={searches:async()=>[{ref,name:'Luna',species:'dog'}],search:async()=>{if(pending)await pending;return result;},review:async c=>{commands.push(c);if(reject)throw new MatchFailure('unavailable');}};
 const model=new MatchingViewModel(new ReadMatchSearches(repository),new FindCaseMatches(repository),new ReviewCaseMatch(repository));
 await model.load();await model.search();reject=true;await model.decide(id(2),'confirmed',id(10));assert.equal(model.state.result.candidates[0].review,null);
 reject=false;await model.decide(id(2),'confirmed',id(11));assert.equal(commands[0].id,commands[1].id);assert.equal(model.state.result.candidates[0].review,'confirmed');
 pending=new Promise(r=>release=r);const work=model.search();await model.search();model.invalidate();release();await work;assert.equal(model.state.result,null);assert.deepEqual(model.state.searches,[]);
});
test('independent finds require photos and own description, never a target; linked observations retain their target requirement',()=>{
 const draft={id:id(1),kind:'independent_found',petId:null,petVersion:null,targetId:null,communityTarget:false,occurredAt:'2026-10-24T12:00:00Z',latitude:-18,longitude:-70,place:'Parque',species:'dog',speciesDetail:'',size:'',sex:'',traits:'Orejas blancas',photoIds:[id(2)]};
 const photos=[{id:id(2),bytes:new Uint8Array([255,216,255])}];
 assert.equal(validateReport(draft,photos).kind,'independent_found');
 assert.throws(()=>validateReport({...draft,targetId:id(3)},photos));assert.throws(()=>validateReport({...draft,photoIds:[]},[]));assert.throws(()=>validateReport({...draft,kind:'sighting'},photos));
});
