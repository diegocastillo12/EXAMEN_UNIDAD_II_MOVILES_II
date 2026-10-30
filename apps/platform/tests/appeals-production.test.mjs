import assert from 'node:assert/strict';
import {test} from 'node:test';
import {appealsFixture,decision} from './appeals_fixture.mjs';
import {ordinary,moderator} from './moderation_fixture.mjs';
test('HU14.4 production protects SSR, account binding, CSRF, review permissions and ambiguous retries',async t=>{
 const s=await appealsFixture();t.after(s.close);
 const login=async email=>{
  const response=await fetch(s.origin+'/api/access/login',{method:'POST',headers:{Origin:s.origin,'Content-Type':'application/json'},body:JSON.stringify({email,password:'test-fixture-password'})});assert.equal(response.status,200);
  return response.headers.getSetCookie().find(c=>c.startsWith('eh_access=')&&!c.startsWith('eh_access=;')).split(';')[0];
 };
 const post=(operation,body,cookie='',actor=ordinary,origin=s.origin)=>fetch(s.origin+'/api/appeals/'+operation,{method:'POST',headers:{Origin:origin,'Content-Type':'application/json',Cookie:cookie,'X-Account-Actor':actor},body:JSON.stringify(body)});
 const html=await fetch(s.origin+'/apelaciones').then(r=>r.text());assert.doesNotMatch(html,/La publicación necesita revisión|private-jwt/);
 assert.equal((await post('list',{review:false,cursor:null})).status,401);
 const cookie=await login('ordinario@example.test');
 assert.equal((await post('list',{review:false,cursor:null},cookie,ordinary,'https://elsewhere.test')).status,403);
 assert.equal((await post('list',{review:false,cursor:null},cookie,moderator)).status,409);
 assert.equal((await post('list',{review:false,cursor:null},cookie)).status,200);
 assert.equal((await post('list',{review:true,cursor:null},cookie)).status,403);
 assert.equal((await post('submit',{id:'bad',target:decision,reason:'Motivo'},cookie)).status,422);
 const command={id:'cccccccc-cccc-4ccc-8ccc-000000000009',target:decision,reason:'Revisar esta publicación'};
 s.ambiguousAppeal();assert.equal((await post('submit',command,cookie)).status,503);const replay=await post('submit',command,cookie);assert.equal(replay.status,200);assert.equal(s.submissions(),1);assert.equal((await replay.json()).appeal.id,command.id);
 assert.equal((await post('answer',{...command,target:command.id},cookie)).status,403);
 const reviewerCookie=await login('moderador@example.test');const response={id:'cccccccc-cccc-4ccc-8ccc-000000000010',target:command.id,reason:'Revisada y respondida'};
 assert.equal((await post('answer',response,reviewerCookie,moderator)).status,200);assert.equal(s.answers(),1);
 const own=await post('list',{review:false,cursor:null},cookie);assert.equal((await own.json()).items[0].appeal.answer.reason,response.reason);
 s.revokeAppeals(true);assert.equal((await post('answer',response,reviewerCookie,moderator)).status,403);
 assert.equal((await post('list',{review:true,cursor:null},reviewerCookie,moderator)).status,403);
});
