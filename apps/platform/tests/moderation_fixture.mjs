import {createHash,randomBytes} from 'node:crypto';
import {productionFixture} from './server_fixture.mjs';
export const moderator='11111111-1111-4111-8111-111111111145',ordinary='22222222-2222-4222-8222-222222222245',reportId='33333333-3333-4333-8333-333333333345';
const resourceId='44444444-4444-4444-8444-444444444445';
export async function moderationFixture(jpeg=new Uint8Array([255,216,255,217]),options={}){
 let logoutBarrier=null;
 let socialDenied=false,socialCancelled=false;const oauthCodes=new Map();
 const onboarded=new Map();let completions=0,profileFailure=false;
 let revoked=false,hidden=false,ambiguous=false;const decisions=new Map(),accesses=[];let reportVersion=0,resourceVersion=0;
 const send=(res,value,status=200)=>{res.writeHead(status,{'Content-Type':'application/json'});res.end(JSON.stringify(value));};
 async function handle(req,res){
  if(options.handle&&await options.handle(req,res))return true;
  const actor=req.headers.authorization==='Bearer '+'m'.repeat(30)?moderator:ordinary;
  if(req.url?.startsWith('/auth/v1/authorize?')){
   const url=new URL(req.url,'http://fixture'),callback=new URL(url.searchParams.get('redirect_to'));
   if(socialCancelled)callback.searchParams.set('error','access_denied');
   else{const code=randomBytes(24).toString('base64url');oauthCodes.set(code,{challenge:url.searchParams.get('code_challenge'),allowed:!socialDenied});callback.searchParams.set('code',code);}
   res.writeHead(302,{Location:callback.href});res.end();return true;
  }
  if(req.url==='/auth/v1/token?grant_type=pkce'){
   const chunks=[];for await(const b of req)chunks.push(b);const body=JSON.parse(Buffer.concat(chunks).toString()),code=oauthCodes.get(body.auth_code);oauthCodes.delete(body.auth_code);
   if(!code || createHash('sha256').update(body.code_verifier||'').digest('base64url')!==code.challenge){send(res,{error:'invalid_grant'},400);return true;}
   send(res,{access_token:(code.allowed?'m':'o').repeat(30),expires_in:3600,user:{id:code.allowed?moderator:ordinary}});return true;
  }
  if(req.url==='/auth/v1/token?grant_type=password'){
   const chunks=[];for await(const b of req)chunks.push(b);const body=JSON.parse(Buffer.concat(chunks).toString());
   if(body.password!=='test-fixture-password'){send(res,{error_code:'invalid_credentials'},400);return true;}
   const allowed=body.email==='moderador@example.test';send(res,{access_token:(allowed?'m':'o').repeat(30),expires_in:3600,user:{id:allowed?moderator:ordinary}});return true;
  }
  if(req.url==='/auth/v1/user'){send(res,{id:actor,email:actor===moderator?'moderador@example.test':'ordinario@example.test'});return true;}
  if(req.url?.startsWith('/rest/v1/profiles?')){if(profileFailure){send(res,{},503);return true;}send(res,[{id:actor,display_name:actor===moderator?'Revisor de prueba':'Usuario de prueba',city:'Lima',onboarding_completed_at:onboarded.get(actor)===false?null:'2026-10-18T17:00:00Z'}]);return true;}
  if(req.url==='/rest/v1/rpc/complete_onboarding'){for await(const b of req){}if(onboarded.get(actor)===false){completions++;onboarded.set(actor,true);}res.writeHead(204);res.end();return true;}
  if(req.url?.startsWith('/auth/v1/logout')){const barrier=logoutBarrier;if(barrier){barrier.started();await barrier.wait;}send(res,{});return true;}
  if(req.url==='/rest/v1/rpc/read_qr_case'&&hidden){for await(const b of req){}send(res,{state:'unavailable'});return true;}
  if(!req.url?.includes('/rest/v1/rpc/')||!/(require_content_reviewer|list_moderation_reports|read_moderation_report|read_moderation_evidence|decide_content_report)$/.test(req.url))return false;
  const chunks=[];for await(const b of req)chunks.push(b);const input=JSON.parse(Buffer.concat(chunks).toString()||'{}');
  if(actor!==moderator||revoked){send(res,{code:'42501',message:'moderation_forbidden'},403);return true;}
  if(req.url.endsWith('require_content_reviewer')){send(res,moderator);return true;}
  if(req.url.endsWith('list_moderation_reports')){accesses.push('queue');send(res,{items:(input.p_resolved===(reportVersion>0))?[{id:reportId,resource_kind:'lost',resource_id:resourceId,submitted_at:'2026-10-18T17:00:00Z',version:reportVersion}]:[],next:null});return true;}
  if(req.url.endsWith('read_moderation_report')){accesses.push('detail');send(res,{report:{id:reportId,reporter_id:ordinary,resource_kind:'lost',resource_id:resourceId,reason:'PRIVATE_REPORT_REASON',evidence_note:'Descripción privada de la denuncia',submitted_at:'2026-10-18T17:00:00Z'},resource:{title:'Luna',text:'Publicación denunciada para revisión.',status:'active',removed:false,has_photo:true},report_version:reportVersion,resource_version:resourceVersion,hidden,effective_hidden:hidden,history:[...decisions.values()].reverse()});return true;}
  if(req.url.endsWith('read_moderation_evidence')){accesses.push('evidence');send(res,{jpeg:Buffer.from(jpeg).toString('base64')});return true;}
  let saved=decisions.get(input.p_command);
  if(!saved){if(input.p_report_version!==reportVersion||input.p_resource_version!==resourceVersion){send(res,{message:'moderation_conflict'},409);return true;}
   hidden=input.p_action==='hide'?true:input.p_action==='show'?false:hidden;reportVersion++;resourceVersion++;
   saved={command_id:input.p_command,report_id:input.p_report,actor_id:moderator,action:input.p_action,reason:input.p_reason,report_version:reportVersion,resource_version:resourceVersion,hidden,decided_at:'2026-10-18T17:10:00Z'};decisions.set(input.p_command,saved);accesses.push('decision');
  }
  if(ambiguous){ambiguous=false;send(res,{message:'PRIVATE_FAILURE_AFTER_COMMIT'},503);}else send(res,saved);
  return true;
 }
 const server=await productionFixture(jpeg,{handle,env:{SUPABASE_PUBLISHABLE_KEY:'sb_publishable_fixture_123456',MODERATION_SESSION_SECRET:'fixture-session-secret-only-not-a-production-key',...(options.env||{})}});
 return {...server,close:async()=>{logoutBarrier?.release();await server.close();},pauseLogout(){let started,release;const wait=new Promise(resolve=>{release=resolve;}),begun=new Promise(resolve=>{started=resolve;});logoutBarrier={wait,started,release};return {started:begun,release(){logoutBarrier=null;release();}};},setOnboarding:(actor,value)=>onboarded.set(actor,value),completions:()=>completions,profileFailure:value=>{profileFailure=value;},oauthDenied:value=>{socialDenied=value;},oauthCancelled:value=>{socialCancelled=value;},revoke:value=>{revoked=value;},ambiguousDecision:()=>{ambiguous=true;},decisions:()=>decisions.size,accesses:()=>accesses,hidden:()=>hidden};
}
