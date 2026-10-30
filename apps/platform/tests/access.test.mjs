import assert from 'node:assert/strict';
import { test } from 'node:test';
import { AccessAccount, AccessFailure, CompleteAccountOnboarding, ReadManagementAccess, StartAccountSocialSignIn, CompleteAccountSocialSignIn } from '../shared/features/access/domain/access.ts';
import { AccountViewModel } from '../shared/features/access/presentation/account_view_model.ts';
import { HttpAccountRepository } from '../shared/features/access/data/http_account_repository.ts';
import { AccountSessionTransport } from '../shared/features/access/data/account_session_transport.ts';
import { accountSessionDto } from '../shared/features/access/data/account_session_dto.ts';
import { AccountSource } from '../server/features/access/data/account_source.ts';
import { ServerAccountRepository } from '../server/features/access/data/server_account_repository.ts';
import { sealAccountSession, openAccountSession } from '../server/infrastructure/account_session.ts';
import { openSession } from '../server/infrastructure/moderation_session.ts';
const actor = '11111111-1111-4111-8111-111111111145', other = '22222222-2222-4222-8222-222222222245';
const session = () => ({ actor, expiresAt: Date.now() + 60000, email: 'user@example.test', profile: { displayName: 'Luna', city: 'Lima', onboardingCompleted: false } });
const vm = repo => new AccountViewModel(new AccessAccount(repo), new StartAccountSocialSignIn(repo), new CompleteAccountOnboarding(repo), new ReadManagementAccess(repo));

test('Prepared account mounts without a loading reset, binds writes and disappears on invalidation or TTL', async () => {
 let now = Date.now(), calls = [];
 const transport = new AccountSessionTransport(async (path, init) => {
  calls.push({ path, init });
  return Response.json(path.endsWith('management') ? { canReviewReports: false } : session());
 }, () => now);
 assert.equal(transport.preparedSession(), null);
 await transport.fetch('/api/access/session');
 const prepared = transport.preparedSession();
 const repository = new HttpAccountRepository(transport.fetch, prepared.actor);
 const model = new AccountViewModel(new AccessAccount(repository), new StartAccountSocialSignIn(repository), new CompleteAccountOnboarding(repository), new ReadManagementAccess(repository), prepared);
 assert.equal(model.state.checking, false); assert.equal(model.state.session.actor, actor);
 await model.loadManagementAccess();
 assert.equal(calls.length, 2); assert.equal(calls[1].init.headers['X-Account-Actor'], actor);
 now += 15001; assert.equal(transport.preparedSession(), null);
 await transport.fetch('/api/access/session'); assert.ok(transport.preparedSession());
 transport.invalidate(); assert.equal(transport.preparedSession(), null);
 model.invalidate(); assert.equal(model.state.session, null); model.dispose();
});

test('Parallel profile reads cannot expose a result before remote identity validation', async () => {
 let finishIdentity, profileReads = 0;
 const source = { user: () => new Promise(resolve => { finishIdentity = resolve; }), profile: async () => {
  profileReads++; return [{ id: actor, display_name: null, city: null, onboarding_completed_at: null }];
 } };
 const repository = new ServerAccountRepository(source, { actor, token: 'private-test-token', expiresAt: Date.now() + 60000 });
 let returned = false;
 const pending = repository.session().then(value => { returned = true; return value; });
 await Promise.resolve(); assert.equal(profileReads, 1); assert.equal(returned, false);
 finishIdentity({ id: other }); await assert.rejects(pending, /unauthenticated/);
 assert.equal(returned, false);
});

test('Prepared session transport deduplicates reads, bounds reuse by TTL/token expiry and never caches permissions or failures', async () => {
 let now = Date.now(), calls = 0, status = 200;
 const transport = new AccountSessionTransport(async () => { calls++; return new Response(JSON.stringify({ ...session(), expiresAt: now + 60000 }), { status }); }, () => now);
 const a = new HttpAccountRepository(transport.fetch), b = new HttpAccountRepository(transport.fetch);
 await Promise.all([a.session(), b.session()]); assert.equal(calls, 1);
 await b.session(); assert.equal(calls, 1);
 now += 15001; await a.session(); assert.equal(calls, 2);
 transport.invalidate(); status = 503;
 await assert.rejects(a.session()); await assert.rejects(b.session()); assert.equal(calls, 4);
 status = 401; await assert.rejects(a.session()); await assert.rejects(b.session()); assert.equal(calls, 5);
 now += 5001; await assert.rejects(a.session()); assert.equal(calls, 6);
 transport.invalidate(); status = 200;
 await a.session();
 await transport.fetch('/api/access/management'); await transport.fetch('/api/access/management');
 assert.equal(calls, 9, 'Permission checks are never reused');
 await transport.fetch('/api/moderation/logout', { method: 'POST' });
 await a.session(); assert.equal(calls, 11, 'Moderation logout invalidates the prepared account');
 let refreshed = false;
 // A stale success cannot survive the token deadline (a new read is required).
 const expiryTransport = new AccountSessionTransport(async () => { refreshed = true; return new Response(JSON.stringify({ ...session(), expiresAt: now + 100 })); }, () => now);
 await expiryTransport.fetch('/api/access/session'); refreshed = false; now += 101;
 await expiryTransport.fetch('/api/access/session'); assert.equal(refreshed, true);
});

test('Invalidation discards an in-flight identity response and each browser app owns its own preparation', async () => {
 let complete;
 const transport = new AccountSessionTransport(() => new Promise(resolve => { complete = resolve; }));
 const pending = transport.fetch('/api/access/session'); transport.invalidate();
 complete(new Response(JSON.stringify(session())));
 assert.equal((await pending).status, 409);
 let calls = 0;
 const otherApp = new AccountSessionTransport(async () => { calls++; return new Response('{}', { status: 401 }); });
 await otherApp.fetch('/api/access/session'); assert.equal(calls, 1);
});

test('An identity write discards session reads started before or during the mutation', async () => {
 let finishWrite, finishRead;
 const transport = new AccountSessionTransport(async (input) => {
  if (String(input).endsWith('/login')) return new Promise(resolve => { finishWrite = resolve; });
  return new Promise(resolve => { finishRead = resolve; });
 });
 const login = transport.fetch('/api/access/login', { method: 'POST' });
 const oldRead = transport.fetch('/api/access/session');
 finishWrite(new Response('{}')); await login;
 finishRead(new Response(JSON.stringify(session())));
 assert.equal((await oldRead).status, 409);
});
test('General login validates credentials without requiring reviewer permission; DTO drops external roles and private fields', async () => {
 let calls = 0;
 const access = new AccessAccount({ login: async () => { calls++; return session(); } });
 assert.throws(() => access.login('bad', ''), /invalid/);
 assert.equal((await access.login(' user@example.test ', 'password')).actor, actor);
 assert.equal(calls, 1);
 const dto = accountSessionDto({ ...session(), access_token: 'PRIVATE', roles: ['admin'], profile: { ...session().profile, private: 'PRIVATE' } });
 assert.doesNotMatch(JSON.stringify(dto), /PRIVATE|admin/);
 assert.throws(() => accountSessionDto({ ...session(), profile: { city: null } }), /unavailable/);
 assert.throws(() => new CompleteAccountSocialSignIn({}).execute('', 'short'), /unauthenticated/);
});
test('Account cookies authenticate ciphertext, expiry and namespace; moderation cookies cannot be forged by reusing ciphertext', () => {
 const secret = 's'.repeat(48), data = { actor, token: 'private-jwt', expiresAt: Date.now() + 60000 };
 const sealed = sealAccountSession(data, secret);
 assert.deepEqual(openAccountSession(sealed, secret), data);
 assert.equal(openAccountSession(sealed, 'other'), null);
 assert.equal(openAccountSession(sealed.slice(0, -8) + 'tampered', secret), null);
 assert.equal(openSession(sealed, secret), null);
 assert.equal(openAccountSession(sealAccountSession({ ...data, expiresAt: Date.now() - 1 }, secret), secret), null);
});
test('Server reads only own profile, rejects anonymous/changed identity, and never checks reviewer role to establish general access', async () => {
 const calls = []; let user = actor, row = actor, anonymous = false;
 const source = new AccountSource({ url: 'https://backend.test', key: 'sb_publishable_test', sessionSecret: '', secure: true }, async (url, init) => {
  calls.push({ url, init });
  if (url.includes('/auth/v1/token')) return Response.json({ access_token: 'jwt', expires_in: 3600, user: { id: actor } });
  if (url.endsWith('/auth/v1/user')) return Response.json({ id: user, email: 'user@example.test', is_anonymous: anonymous, user_metadata: { role: 'admin' } });
  return Response.json([{ id: row, display_name: null, city: null, onboarding_completed_at: null }]);
 });
 const repo = new ServerAccountRepository(source, null);
 assert.equal((await repo.login('user@example.test', 'password')).profile.onboardingCompleted, false);
 assert.ok(calls.some(c => c.url.includes('id=eq.' + actor)));
 assert.ok(calls.every(c => !c.url.includes('require_content_reviewer')));
 row = other; await assert.rejects(() => repo.session(), /unavailable/);
 row = actor; user = other; await assert.rejects(() => repo.session(), /unauthenticated/);
 user = actor; anonymous = true; await assert.rejects(() => repo.session(), /unauthenticated/);
});
test('Onboarding retries retain the third step, block double submission, and reject late completion after account changes', async () => {
 let complete, attempts = 0, fail = true;
 const repo = { session: async () => session(), completeOnboarding: async () => { attempts++; if (fail) throw new AccessFailure('unavailable'); return new Promise(r => { complete = r; }); } };
 const model = vm(repo); await model.checkSession();
 await model.nextStep(); await model.nextStep(); await model.nextStep();
 assert.equal(model.state.step, 2); assert.ok(model.state.session); assert.equal(model.state.failure.kind, 'unavailable');
 fail = false; const pending = model.nextStep(); await model.nextStep(); assert.equal(attempts, 2);
 model.invalidate(); complete({ ...session(), profile: { ...session().profile, onboardingCompleted: true } }); await pending;
 assert.equal(model.state.session, null); assert.equal(model.state.step, 0); model.dispose();
});
test('Management lookup distinguishes lack of role from a connection failure without discarding the user account', async () => {
 let fail = false;
 const model = vm({ session: async () => session(), canReviewReports: async () => { if (fail) throw new AccessFailure('unavailable'); return false; } });
 await model.checkSession(); await model.loadManagementAccess();
 assert.equal(model.state.canReview, false); assert.ok(model.state.session);
 fail = true; await model.loadManagementAccess();
 assert.equal(model.state.canReview, null); assert.equal(model.state.managementFailed, true); assert.ok(model.state.session);
 model.dispose();
});

test('Management retry keeps its action busy, deduplicates requests and clears the failure only after confirmation', async () => {
 let finish, calls = 0;
 const model = vm({ session: async () => session(), canReviewReports: () => {
  calls++; if (calls === 1) return Promise.reject(new AccessFailure('unavailable'));
  return new Promise(resolve => { finish = resolve; });
 } });
 await model.checkSession(); await model.loadManagementAccess();
 const retry = model.loadManagementAccess(); await model.loadManagementAccess();
 assert.equal(calls, 2); assert.equal(model.state.checkingManagement, true);
 assert.equal(model.state.managementFailed, true); assert.ok(model.state.session);
 finish(false); await retry;
 assert.equal(model.state.checkingManagement, false); assert.equal(model.state.managementFailed, false);
 assert.equal(model.state.canReview, false); model.dispose();
});
test('Access UI state recovers after errors and rejects late login/social/session responses after disposal or account invalidation', async () => {
 let complete, calls = 0;
 const model = vm({ session: async () => { throw new AccessFailure('unauthenticated'); }, login: () => new Promise(r => { complete = r; }), start: async () => { calls++; return 'https://auth.test/auth/v1/authorize'; } });
 await model.checkSession(); assert.equal(model.state.failure, null);
 const pending = model.login('user@example.test', 'password'); await model.login('user@example.test', 'password');
 model.invalidate(); complete(session()); await pending; assert.equal(model.state.session, null);
 await model.checkSession(); await model.signInWithProvider('google'); await model.signInWithProvider('google'); assert.equal(calls, 1);
 model.dispose();
 let resolve; const late = vm({ session: () => new Promise(r => { resolve = r; }) });
 const check = late.checkSession(); late.dispose(); resolve(session()); await check; assert.equal(late.state.session, null);
});
test('HTTP adapter binds onboarding and permission lookup to expected actor and rejects malformed social URLs', async () => {
 const calls = [];
 const repo = new HttpAccountRepository(async (path, init) => {
  calls.push({ path, init });
  if (path.endsWith('management')) return Response.json({ canReviewReports: false });
  if (path.endsWith('start')) return Response.json({ url: 'javascript:alert(1)' });
  return Response.json(session());
 });
 await repo.session(); await repo.completeOnboarding(); assert.equal(await repo.canReviewReports(), false);
 assert.equal(calls[1].init.headers['X-Account-Actor'], actor); assert.equal(calls[2].init.headers['X-Account-Actor'], actor);
 assert.equal(calls[1].init.credentials, 'same-origin');
 await assert.rejects(() => repo.start('google'), /unavailable/);
 for (const url of ['https://auth.test/other', 'https://auth.test/auth/v1/authorize?provider=facebook']) {
  await assert.rejects(() => new HttpAccountRepository(async () => Response.json({ url })).start('google'), /unavailable/);
 }
});
test('Social starts can retry failures and discard a provider redirect received after leaving the screen', async () => {
 let complete, fail = true;
 const model = vm({ session: async () => { throw new AccessFailure('unauthenticated'); }, start: async () => {
  if (fail) throw new AccessFailure('unavailable');
  return new Promise(resolve => { complete = resolve; });
 } });
 await model.checkSession(); assert.equal(await model.signInWithProvider('facebook'), null); assert.equal(model.state.busy, false);
 fail = false; const pending = model.signInWithProvider('facebook'); await Promise.resolve(); model.dispose();
 complete('https://auth.test/auth/v1/authorize?provider=facebook'); assert.equal(await pending, null);
});
test('A logout response received after disposal cannot trigger navigation or overwrite a newer identity', async () => {
 let complete;
 const model = vm({ session: async () => session(), logout: () => new Promise(resolve => { complete = resolve; }) });
 await model.checkSession(); const pending = model.logout(); model.dispose(); complete();
 assert.equal(await pending, false); assert.equal(model.state.session, null);
});
test('A void onboarding RPC accepts HTTP 204 and confirms completion by reading the actual account profile', async () => {
 let completed = false; const calls = [];
 const source = new AccountSource({ url: 'https://backend.test', key: 'publishable', sessionSecret: '', secure: true }, async url => {
  calls.push(url);
  if (url.endsWith('/complete_onboarding')) { completed = true; return new Response(null, { status: 204 }); }
  if (url.endsWith('/auth/v1/user')) return Response.json({ id: actor, email: 'user@example.test' });
  return Response.json([{ id: actor, display_name: 'Luna', city: 'Lima', onboarding_completed_at: completed ? '2026-10-19T12:00:00Z' : null }]);
 });
 const repository = new ServerAccountRepository(source, { actor, token: 'test-only-jwt', expiresAt: Date.now() + 60000 });
 const result = await repository.completeOnboarding();
 assert.equal(result.profile.onboardingCompleted, true);
 assert.ok(calls.findIndex(url => url.includes('/profiles?')) > calls.findIndex(url => url.endsWith('/complete_onboarding')));
});
test('An empty response is only valid for the void RPC; JSON endpoints and denied requests still fail', async () => {
 const config = { url: 'https://backend.test', key: 'publishable', sessionSecret: '', secure: true };
 const empty = new AccountSource(config, async () => new Response(null, { status: 204 }));
 await assert.rejects(() => empty.user('test-only-jwt'), /unavailable/);
 for (const [status, kind] of [[401, 'unauthenticated'], [403, 'forbidden'], [503, 'unavailable']]) {
  const source = new AccountSource(config, async () => new Response(null, { status }));
  await assert.rejects(() => source.completeOnboarding('test-only-jwt'), error => error.kind === kind);
 }
});

