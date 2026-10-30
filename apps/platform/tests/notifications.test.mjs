import assert from 'node:assert/strict';
import { test } from 'node:test';
import { ReadInbox,MarkNotificationRead,InboxFailure } from '../shared/features/notifications/domain/inbox.ts';
import { InboxViewModel } from '../shared/features/notifications/presentation/inbox_view_model.ts';
import { HttpInboxRepository } from '../shared/features/notifications/data/http_inbox_repository.ts';
import { ServerInboxRepository } from '../server/features/notifications/data/server_inbox_repository.ts';
import { InboxSource } from '../server/features/notifications/data/inbox_source.ts';
import { AccountSource } from '../server/features/access/data/account_source.ts';
import { ServerAccountRepository } from '../server/features/access/data/server_account_repository.ts';
import { ReadAccountAvatar } from '../shared/features/access/domain/account_avatar.ts';
const item={id:'9007199254740993',title:'Novedad',createdAt:'2026-10-21T12:00:00Z',read:false};
const deferred=()=>{let resolve;const promise=new Promise(r=>{resolve=r;});return{promise,resolve};};
test('Notification identifiers preserve bigint precision and reject invalid cursors before repository access',async()=>{
  const calls=[],read=new ReadInbox({list:async cursor=>{calls.push(cursor);return{items:[],cursor:null};}});
  await read.execute(item.id);assert.deepEqual(calls,[item.id]);
  for(const invalid of ['0','-1','1.5',123,'9223372036854775808','1 OR TRUE'])assert.throws(()=>read.execute(invalid),e=>e.kind==='invalid');
});
test('Inbox deduplicates reads and writes, preserves content on refresh failure, and confirms read only after server acknowledgement',async()=>{
  const gate=deferred(),mark=deferred();let reads=0,writes=0,fail=false;
  const repo={list:async()=>{reads++;if(fail)throw new InboxFailure('unavailable');return gate.promise;},markRead:async()=>{writes++;await mark.promise;}};
  const model=new InboxViewModel(new ReadInbox(repo),new MarkNotificationRead(repo));
  const first=model.load();await model.load();assert.equal(reads,1);gate.resolve({items:[item],cursor:null});await first;
  const writing=model.markRead(item.id);await model.markRead(item.id);assert.equal(writes,1);assert.equal(model.state.items[0].read,false);mark.resolve();await writing;assert.equal(model.state.items[0].read,true);
  fail=true;await model.load();assert.equal(model.state.items.length,1);assert.equal(model.state.failure.kind,'unavailable');assert.equal(model.state.loaded,true);
});
test('Pagination failure retains cursor and items; disposal prevents late notification data from returning to another account',async()=>{
  let calls=0;const late=deferred();
  const repo={list:async()=>{calls++;if(calls===1)return{items:[item],cursor:'42'};if(calls===2)throw new InboxFailure('unavailable');return late.promise;},markRead:async()=>{}};
  const model=new InboxViewModel(new ReadInbox(repo),new MarkNotificationRead(repo));await model.load();await model.load(true);
  assert.equal(model.state.cursor,'42');assert.equal(model.state.items.length,1);
  const loading=model.load(true);model.dispose();late.resolve({items:[{...item,id:'41'}],cursor:null});await loading;assert.equal(model.state.items.length,0);
});
test('Expired or changed identity hides previously confirmed inbox data',async()=>{
  let failed=false;
  const repo={list:async()=>{if(failed)throw new InboxFailure('conflict');return{items:[item],cursor:null};},markRead:async()=>{}};
  const model=new InboxViewModel(new ReadInbox(repo),new MarkNotificationRead(repo));await model.load();failed=true;await model.load();
  assert.equal(model.state.items.length,0);assert.equal(model.state.loaded,false);assert.equal(model.state.failure.kind,'conflict');
});
test('Server and HTTP repositories bind user credentials, drop private notification fields, and keep upstream failures safe',async()=>{
  const calls=[],repo=new ServerInboxRepository(new InboxSource({url:'https://backend.test',key:'publishable'},'private-token',async(url,init)=>{
    calls.push({url,init});return Response.json({items:[{id:item.id,title:item.title,created_at:item.createdAt,read_at:null,owner_id:'PRIVATE'}],next:null});
  }));
  assert.deepEqual(await repo.list(null),{items:[item],cursor:null});assert.equal(calls[0].init.headers.Authorization,'Bearer private-token');assert.deepEqual(JSON.parse(calls[0].init.body),{p_before:null});
  let request;const http=new HttpInboxRepository('actor',async(url,init)=>{request={url,init};return Response.json({items:[item],cursor:null});});
  await http.list(item.id);assert.equal(request.init.headers['X-Account-Actor'],'actor');assert.equal(request.init.credentials,'same-origin');assert.ok(request.url.endsWith(item.id));
  const bad=new HttpInboxRepository('actor',async()=>new Response('PRIVATE_ERROR',{status:503}));await assert.rejects(bad.list(null),e=>e.message==='unavailable');
});
test('Avatar reads validate current identity and constrain the path to its private account; optional missing images preserve fallback',async()=>{
  const actor='22222222-2222-4222-8222-222222222245',calls=[];
  const source=new AccountSource({url:'https://backend.test',key:'public',sessionSecret:'test',secure:true},async(url,init)=>{
    calls.push({url,init});return url.endsWith('/auth/v1/user')?Response.json({id:actor}):new Response('',{status:404});
  });
  const repo=new ServerAccountRepository(source,{actor,token:'private',expiresAt:Date.now()+60000});
  assert.equal(await new ReadAccountAvatar(repo).execute(),null);assert.ok(calls.at(-1).url.endsWith('/profile-avatars/'+actor+'/avatar.jpg'));
  const revoked=new ServerAccountRepository({user:async()=>({id:'another'}),avatar:async()=>{throw Error('must not read');}},{actor,token:'private',expiresAt:Date.now()+60000});
  await assert.rejects(new ReadAccountAvatar(revoked).execute(),e=>e.kind==='unauthenticated');
});
