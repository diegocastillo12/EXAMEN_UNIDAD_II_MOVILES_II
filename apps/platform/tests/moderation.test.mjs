import assert from 'node:assert/strict';
import {test} from 'node:test';
import {AccessModeration,ReviewReports,DecideReport,ModerationFailure} from '../shared/features/moderation/domain/moderation.ts';
import {ModerationViewModel} from '../shared/features/moderation/presentation/moderation_view_model.ts';
import {detailDto,pageDto} from '../shared/features/moderation/data/moderation_dto.ts';
import {HttpModerationRepository} from '../shared/features/moderation/data/http_moderation_repository.ts';
import {moderationConfiguration,sealSession,openSession} from '../server/infrastructure/moderation_session.ts';
import {ModerationSource} from '../server/features/moderation/data/moderation_source.ts';
import {ServerModerationRepository} from '../server/features/moderation/data/server_moderation_repository.ts';
const actor='11111111-1111-4111-8111-111111111145',id='22222222-2222-4222-8222-222222222245',commandId='33333333-3333-4333-8333-333333333345';
const detail={id,kind:'lost',resourceId:id,submittedAt:'2026-10-18T17:00:00Z',reason:'Privado',evidence:'Evidencia',resource:{title:'Luna',text:'Descripción',status:'active',removed:false,hasPhoto:false},reportVersion:0,resourceVersion:0,hidden:false,effectiveHidden:false,history:[]};
class FakeModeration {
  attempts=[];ambiguous=false;failRead=false;failure=null;pending=null;
  async session(){return {actor,expiresAt:Date.now()+3600000};}
  async login(){return this.session();} async logout(){}
  async list(){return {items:[{id,kind:'lost',resourceId:id,submittedAt:detail.submittedAt,version:0}],next:null};}
  async read(){if(this.failRead)throw new ModerationFailure('unavailable');return detail;}
  async decide(c){this.attempts.push(c);await this.pending;if(this.failure)throw new ModerationFailure(this.failure);if(this.ambiguous)throw new ModerationFailure('unavailable');return {id:c.id,report:c.report,actor,action:c.action,reason:c.reason,reportVersion:c.reportVersion+1,resourceVersion:c.resourceVersion+1,hidden:c.action==='hide',decidedAt:detail.submittedAt};}
}
function model(repo){return new ModerationViewModel(new AccessModeration(repo),new ReviewReports(repo),new DecideReport(repo),()=>commandId);}
test('Moderation validates intent, Unicode limits and stable identifiers before repository calls',async()=>{
 const repo=new FakeModeration(),action=new DecideReport(repo),access=new AccessModeration(repo);
 const c={id:commandId,report:id,reportVersion:0,resourceVersion:0,action:'hide',reason:'Motivo'};
 for(const reason of ['', '\u00a0\u3000','🐾'.repeat(501)])assert.throws(()=>action.execute({...c,reason}),/invalid/);
 assert.throws(()=>action.execute({...c,action:'delete'}),/invalid/);assert.throws(()=>action.execute({...c,resourceVersion:-1}),/invalid/);
 assert.throws(()=>access.login('bad',''),/invalid/);assert.throws(()=>new ReviewReports(repo).read('bad'),/invalid/);
 await action.execute({...c,reason:'🐾'.repeat(500)});assert.equal(repo.attempts.length,1);
});
test('Ambiguous decisions freeze UUID/payload and double submit cannot overwrite a committed receipt',async()=>{
 const repo=new FakeModeration(),vm=model(repo);await vm.checkSession();await vm.open(id);vm.edit('Motivo','hide');repo.ambiguous=true;
 await vm.decide();assert.equal(vm.state.receipt,null);const frozen=vm.state.frozen;vm.edit('otro','show');assert.equal(vm.state.reason,'Motivo');
 repo.ambiguous=false;let complete;repo.pending=new Promise(resolve=>complete=resolve);const saving=vm.decide();await vm.decide();complete();await saving;
 assert.equal(repo.attempts.length,2);assert.equal(vm.state.receipt.id,frozen.id);assert.deepEqual(repo.attempts[0],repo.attempts[1]);vm.dispose();
});
test('Conflicts preserve the draft; failed refresh retains it; explicit fresh read permits another decision',async()=>{
 const repo=new FakeModeration(),vm=model(repo);await vm.checkSession();await vm.open(id);vm.edit('Conservar motivo','hide');repo.failure='conflict';
 await vm.decide();await vm.decide();assert.equal(repo.attempts.length,1);repo.failRead=true;await vm.refreshDetail();assert.equal(vm.state.reason,'Conservar motivo');assert.ok(vm.state.frozen);
 repo.failRead=false;await vm.refreshDetail();assert.equal(vm.state.reason,'Conservar motivo');assert.equal(vm.state.frozen,null);vm.dispose();
});
test('Role loss, identity change and disposal erase private state and reject late responses',async()=>{
 const repo=new FakeModeration(),vm=model(repo);await vm.checkSession();await vm.open(id);vm.edit('Motivo','hide');
 let complete;repo.pending=new Promise(resolve=>complete=resolve);const saving=vm.decide();vm.clear();complete();await saving;assert.equal(vm.state.detail,null);assert.equal(vm.state.receipt,null);
 repo.pending=null;await vm.checkSession();await vm.open(id);vm.edit('Motivo','hide');repo.failure='forbidden';await vm.decide();assert.equal(vm.state.session,null);assert.equal(vm.state.reason,'');
 repo.failure=null;await vm.checkSession();await vm.open(id);vm.edit('Motivo');repo.pending=new Promise(resolve=>complete=resolve);const late=vm.decide();vm.dispose();complete();await late;assert.equal(vm.state.detail,null);
});
test('Session encryption authenticates ciphertext, expiry, secret rotation and server-only configuration',()=>{
 const secret='s'.repeat(48),session={actor,token:'test-private-jwt',expiresAt:Date.now()+300000};const sealed=sealSession(session,secret);
 assert.ok(!sealed.includes(session.token));assert.deepEqual(openSession(sealed,secret),session);assert.equal(openSession(sealed,'other'),null);
 assert.equal(openSession(sealed.slice(0,-4)+'aaaa',secret),null);assert.equal(openSession(sealSession({...session,expiresAt:Date.now()-1},secret),secret),null);
 const config=moderationConfiguration({SUPABASE_URL:'https://example.test',SUPABASE_PUBLISHABLE_KEY:'sb_publishable_example_12345',MODERATION_SESSION_SECRET:secret});assert.equal(config.secure,true);
 for(const env of [{},{SUPABASE_URL:'https://example.test',SUPABASE_PUBLISHABLE_KEY:'sb_secret_NOT_allowed',MODERATION_SESSION_SECRET:secret}])assert.throws(()=>moderationConfiguration(env),/unavailable/);
});
test('Server verifies Auth user and database role for every operation and DTO drops private identity/coordinates',async()=>{
 const calls=[];let revoked=false;
 const source=new ModerationSource({url:'https://backend.test',key:'publishable',sessionSecret:'s'.repeat(48),secure:true},async(url,options)=>{
  calls.push([url,options.headers]);if(url.endsWith('/auth/v1/user'))return Response.json({id:actor});
  if(url.endsWith('/require_content_reviewer'))return revoked?Response.json({code:'42501'},{status:403}):Response.json(actor);
  return Response.json({items:[],next:null});
 });
 const repo=new ServerModerationRepository(source,{actor,token:'jwt-private-token',expiresAt:Date.now()+300000});await repo.list(false,null);assert.equal(calls.length,3);
 assert.equal(calls[0][1].Authorization,'Bearer jwt-private-token');revoked=true;await assert.rejects(repo.list(false,null),/forbidden/);
 const dto=detailDto({report:{id,resource_kind:'lost',resource_id:id,submitted_at:detail.submittedAt,reason:'privado',evidence_note:null,reporter_id:'do-not-expose'},resource:{title:'Luna',text:'texto',status:'active',removed:false,has_photo:false,latitude:123},report_version:0,resource_version:0,hidden:false,effective_hidden:false,history:[]});
 assert.equal(dto.resource.latitude,undefined);assert.equal(dto.reporter_id,undefined);assert.throws(()=>pageDto({items:[{id:'invalid'}],next:null}),/unavailable/);
});
test('Same-origin client binds account, omits tokens and maps HTTP failures safely',async()=>{
 const calls=[];let fail=false;
 const repo=new HttpModerationRepository(async(path,options)=>{calls.push({path,options});return fail?new Response('PRIVATE FAILURE',{status:403}):Response.json({actor,expiresAt:Date.now()+300000});});
 await repo.session();await repo.read(id);assert.equal(calls[1].options.headers['X-Moderation-Actor'],actor);assert.equal(calls[1].options.credentials,'same-origin');assert.equal(calls[1].options.headers.Authorization,undefined);
 fail=true;await assert.rejects(repo.read(id),error=>error.kind==='forbidden'&&!error.message.includes('PRIVATE'));
 const original=globalThis.fetch;
 try{globalThis.fetch=function(){assert.equal(this,globalThis,'native browser fetch must retain its receiver');return Promise.resolve(Response.json({actor,expiresAt:Date.now()+300000}));};
  assert.equal((await new HttpModerationRepository().session()).actor,actor);
 }finally{globalThis.fetch=original;}
});


test('Login view model validates input, prevents duplicate submits and never loads private reports', async () => {
 const {AccessViewModel}=await import('../shared/features/moderation/presentation/access_view_model.ts');
 let resolveLogin, calls=0;
 const repository={session:async()=>{throw new ModerationFailure('unauthenticated');},login:()=>{calls++;return new Promise(resolve=>{resolveLogin=resolve;});}};
 const model=new AccessViewModel(new AccessModeration(repository));
 await model.checkSession();assert.equal(model.state.checking,false);assert.equal(model.state.failure,null);
 await model.login('invalid','');assert.equal(model.state.failure.kind,'invalid');assert.equal(calls,0);
 const pending=model.login('reviewer@example.test','password');await model.login('reviewer@example.test','password');assert.equal(calls,1);
 const session={actor:'reviewer',expiresAt:Date.now()+60000};resolveLogin(session);await pending;assert.deepEqual(model.state.session,session);assert.equal(model.state.busy,false);
 model.dispose();assert.equal(model.state.session,null);
});

test('Login distinguishes role denial and network failure, and ignores responses after leaving', async () => {
 const {AccessViewModel}=await import('../shared/features/moderation/presentation/access_view_model.ts');
 for(const kind of ['forbidden','unavailable']){
  const model=new AccessViewModel(new AccessModeration({session:async()=>{throw new ModerationFailure(kind);}}));
  await model.checkSession();assert.equal(model.state.failure.kind,kind);assert.equal(model.state.session,null);
 }
 let resolve;const model=new AccessViewModel(new AccessModeration({session:()=>new Promise(r=>{resolve=r;})}));
 const pending=model.checkSession();model.dispose();resolve({actor:'late',expiresAt:Date.now()+60000});await pending;assert.equal(model.state.session,null);
});


test('Social flow binds state/verifier, encrypts cookies, expires and rejects tampering',async()=>{
 const {newOAuthFlow,sealOAuthFlow,openOAuthFlow,authorizeSocialUrl}=await import('../server/infrastructure/social_oauth.ts');
 const secret='test-secret-for-oauth-flow-only-123456789',flow=newOAuthFlow('google'),sealed=sealOAuthFlow(flow,secret);
 assert.equal(sealed.includes(flow.verifier),false);assert.deepEqual(openOAuthFlow(sealed,flow.state,secret),flow);
 assert.throws(()=>newOAuthFlow('apple'));assert.throws(()=>openOAuthFlow(sealed,'x'.repeat(43),secret));assert.throws(()=>openOAuthFlow(sealed,flow.state,'different-secret'));assert.throws(()=>openOAuthFlow('bad',flow.state,secret));
 assert.throws(()=>openOAuthFlow(sealOAuthFlow({...flow,expiresAt:Date.now()-1},secret),flow.state,secret));
 const url=new URL(authorizeSocialUrl('https://backend.example','https://web.example',flow));assert.equal(url.searchParams.get('provider'),'google');assert.equal(url.searchParams.get('code_challenge_method'),'s256');assert.notEqual(url.searchParams.get('code_challenge'),flow.verifier);assert.equal(new URL(url.searchParams.get('redirect_to')).origin,'https://web.example');
});
