import assert from 'node:assert/strict';
import { test } from 'node:test';
import { recoveryFixture,petId,photoId,caseId } from './recovery_fixture.mjs';
import { ordinary } from './moderation_fixture.mjs';
test('Recovery routes require account/onboarding; APIs bind actor and origin, sanitize projections, and retry reports without duplicating',async()=>{
 const server=await recoveryFixture();
 try{
  for(const path of ['/explorar','/mis-mascotas','/reportar']){const response=await fetch(server.origin+path,{redirect:'manual'});assert.equal(response.status,302);assert.match(response.headers.get('location'),/api\/access\/entry/);assert.doesNotMatch(await response.text(),/user-navigation|recovery-screen/);}
  assert.equal((await fetch(server.origin+'/api/recovery/pets')).status,401);
  const login=await fetch(server.origin+'/api/access/login',{method:'POST',headers:{origin:server.origin,'Content-Type':'application/json'},body:JSON.stringify({email:'ordinario@example.test',password:'test-fixture-password'})});assert.equal(login.status,200);
  const cookies=login.headers.getSetCookie().find(c=>c.startsWith('eh_access=')&&!c.startsWith('eh_access=;')).split(';')[0], headers={cookie:cookies,origin:server.origin,'X-Account-Actor':ordinary,'Content-Type':'application/json'};
  const call=(path,body,h=headers)=>fetch(server.origin+'/api/recovery/'+path,{method:body===undefined?'GET':'POST',headers:h,...(body===undefined?{}:{body:JSON.stringify(body)})});
  assert.equal((await call('pets',undefined,{cookie:cookies})).status,409);
  assert.equal((await call('explore',{query:{kind:'all',species:'all',status:'active'}},{...headers,origin:'https://untrusted.test'})).status,403);
  const page=await (await call('explore',{query:{kind:'all',species:'all',status:'active'}})).json();assert.equal(page.items[0].id,caseId);assert.doesNotMatch(JSON.stringify(page),/PRIVATE_|owner_id|place_reference|contact_phone|cover_path/);
  const pets=await (await call('pets')).json();assert.equal(pets[0].name,'Luna');assert.doesNotMatch(JSON.stringify(pets),/owner_id|processed_at/);
  const report={id:'99999999-9999-4999-8999-999999999999',kind:'own_loss',petId,petVersion:1,targetId:null,communityTarget:false,occurredAt:'2026-10-19T12:00:00.000Z',latitude:-12.046,longitude:-77.042,place:'Referencia privada',species:'',speciesDetail:'',size:'',sex:'',traits:'',photoIds:[photoId]};
  const publish=async value=>{const body=new FormData();body.set('draft',JSON.stringify(value));return fetch(server.origin+'/api/recovery/reports',{method:'POST',headers:{cookie:cookies,origin:server.origin,'X-Account-Actor':ordinary},body});};
  assert.equal((await publish({...report,latitude:91})).status,422);assert.equal(server.reports.size,0);
  server.ambiguous();assert.equal((await publish(report)).status,503);assert.equal(server.reports.size,1);assert.equal((await publish(report)).status,200);assert.equal(server.reports.size,1);
  const image=await fetch(server.origin+`/api/recovery/photo?source=lost&id=${caseId}`,{headers:{cookie:cookies}});assert.equal(image.status,200);assert.equal(image.headers.get('content-type'),'image/jpeg');
  assert.equal((await fetch(server.origin+`/api/recovery/photo?source=lost&id=${petId}`,{headers:{cookie:cookies}})).status,403);
  server.setOnboarding(ordinary,false);assert.equal((await call('pets')).status,403);
 }finally{await server.close();}
});
