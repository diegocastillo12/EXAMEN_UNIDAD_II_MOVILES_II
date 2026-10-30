import assert from 'node:assert/strict';
import {test} from 'node:test';
import {moderationFixture,moderator,reportId} from './moderation_fixture.mjs';
test('Production moderation authorizes each API, protects cookie/CSRF, audits evidence and replays an ambiguous decision',async t=>{
 const server=await moderationFixture();t.after(server.close);
 const ssr=await fetch(server.origin+'/moderacion');const html=await ssr.text();assert.equal(ssr.status,200);assert.doesNotMatch(html,/PRIVATE_REPORT_REASON|private-jwt|sb_publishable_fixture|session-secret/);assert.match(ssr.headers.get('x-robots-tag'),/noindex/);
 assert.equal((await fetch(server.origin+'/api/moderation/session')).status,401);
 assert.equal((await fetch(server.origin+'/api/moderation/login',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({email:'moderador@example.test',password:'test-fixture-password'})})).status,403);
 const post=(path,body,cookie='',actor=moderator)=>fetch(server.origin+'/api/moderation/'+path,{method:'POST',headers:{Origin:server.origin,'Content-Type':'application/json',Cookie:cookie,'X-Moderation-Actor':actor},body:JSON.stringify(body)});
 const denied=await post('login',{email:'ordinario@example.test',password:'test-fixture-password'});assert.equal(denied.status,403);assert.doesNotMatch(await denied.text(),/PRIVATE/);
 const login=await post('login',{email:'moderador@example.test',password:'test-fixture-password'});assert.equal(login.status,200);
 const setCookie=login.headers.getSetCookie().find(c=>c.startsWith('eh_moderation=')&&!c.startsWith('eh_moderation=;'));assert.ok(setCookie);assert.match(setCookie,/HttpOnly/);assert.match(setCookie,/SameSite=Strict/i);assert.doesNotMatch(setCookie,/mmmmmmmm/);
 const cookie=setCookie.split(';')[0];assert.equal((await login.json()).actor,moderator);
 const queue=await post('queue',{resolved:false,cursor:null},cookie);assert.equal(queue.status,200);assert.equal((await queue.json()).items.length,1);
 const get=path=>fetch(server.origin+'/api/moderation/'+path,{headers:{Cookie:cookie,'X-Moderation-Actor':moderator}});
 const detail=await get('reports/'+reportId);assert.equal(detail.status,200);assert.equal((await detail.json()).reason,'PRIVATE_REPORT_REASON');
 const photo=await get('reports/'+reportId+'/evidence');assert.equal(photo.status,200);assert.equal(photo.headers.get('content-type'),'image/jpeg');assert.match(photo.headers.get('cache-control'),/no-store/);
 const command={id:'55555555-5555-4555-8555-555555555545',report:reportId,reportVersion:0,resourceVersion:0,action:'hide',reason:'Motivo de revisión'};
 server.ambiguousDecision();assert.equal((await post('decisions',command,cookie)).status,503);const retried=await post('decisions',command,cookie);assert.equal(retried.status,200);assert.equal((await retried.json()).hidden,true);assert.equal(server.decisions(),1);
 assert.equal((await post('queue',{resolved:false,cursor:null},cookie,'other')).status,401);
 server.revoke(true);assert.equal((await get('reports/'+reportId)).status,403);assert.equal((await get('reports/'+reportId+'/evidence')).status,403);
 for(const action of ['queue','detail','evidence','decision'])assert.ok(server.accesses().includes(action));
 assert.equal((await post('logout',{},cookie)).status,200);
});


test('An anonymous session check returns 401 without backend configuration; login still fails closed',async t=>{
 const {productionFixture}=await import('./server_fixture.mjs');
 const server=await productionFixture(undefined,{env:{SUPABASE_PUBLISHABLE_KEY:'',MODERATION_SESSION_SECRET:''}});t.after(server.close);
 const response=await fetch(server.origin+'/api/moderation/session');assert.equal(response.status,401);assert.deepEqual(await response.json(),{error:'unauthenticated'});
 const supplied=await fetch(server.origin+'/api/moderation/session',{headers:{Cookie:'eh_moderation=untrusted'}});assert.equal(supplied.status,503);
 const login=await fetch(server.origin+'/api/moderation/login',{method:'POST',headers:{Origin:server.origin,'Content-Type':'application/json'},body:JSON.stringify({email:'reviewer@example.test',password:'test-only-password'})});assert.equal(login.status,503);assert.deepEqual(await login.json(),{error:'unavailable'});
});


test('Google and Facebook PKCE callback protect state, replay, origin and reviewer permissions',async t=>{
 const server=await moderationFixture();t.after(server.close);
 const start=provider=>fetch(server.origin+'/api/moderation/oauth/start',{method:'POST',headers:{Origin:server.origin,'Content-Type':'application/json'},body:JSON.stringify({provider})});
 const denied=await fetch(server.origin+'/api/moderation/oauth/start',{method:'POST',headers:{Origin:'https://untrusted.example','Content-Type':'application/json'},body:'{"provider":"google"}'});assert.equal(denied.status,403);
 assert.equal((await start('apple')).status,422);
 const exchange=async provider=>{
  const begin=await start(provider);assert.equal(begin.status,200);const header=begin.headers.getSetCookie().find(c=>c.startsWith('eh_oauth='));assert.match(header,/HttpOnly/);assert.match(header,/SameSite=Lax/i);assert.match(header,/Path=\/api\/moderation\/oauth/);
  const {url}=await begin.json();assert.equal(new URL(url).searchParams.get('provider'),provider);
  const redirect=await fetch(url,{redirect:'manual'});return{callback:redirect.headers.get('location'),cookie:header.split(';')[0]};
 };
 for(const provider of ['google','facebook']){
  const {callback,cookie}=await exchange(provider);
  const noCookie=await fetch(callback,{redirect:'manual',headers:{'Sec-Fetch-Site':'cross-site'}});assert.equal(noCookie.headers.get('location'),'/iniciar-sesion?reason=oauth-failed');
  const wrong=new URL(callback);wrong.searchParams.set('flow','x'.repeat(43));const forged=await fetch(wrong,{redirect:'manual',headers:{Cookie:cookie}});assert.equal(forged.headers.get('location'),'/iniciar-sesion?reason=oauth-failed');
  const result=await fetch(callback,{redirect:'manual',headers:{Cookie:cookie,'Sec-Fetch-Site':'cross-site'}});assert.equal(result.status,303);assert.equal(result.headers.get('location'),'/inicio');const session=result.headers.getSetCookie().find(c=>c.startsWith('eh_access=')&&!c.startsWith('eh_access=;'));assert.match(session,/HttpOnly/);assert.match(session,/SameSite=Strict/i);assert.doesNotMatch(session,/mmmmmmmm/);
  const check=await fetch(server.origin+'/api/moderation/session',{headers:{Cookie:session.split(';')[0]}});assert.equal(check.status,200);
  const replay=await fetch(callback,{redirect:'manual',headers:{Cookie:cookie}});assert.equal(replay.headers.get('location'),'/iniciar-sesion?reason=oauth-failed');
 }
 server.oauthDenied(true);let flow=await exchange('google');const forbidden=await fetch(flow.callback,{redirect:'manual',headers:{Cookie:flow.cookie}});assert.equal(forbidden.headers.get('location'),'/inicio');const ordinaryCookie=forbidden.headers.getSetCookie().find(c=>c.startsWith('eh_access=')&&!c.startsWith('eh_access=;')).split(';')[0];assert.equal((await fetch(server.origin+'/api/moderation/session',{headers:{Cookie:ordinaryCookie}})).status,403);assert.equal((await fetch(server.origin+'/api/access/session',{headers:{Cookie:ordinaryCookie}})).status,200);
 server.oauthDenied(false);server.oauthCancelled(true);flow=await exchange('facebook');const cancel=await fetch(flow.callback,{redirect:'manual',headers:{Cookie:flow.cookie}});assert.equal(cancel.headers.get('location'),'/iniciar-sesion?reason=oauth-cancelled');
 assert.equal((await fetch(server.origin+'/api/moderation/session',{headers:{'Sec-Fetch-Site':'cross-site'}})).status,403);
});
