import assert from 'node:assert/strict';
import {test} from 'node:test';
import {ReadUserBlocks,PrepareUserBlock,SetUserBlock,BlockFailure} from '../shared/features/user_blocks/domain/user_blocks.ts';
import {UserBlockViewModel} from '../shared/features/user_blocks/presentation/user_block_view_model.ts';
import {HttpUserBlockRepository} from '../shared/features/user_blocks/data/http_user_block_repository.ts';
import {ServerUserBlockRepository} from '../server/features/user_blocks/data/server_user_block_repository.ts';
import {UserBlockSource} from '../server/features/user_blocks/data/user_block_source.ts';
import {SupabaseSightingDataSource} from '../server/features/sightings/data/supabase_sighting_data_source.ts';
import {RecoverySource} from '../server/features/recovery/data/recovery_source.ts';
const entry={id:'cccccccc-cccc-4ccc-8ccc-cccccccccc42',label:'Reportante de Luna',enabled:false,version:0};
const target={kind:'lost',id:'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa42'};
const deferred=()=>{let resolve;const promise=new Promise(r=>{resolve=r;});return {resolve,promise};};
const model=(repo,t=target)=>new UserBlockViewModel(new ReadUserBlocks(repo),new PrepareUserBlock(repo),new SetUserBlock(repo),t);
test('HU14.2 domain validates all references before repository access',()=>{
 const repo={list(){throw Error('must not call');},prepare(){throw Error('must not call');},set(){throw Error('must not call');}};
 assert.throws(()=>new ReadUserBlocks(repo).execute('bad'),e=>e.kind==='invalid');
 assert.throws(()=>new PrepareUserBlock(repo).execute({...target,kind:'profile'}),e=>e.kind==='invalid');
 for(const change of [null,{entry,enabled:'true'},{entry:{...entry,version:-1},enabled:true}])assert.throws(()=>new SetUserBlock(repo).execute(change),e=>e.kind==='invalid');
});
test('HU14.2 ambiguous changes retain exact version and suppress duplicate/opposite actions; disposal drops late results',async()=>{
 const gate=deferred(),attempts=[];let fail=true;
 const repo={list:async()=>({items:[],next:null}),prepare:async()=>entry,set:async change=>{attempts.push(change);await gate.promise;if(fail)throw new BlockFailure('unavailable');return {...entry,enabled:true,version:1};}};
 const m=model(repo);await m.load();const first=m.change(entry,true);await m.change(entry,true);assert.equal(attempts.length,1);gate.resolve();await first;
 assert.ok(m.state.pending);await m.change(entry,false);assert.equal(attempts.length,1);fail=false;await m.change(entry,true);assert.equal(attempts[0],attempts[1]);assert.equal(m.state.target.enabled,true);assert.equal(m.state.pending,null);
 const later=deferred();repo.set=async()=>later.promise;const pending=m.change(m.state.target,false);m.dispose();later.resolve({...entry,version:2});await pending;assert.equal(m.state.target,null);assert.deepEqual(m.state.items,[]);
});
test('HU14.2 refresh failures preserve confirmed data/cursors; expired identity clears private state',async()=>{
 let failure=null;
 const m=model({list:async()=>{if(failure)throw new BlockFailure(failure);return {items:[{...entry,enabled:true}],next:entry.id};},prepare:async()=>null,set:async()=>{}},null);
 await m.load();failure='unavailable';await m.load(true);assert.equal(m.state.items.length,1);assert.equal(m.state.next,entry.id);
 failure='unauthenticated';await m.load();assert.equal(m.state.items.length,0);assert.equal(m.state.next,null);
});
test('HU14.2 stale version conflict requires a fresh consultation; returned account IDs never enter client data',async()=>{
 let writes=0;
 const m=model({list:async()=>({items:[],next:null}),prepare:async()=>entry,set:async()=>{writes++;throw new BlockFailure('conflict');}});
 await m.load();await m.change(entry,true);await m.change(entry,true);assert.equal(writes,1);assert.equal(m.state.pending,null);await m.load();assert.equal(m.state.failure,null);
 const calls=[],repo=new ServerUserBlockRepository(new UserBlockSource({url:'https://backend.test',key:'publishable'},'private-token',async(url,init)=>{calls.push({url,init});return Response.json({...entry,owner_id:'PRIVATE',blocked_id:'PRIVATE'});}));
 assert.deepEqual(await repo.prepare(target),entry);assert.equal(calls[0].init.headers.Authorization,'Bearer private-token');assert.deepEqual(JSON.parse(calls[0].init.body),{p_kind:target.kind,p_resource:target.id});
});
test('HU14.2 HTTP binds account and rejects mismatched receipts; source failures are safe and bounded',async()=>{
 let request;const repo=new HttpUserBlockRepository('actor',async(url,init)=>{request={url,init};return Response.json({...entry,enabled:true,version:1});});
 await repo.set({entry,enabled:true});assert.equal(request.init.headers['X-Account-Actor'],'actor');assert.equal(request.init.credentials,'same-origin');assert.deepEqual(JSON.parse(request.init.body),{id:entry.id,enabled:true,version:0});
 const invalid=new HttpUserBlockRepository('actor',async()=>Response.json({...entry,version:99}));await assert.rejects(invalid.set({entry,enabled:true}),e=>e.kind==='unavailable');
 const source=new UserBlockSource({url:'https://backend.test',key:'publishable'},'private',async()=>new Response('PRIVATE_ERROR',{status:403}));await assert.rejects(source.rpc('list_user_blocks',{}),e=>e.message==='forbidden');
 const tooLarge=new UserBlockSource({url:'https://backend.test',key:'publishable'},'private',async()=>new Response('x'.repeat(65537)));await assert.rejects(tooLarge.rpc('list_user_blocks',{}),e=>e.message==='unavailable');
});
test('HU14.2 blocked contribution failures remain distinct from authentication, retry uncertainty and private backend text',async()=>{
 const response=()=>Response.json({code:'42501',message:'interaction_blocked'},{status:403});
 await assert.rejects(new SupabaseSightingDataSource({url:'https://backend.test',key:'private'},response).submit({}),e=>e.kind==='blocked');
 await assert.rejects(new RecoverySource({url:'https://backend.test',key:'publishable'},'token',response).rpc('publish_recovery_report',{}),e=>e.kind==='blocked');
});
