import assert from 'node:assert/strict';
import {test} from 'node:test';
import {AppealFailure,ReadAppeals,SubmitAppeal,AnswerAppeal} from '../shared/features/appeals/domain/appeals.ts';
import {appealDto,appealPageDto} from '../shared/features/appeals/data/appeals_dto.ts';
import {HttpAppealsRepository} from '../shared/features/appeals/data/http_appeals_repository.ts';
import {AppealsSource} from '../server/features/appeals/data/appeals_source.ts';
import {AppealsViewModel} from '../shared/features/appeals/presentation/appeals_view_model.ts';
const id=n=>`cccccccc-cccc-4ccc-8ccc-${String(n).padStart(12,'0')}`;
const entry=()=>({decision:id(1),resource:id(2),kind:'lost',action:'hide',reason:'Motivo de moderación',decidedAt:'2026-10-23T12:00:00Z',appeal:null});
function setup(review=false){
 let value=entry(),failure=null,readFailure=null,barrier=null;const calls=[];
 const repository={list:async()=>{if(readFailure)throw new AppealFailure(readFailure);return {items:[value],next:null};},submit:async c=>{calls.push(c);if(barrier)await barrier;if(failure)throw new AppealFailure(failure);value={...value,appeal:{id:c.id,reason:c.reason,submittedAt:'2026-10-23T12:10:00Z',answer:null}};return value;},answer:async c=>{calls.push(c);if(failure)throw new AppealFailure(failure);value={...value,appeal:{...value.appeal,answer:{id:c.id,actor:id(8),reason:c.reason,answeredAt:'2026-10-23T12:20:00Z'}}};return value;}};
 const model=new AppealsViewModel(new ReadAppeals(repository),new SubmitAppeal(repository),new AnswerAppeal(repository),review,()=>id(9));
 return {model,repository,calls,set:v=>value=v,fail:v=>failure=v,failRead:v=>readFailure=v,barrier:p=>barrier=p};
}
test('HU14.4 use cases validate Unicode, UUIDs, cursors and trimmed commands',async()=>{
 const {repository,calls}=setup();const submit=new SubmitAppeal(repository);
 for(const reason of ['', '\u00a0\u3000','🐾'.repeat(1001)])assert.throws(()=>submit.execute({id:id(9),target:id(1),reason}),e=>e.kind==='invalid');
 await submit.execute({id:id(9),target:id(1),reason:'  🐾'.repeat(1)+'  '});assert.equal(calls[0].reason,'🐾');
 assert.throws(()=>submit.execute({id:'bad',target:id(1),reason:'Motivo'}),e=>e.kind==='invalid');
 assert.throws(()=>new ReadAppeals(repository).execute(false,{id:id(1),time:'bad'}),e=>e.kind==='invalid');
});
test('HU14.4 DTO projects only authorized fields and rejects malformed nested answers',()=>{
 assert.equal(appealDto({...entry(),reporter_id:id(7),evidence:'PRIVATE'}).evidence,undefined);
 assert.throws(()=>appealPageDto({items:Array(21).fill(entry()),next:null}),e=>e.kind==='unavailable');
 assert.throws(()=>appealDto({...entry(),appeal:{id:id(9),reason:'A',submittedAt:'bad',answer:null}}),e=>e.kind==='unavailable');
});
test('HU14.4 ambiguous retry freezes UUID and reason, blocks double submission and clears after success',async()=>{
 const s=setup();await s.model.load();s.model.select(s.model.state.items[0]);s.model.edit('Mi motivo');
 let release;s.barrier(new Promise(r=>release=r));s.fail('unavailable');const pending=s.model.send();await s.model.send();assert.equal(s.calls.length,1);release();await pending;
 const frozen=s.model.state.frozen;s.model.edit('Cambio');assert.equal(s.model.state.reason,'Mi motivo');
 s.fail(null);await s.model.send();assert.deepEqual(s.calls[1],frozen);assert.equal(s.model.state.frozen,null);assert.equal(s.model.state.selected.appeal.reason,'Mi motivo');assert.equal(s.model.state.saved,true);
});
test('HU14.4 conflict preserves draft through a failed refresh and recovers against current state',async()=>{
 const s=setup();await s.model.load();s.model.select(s.model.state.items[0]);s.model.edit('Borrador');s.fail('conflict');await s.model.send();
 s.failRead('unavailable');await s.model.load();assert.equal(s.model.state.refreshRequired,true);assert.equal(s.model.state.reason,'Borrador');await s.model.send();assert.equal(s.calls.length,1);
 s.failRead(null);await s.model.load();assert.equal(s.model.state.frozen,null);assert.equal(s.model.state.refreshRequired,false);assert.equal(s.model.state.reason,'Borrador');
});
test('HU14.4 reviewer answers, revocation clears private content and disposal discards late responses',async()=>{
 const s=setup(true);s.set({...entry(),appeal:{id:id(3),reason:'Privado',submittedAt:'2026-10-23T12:10:00Z',answer:null}});await s.model.load();s.model.select(s.model.state.items[0]);s.model.edit('Respuesta');await s.model.send();assert.equal(s.model.state.selected.appeal.answer.reason,'Respuesta');
 s.failRead('forbidden');await s.model.load();assert.equal(s.model.state.items.length,0);assert.equal(s.model.state.selected,null);assert.equal(s.model.state.reason,'');
 const delayed=setup();await delayed.model.load();delayed.model.select(delayed.model.state.items[0]);delayed.model.edit('Privado');let release;delayed.barrier(new Promise(r=>release=r));const promise=delayed.model.send();delayed.model.dispose();release();await promise;assert.equal(delayed.model.state.selected,null);assert.equal(delayed.model.state.items.length,0);
});
test('HU14.4 HTTP binds actor and maps sanitized failures; RPC uses user JWT and bounded responses',async()=>{
 let request;const http=new HttpAppealsRepository(id(8),async(path,options)=>{request={path,options};return new Response(JSON.stringify({items:[entry()],next:null}));});await http.list(false,null);assert.equal(request.options.headers['X-Account-Actor'],id(8));assert.equal(request.path,'/api/appeals/list');
 const config={url:'http://backend.test',key:'publishable'};
 const source=new AppealsSource(config,'private-jwt',async(path,options)=>{assert.equal(options.headers.Authorization,'Bearer private-jwt');return new Response(JSON.stringify({message:'appeal_conflict'}),{status:400});});await assert.rejects(source.rpc('submit_moderation_appeal',{}),e=>e.kind==='conflict');
 const oversized=new AppealsSource(config,'jwt',async()=>new Response('x'.repeat(262145)));await assert.rejects(oversized.rpc('list_moderation_appeals',{}),e=>e.kind==='unavailable');
});
