import assert from'node:assert/strict';
import{test}from'node:test';
import{matchingFixture,lost,found}from'./matching_fixture.mjs';
import{ordinary}from'./moderation_fixture.mjs';
test('missing native image runtime preserves search listing and authentication, with a retryable comparison failure',async t=>{
 const server=await matchingFixture({uncached:true,env:{NODE_OPTIONS:'--import='+new URL('./unavailable_native_images.mjs',import.meta.url).href}});t.after(server.close);
 const call=(operation,token='o',body={})=>fetch(server.origin+'/api/app/matching/'+operation,{method:'POST',headers:{Authorization:'Bearer '+token.repeat(30),'Content-Type':'application/json'},body:JSON.stringify(body)});
 assert.equal((await call('searches','x')).status,401);
 const listed=await call('searches');assert.equal(listed.status,200);assert.equal((await listed.json())[0].ref.id,lost);
 const comparison=await call('search','o',{source:'lost',id:lost});assert.equal(comparison.status,503);assert.deepEqual(await comparison.json(),{error:'unavailable'});
 assert.equal(server.indexed.size,0);
 assert.equal((await call('searches')).status,200);
});
test('matching built server enforces global SSR access, cookie actor binding, CSRF and strips server-only representations',async t=>{
 const server=await matchingFixture();t.after(server.close);
 const page=await fetch(server.origin+'/coincidencias',{redirect:'manual'});assert.equal(page.status,302);assert.match(page.headers.get('location'),/access\/entry/);
 const login=await fetch(server.origin+'/api/access/login',{method:'POST',headers:{origin:server.origin,'Content-Type':'application/json'},body:JSON.stringify({email:'ordinario@example.test',password:'test-fixture-password'})});assert.equal(login.status,200);
 const cookie=login.headers.getSetCookie().find(c=>c.startsWith('eh_access=')&&!c.startsWith('eh_access=;')).split(';')[0];
 const call=(path,body,headers={})=>fetch(server.origin+'/api/matching/'+path,{method:'POST',headers:{origin:server.origin,'Content-Type':'application/json',cookie,'X-Account-Actor':ordinary,...headers},body:JSON.stringify(body)});
 assert.equal((await call('search',{source:'lost',id:lost},{'X-Account-Actor':found})).status,409);
 assert.equal((await call('search',{source:'lost',id:lost},{origin:'https://attacker.test'})).status,403);
 const searches=await call('searches',{});assert.equal(searches.status,200);assert.equal((await searches.json())[0].ref.id,lost);
 const response=await call('search',{source:'lost',id:lost,p_actor:found});assert.equal(response.status,200);const value=await response.json();assert.equal(value.candidates.length,1);assert.doesNotMatch(JSON.stringify(value),/owner|embedding|photos|path|PRIVATE|score/);
 const review={id:'a0000000-0000-4000-8000-000000000074',anchor:value.anchor,anchorRevision:value.revision,candidate:value.candidates[0].ref,candidateRevision:value.candidates[0].revision,decision:'confirmed',model:value.model};
 assert.deepEqual(await(await call('review',review)).json(),{saved:true});
 const html=await fetch(server.origin+'/coincidencias',{headers:{cookie}}).then(r=>r.text());assert.match(html,/Posibles coincidencias/);assert.doesNotMatch(html,/PRIVATE|embedding|private-jwt/);
 server.revoke(true);assert.equal((await call('search',{source:'lost',id:lost})).status,403);
});
test('matching native endpoint verifies bearer identity, rejects origins and does not accept browser cookies as native authorization',async t=>{
 const server=await matchingFixture();t.after(server.close);
 const call=(authorization,origin)=>fetch(server.origin+'/api/app/matching/search',{method:'POST',headers:{'Content-Type':'application/json',...(authorization?{Authorization:authorization}:{}),...(origin?{Origin:origin}:{})},body:JSON.stringify({source:'lost',id:lost})});
 assert.equal((await call()).status,403);assert.equal((await call('Bearer '+'x'.repeat(30))).status,401);
 assert.equal((await call('Bearer '+'o'.repeat(30),'https://attacker.test')).status,403);
 const response=await call('Bearer '+'o'.repeat(30));assert.equal(response.status,200);assert.equal((await response.json()).anchor.id,lost);
 server.fail(true);const failure=await call('Bearer '+'o'.repeat(30));assert.equal(failure.status,503);assert.doesNotMatch(await failure.text(),/PRIVATE/);
 server.fail(false);server.authFail(true);assert.equal((await call('Bearer '+'o'.repeat(30))).status,503);
});
