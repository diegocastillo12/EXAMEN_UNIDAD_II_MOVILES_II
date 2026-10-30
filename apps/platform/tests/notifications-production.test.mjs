import assert from 'node:assert/strict';
import { test } from 'node:test';
import { inboxFixture } from './inbox_fixture.mjs';
import { ordinary,moderator } from './moderation_fixture.mjs';
test('Private inbox/avatar APIs enforce session, account binding, origin, current onboarding and per-owner RPC permissions',async t=>{
  const s=await inboxFixture();t.after(s.close);
  assert.equal((await fetch(s.origin+'/api/notifications/inbox')).status,401);
  assert.equal((await fetch(s.origin+'/api/access/avatar?actor='+ordinary)).status,401);
  const login=async email=>{
    const r=await fetch(s.origin+'/api/access/login',{method:'POST',headers:{Origin:s.origin,'Content-Type':'application/json'},body:JSON.stringify({email,password:'test-fixture-password'})});
    assert.equal(r.status,200);return r.headers.getSetCookie().find(value=>value.startsWith('eh_access=')&&!value.startsWith('eh_access=;')).split(';')[0];
  };
  const cookie=await login('ordinario@example.test'),headers={Cookie:cookie,'X-Account-Actor':ordinary};
  const response=await fetch(s.origin+'/api/notifications/inbox',{headers}),page=await response.json();assert.equal(response.status,200);
  assert.equal(page.items[0].id,'9007199254740993');assert.equal(page.cursor,'9007199254740992');assert.equal(JSON.stringify(page).includes('PRIVATE'),false);
  assert.equal((await fetch(s.origin+'/api/notifications/inbox',{headers:{...headers,'X-Account-Actor':moderator}})).status,409);
  assert.equal((await fetch(s.origin+'/api/notifications/inbox?before=0',{headers})).status,422);
  assert.equal((await fetch(s.origin+'/api/notifications/inbox',{headers:{...headers,'Sec-Fetch-Site':'cross-site'}})).status,403);
  const mark=(id,origin=s.origin,c= cookie,actor=ordinary)=>fetch(s.origin+'/api/notifications/read',{method:'POST',headers:{Cookie:c,'X-Account-Actor':actor,Origin:origin,'Content-Type':'application/json'},body:JSON.stringify({id})});
  assert.equal((await mark(page.items[0].id,'https://untrusted.test')).status,403);
  assert.equal((await mark(page.items[0].id)).status,200);assert.equal((await mark(page.items[0].id)).status,200);
  const refreshed=await (await fetch(s.origin+'/api/notifications/inbox',{headers})).json();assert.equal(refreshed.items[0].read,true);
  const other=await login('moderador@example.test');assert.equal((await mark(page.items[0].id,s.origin,other,moderator)).status,403);
  assert.equal((await fetch(s.origin+'/api/access/avatar?actor='+moderator,{headers})).status,403);
  const photo=await fetch(s.origin+'/api/access/avatar?actor='+ordinary,{headers});assert.equal(photo.status,200);assert.equal(photo.headers.get('content-type'),'image/jpeg');assert.match(photo.headers.get('cache-control'),/no-store/);
  s.avatar(false);assert.equal((await fetch(s.origin+'/api/access/avatar?actor='+ordinary,{headers})).status,204);
  s.failList(true);const failed=await fetch(s.origin+'/api/notifications/inbox',{headers});assert.equal(failed.status,503);assert.deepEqual(await failed.json(),{error:'unavailable'});
  s.setOnboarding(ordinary,false);assert.equal((await fetch(s.origin+'/api/notifications/inbox',{headers})).status,403);
});
