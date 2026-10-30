import assert from 'node:assert/strict';
import { test } from 'node:test';
import { ExploreCases, SaveMyPet, PublishRecoveryReport, RecoveryFailure, ReadMyPets, AddPetPhoto, ReadOpenSearches, ReadReportDraft, SaveReportDraft, ClearReportDraft } from '../shared/features/recovery/domain/recovery.ts';
import { RecoveryViewModel } from '../shared/features/recovery/presentation/recovery_view_model.ts';
const id='55555555-5555-4555-8555-555555555555', photo='66666666-6666-4666-8666-666666666666';
const report={id,kind:'own_loss',petId:id,petVersion:1,targetId:null,communityTarget:false,occurredAt:'2026-10-19T12:00:00.000Z',latitude:-12,longitude:-77,place:'Parque',species:'',speciesDetail:'',size:'',sex:'',traits:'',photoIds:[photo]};

test('Report prerequisites run together and late responses cannot restore disposed account data', async () => {
 let finishPets, finishTargets;
 const repository = { pets: () => new Promise(resolve => { finishPets = resolve; }), targets: () => new Promise(resolve => { finishTargets = resolve; }) };
 const drafts = {};
 const vm = new RecoveryViewModel(new ExploreCases(repository),new ReadMyPets(repository),new SaveMyPet(repository),new AddPetPhoto(repository),new ReadOpenSearches(repository),new PublishRecoveryReport(repository),new ReadReportDraft(drafts),new SaveReportDraft(drafts),new ClearReportDraft(drafts));
 const load = vm.load('report');
 assert.equal(typeof finishPets, 'function'); assert.equal(typeof finishTargets, 'function');
 assert.equal(vm.state.loading,false);assert.equal(vm.state.petsLoading,true);assert.equal(vm.state.targetsLoading,true);
 finishPets([{ id }]); await new Promise(setImmediate);
 assert.equal(vm.state.petsReady,true);assert.deepEqual(vm.state.pets,[{id}]);assert.equal(vm.state.petsLoading,false);assert.equal(vm.state.targetsLoading,true);
 vm.dispose(); finishTargets([{ id }]); await load;
 assert.deepEqual(vm.state.pets, []); assert.deepEqual(vm.state.targets, []);
});

test('Report sources publish independently, retain errors/confirmed content, and retry only the failed selector', async () => {
 let petsCalls=0,targetsCalls=0,resolveTargets,rejectTargets;
 const repository={pets:async()=>{petsCalls++;return[{id}];},targets:()=>{targetsCalls++;return new Promise((resolve,reject)=>{resolveTargets=resolve;rejectTargets=reject;});}};
 const vm=reportModel(repository);
 const first=vm.load('report');await new Promise(setImmediate);
 assert.equal(vm.state.petsReady,true);assert.equal(vm.state.targetsReady,false);
 rejectTargets(new RecoveryFailure('unavailable'));await first;
 assert.deepEqual(vm.state.pets,[{id}]);assert.equal(vm.state.targetsReady,false);assert.equal(vm.state.targetsFailure.kind,'unavailable');
 const retry=vm.loadReportSource('targets');await vm.loadReportSource('targets');
 assert.equal(targetsCalls,2);assert.equal(petsCalls,1);assert.equal(vm.state.targetsLoading,true);assert.equal(vm.state.targetsFailure.kind,'unavailable');
 resolveTargets([{id}]);await retry;
 assert.equal(vm.state.targetsReady,true);assert.equal(vm.state.targetsFailure,null);assert.equal(vm.state.failure,null);
 const refresh=vm.loadReportSource('targets');assert.deepEqual(vm.state.targets,[{id}]);assert.equal(vm.state.targetsReady,true);
 resolveTargets([]);await refresh;assert.deepEqual(vm.state.targets,[]);assert.equal(vm.state.targetsReady,true);vm.dispose();
});

test('Late draft/source results are discarded after disposal or a confirmed publication', async () => {
 let resolvePets,rejectTargets,resolveDraft;
 const repository={pets:()=>new Promise(resolve=>{resolvePets=resolve;}),targets:()=>new Promise((_resolve,reject)=>{rejectTargets=reject;}),publish:async()=>({id,status:'active'})};
 const drafts={read:()=>new Promise(resolve=>{resolveDraft=resolve;}),clear:async()=>{}};
 const vm=reportModel(repository,drafts),load=vm.load('report'),draft=vm.restoreDraft();
 await vm.send(report,[]);assert.equal(vm.state.receipt.id,id);
 resolvePets([{id}]);rejectTargets(new RecoveryFailure('unavailable'));resolveDraft({draft:report,photos:[],frozen:false});
 await load;assert.equal(await draft,null);assert.equal(vm.state.failure,null);assert.deepEqual(vm.state.pets,[]);assert.equal(vm.state.targetsLoading,false);
 const other=reportModel(repository,drafts),otherLoad=other.load('report'),otherDraft=other.restoreDraft();other.dispose();
 resolvePets([{id}]);rejectTargets(new RecoveryFailure('unavailable'));resolveDraft({draft:report,photos:[],frozen:false});
 await otherLoad;assert.equal(await otherDraft,null);assert.equal(other.state.failure,null);assert.deepEqual(other.state.pets,[]);
});

function reportModel(repository,drafts={}) {
 return new RecoveryViewModel(new ExploreCases(repository),new ReadMyPets(repository),new SaveMyPet(repository),new AddPetPhoto(repository),new ReadOpenSearches(repository),new PublishRecoveryReport(repository),new ReadReportDraft(drafts),new SaveReportDraft(drafts),new ClearReportDraft(drafts));
}
test('Web operations reject missing pet metadata, invalid filters and invalid reports before repository writes',async()=>{
 let writes=0;const repository={savePet:async()=>writes++,publish:async()=>writes++,explore:async()=>writes++};
 const save=new SaveMyPet(repository);
 assert.throws(()=>save.execute({id,version:0,name:'',species:'dog',ageMonths:null,traits:'',size:null,sex:null,speciesDetail:null}),e=>e.kind==='invalid'&&e.fields.includes('name')&&e.fields.includes('ageMonths')&&e.fields.includes('size'));
 assert.throws(()=>new ExploreCases(repository).execute({kind:'all',species:'all',status:'private'}),RecoveryFailure);
 const publish=new PublishRecoveryReport(repository);
 for(const change of [{latitude:NaN},{longitude:181},{occurredAt:'2100-01-01'},{photoIds:[]},{petVersion:0},{kind:'sighting',targetId:null},{kind:'possible_loss',targetId:null,traits:'Vista',species:'dog',photoIds:[]}])assert.throws(()=>publish.execute({...report,...change},[]),RecoveryFailure);
 assert.equal(writes,0);await publish.execute(report,[]);assert.equal(writes,1);
});
test('Recovery screen blocks duplicate writes, retains confirmed content during refresh and ignores late state after disposal',async()=>{
 let release;const pending=new Promise(r=>{release=r;});let count=0;
 const repository={pets:async()=>[],targets:async()=>[],savePet:async d=>d,uploadPetPhoto:async()=>{},explore:async()=>({items:[{id,source:'lost'}],cursor:null}),publish:async()=>{count++;await pending;return{id,status:'active'};}};
 const drafts={read:async()=>null,save:async()=>{},clear:async()=>{}};
 const vm=new RecoveryViewModel(new ExploreCases(repository),new ReadMyPets(repository),new SaveMyPet(repository),new AddPetPhoto(repository),new ReadOpenSearches(repository),new PublishRecoveryReport(repository),new ReadReportDraft(drafts),new SaveReportDraft(drafts),new ClearReportDraft(drafts));
 await vm.load('explore');assert.equal(vm.state.items.length,1);
 const first=vm.send(report,[]);await vm.send(report,[]);assert.equal(count,1);vm.dispose();release();await first;assert.equal(vm.state.receipt,null);assert.equal(vm.state.items.length,0);
});
