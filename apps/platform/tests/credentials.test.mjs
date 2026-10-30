import assert from 'node:assert/strict';
import { test } from 'node:test';
import { CredentialFailure, RegisterAccount, RequestPasswordRecovery, VerifyAccountCode, ResendAccountCode, ResetAccountPassword, ReadCredentialProgress, CancelCredentialFlow } from '../shared/features/access/domain/credentials.ts';
import { CredentialViewModel } from '../shared/features/access/presentation/credential_view_model.ts';
import { HttpCredentialRepository } from '../shared/features/access/data/http_credential_repository.ts';
import { CredentialSource } from '../server/features/access/data/credential_source.ts';
import { ServerCredentialRepository } from '../server/features/access/data/server_credential_repository.ts';
import { newCredentialFlow, sealCredentialFlow, openCredentialFlow } from '../server/infrastructure/credential_flow.ts';
import { openAccountSession, sealAccountSession } from '../server/infrastructure/account_session.ts';
import { credentialProgressDto } from '../shared/features/access/data/credential_dto.ts';
const secret = 'test-fixture-credential-secret-long-enough', actor = '55555555-5555-4555-8555-555555555555';
const model = (repo, now = Date.now) => new CredentialViewModel(new RegisterAccount(repo), new RequestPasswordRecovery(repo), new VerifyAccountCode(repo), new ResendAccountCode(repo, now), new ResetAccountPassword(repo), new ReadCredentialProgress(repo), new CancelCredentialFlow(repo), now);
const progress = () => ({ ...newCredentialFlow('registration', 'user@example.test'), stage: 'code' });
test('Credential use cases validate names, email, password pairs, six-digit codes and resend limits before any request', async () => {
 let calls = 0; const repo = { register: async (...args) => { calls++; return args; }, requestRecovery: async () => { calls++; }, verify: async () => { calls++; }, reset: async () => { calls++; }, resend: async () => { calls++; } };
 const register = new RegisterAccount(repo), recovery = new RequestPasswordRecovery(repo), verify = new VerifyAccountCode(repo), reset = new ResetAccountPassword(repo);
 for (const args of [['', 'a@b.c', '12345678', '12345678'], ['name', 'bad', '12345678', '12345678'], ['name', 'a@b.c', 'short', 'short'], ['name', 'a@b.c', '12345678', 'different']]) assert.throws(() => register.execute(...args), CredentialFailure);
 assert.throws(() => recovery.execute('bad')); assert.throws(() => verify.execute('registration', 'a'.repeat(32), '12a456')); assert.throws(() => reset.execute('a'.repeat(32), '12345678', 'different'));
 assert.throws(() => new ResendAccountCode(repo).execute(progress()), /rate_limited/); assert.equal(calls, 0);
 assert.deepEqual(await register.execute(' Name ', ' a@b.c ', '12345678', '12345678'), ['Name', 'a@b.c', '12345678']);
});
test('Recovery cookies are encrypted, bounded, expiring and cannot be substituted for normal account cookies', () => {
 const flow = newCredentialFlow('recovery', 'a@b.c'); flow.recovery = { actor, token: 'PRIVATE_RECOVERY_TOKEN', expiresAt: Date.now() + 60000 };
 const sealed = sealCredentialFlow(flow, secret); assert.doesNotMatch(sealed, /PRIVATE|a@b.c/); assert.deepEqual(openCredentialFlow(sealed, secret), flow);
 assert.equal(openCredentialFlow(sealed, 'different-secret'), null); assert.equal(openCredentialFlow(sealed.slice(0, -4) + 'AAAA', secret), null);
 assert.equal(openCredentialFlow(sealCredentialFlow({ ...flow, expiresAt: Date.now() - 1 }, secret), secret), null);
 assert.equal(openAccountSession(sealed, secret), null); assert.equal(openCredentialFlow(sealAccountSession(flow.recovery, secret), secret), null);
 assert.deepEqual(Object.keys(credentialProgressDto({ ...flow, stage: 'reset', secret: 'DROP' })).sort(), ['email', 'expiresAt', 'id', 'kind', 'retryAt', 'stage']);
});
test('Credential source uses public Auth operations, bounded payloads and safe errors, including existing address privacy', async () => {
 const calls = [], config = { url: 'https://backend.example.test', key: 'sb_publishable_fixture', sessionSecret: secret, secure: true };
 const source = new CredentialSource(config, async (url, init) => { calls.push({ url, init }); return new Response(JSON.stringify({ access_token: 'private', user: { id: actor } })); });
 await source.register('Name', 'a@b.c', '12345678'); await source.recover('a@b.c'); await source.verify('a@b.c', '123456', true); await source.update('token', 'new-password');
 assert.equal(calls[0].init.headers.apikey, config.key); assert.equal(calls[0].init.headers.Authorization, undefined); assert.deepEqual(JSON.parse(calls[0].init.body).data, { full_name: 'Name' }); assert.equal(calls[3].init.method, 'PUT');
 for (const [code, expected] of [['otp_expired', 'invalid_code'], ['weak_password', 'weak_password'], ['same_password', 'same_password'], ['PRIVATE_SDK_MESSAGE', 'unavailable']]) {
  const failing = new CredentialSource(config, async () => new Response(JSON.stringify({ error_code: code, message: 'PRIVATE_DETAIL' }), { status: 422 }));
  await assert.rejects(failing.verify('a@b.c', '123456', true), e => e.kind === expected && !e.message.includes('PRIVATE'));
 }
 const duplicate = new CredentialSource(config, async () => new Response('{"error_code":"user_already_exists"}', { status: 422 })); assert.deepEqual(await duplicate.register('Name', 'a@b.c', '12345678'), { id: 'pending' });
 const huge = new CredentialSource(config, async () => new Response('x'.repeat(65537))); await assert.rejects(huge.recover('a@b.c'), /unavailable/);
});
test('Server recovery requires the exact flow and verified identity, never establishes normal access, and retains reset after failure', async () => {
 const flow = newCredentialFlow('recovery', 'user@example.test'); let updated = 0, logout = 0, wrongActor = false;
 const source = { verify: async () => ({ access_token: 'test-token', expires_in: 3600, user: { id: actor } }), user: async () => ({ id: wrongActor ? 'other' : actor, email: flow.email }), update: async () => { updated++; if (updated === 1) throw new CredentialFailure('unavailable'); return { id: actor }; } };
 const repo = new ServerCredentialRepository(source, { logout: async () => { logout++; } }, flow);
 await assert.rejects(repo.resetAccess(), /expired/); await assert.rejects(repo.verify('registration', flow.id, '123456'), /conflict/);
 const result = await repo.verify('recovery', flow.id, '123456'); assert.equal(result.session, null); assert.equal(result.progress.stage, 'reset'); assert.equal(repo.established, null);
 wrongActor = true; await assert.rejects(repo.reset(flow.id, '12345678'), /expired/); assert.equal(updated, 0);
 wrongActor = false; await assert.rejects(repo.reset(flow.id, '12345678'), /unavailable/); assert.ok(repo.flow.recovery);
 await repo.reset(flow.id, '12345678'); assert.equal(repo.flow, null); assert.equal(logout, 1);
});
test('Credential ViewModel deduplicates submits, preserves code on error, ignores disposed replies and counts actual resend deadlines', async () => {
 let resolve, requests = 0, now = Date.now(); const p = progress(); p.retryAt = now + 60000;
 const repo = { progress: async () => p, register: () => { requests++; return new Promise(r => { resolve = r; }); }, verify: async () => { throw new CredentialFailure('invalid_code'); }, resend: async () => ({ ...p, retryAt: now + 60000 }), cancel: async () => {} };
 const vm = model(repo, () => now); await vm.initialize('registration'); assert.equal(vm.state.seconds, 60);
 await vm.verify('000000'); assert.equal(vm.state.failure.kind, 'invalid_code'); assert.equal(vm.state.progress.id, p.id); vm.edited(); assert.equal(vm.state.failure, null);
 now += 60001; vm.tick(); assert.equal(vm.state.seconds, 0); await vm.resend(); assert.equal(vm.state.seconds, 60);
 await vm.cancel(); const pending = vm.register('Name', 'a@b.c', '12345678', '12345678'); await vm.register('Name', 'a@b.c', '12345678', '12345678'); assert.equal(requests, 1);
 vm.dispose(); resolve({ progress: p, session: null }); await pending; assert.equal(vm.state.progress, null);
});
test('HTTP credentials adapter rejects malformed progress, maps rate limits and never returns external tokens', async () => {
 const seen = [], p = progress(); const repo = new HttpCredentialRepository(async (path, init) => { seen.push({ path, init }); return new Response(JSON.stringify({ progress: p, session: null, access_token: 'DROP' })); });
 const result = await repo.register('Name', 'a@b.c', '12345678'); assert.equal(result.session, null); assert.doesNotMatch(JSON.stringify(result), /DROP|recovery/); assert.equal(seen[0].init.credentials, 'same-origin');
 const broken = new HttpCredentialRepository(async () => new Response('{"progress":{"id":"bad"}}')); await assert.rejects(broken.progress(), /unavailable/);
 const limited = new HttpCredentialRepository(async () => new Response('{"error":"rate_limited"}', { status: 429 })); await assert.rejects(limited.requestRecovery('a@b.c'), /rate_limited/);
});
test('Server resend enforces the cookie deadline and a stale tab cannot erase a newer flow', async () => {
 let calls = 0; const flow = newCredentialFlow('registration', 'a@b.c');
 const repo = new ServerCredentialRepository({ resend: async () => { calls++; } }, {}, flow);
 await assert.rejects(repo.resend('registration', flow.id), /rate_limited/); assert.equal(calls, 0);
 await assert.rejects(repo.resend('registration', 'f'.repeat(32)), /conflict/); assert.equal(repo.flow.id, flow.id);
 repo.flow.retryAt = Date.now() - 1; const resent = await repo.resend('registration', flow.id);
 assert.equal(calls, 1); assert.ok(resent.retryAt > Date.now() + 59000);
});
test('Recovery ViewModel preserves a failed reset for retry, confirms only committed updates, and honors rate limits without a pending code', async () => {
 let now = Date.now(), attempts = 0;
 const p = { ...progress(), kind: 'recovery', stage: 'reset' };
 const repo = { resetAccess: async () => {}, progress: async () => p, reset: async () => { attempts++; if (attempts === 1) throw new CredentialFailure('unavailable'); } };
 const vm = model(repo, () => now); await vm.initialize('recovery', true); await vm.reset('12345678', '12345678');
 assert.equal(vm.state.completed, false); assert.equal(vm.state.progress.id, p.id);
 await vm.reset('12345678', '12345678'); assert.equal(vm.state.completed, true); assert.equal(vm.state.progress, null);
 const limited = model({ progress: async () => null, requestRecovery: async () => { throw new CredentialFailure('rate_limited'); } }, () => now);
 await limited.initialize('recovery'); await limited.recover('a@b.c'); assert.equal(limited.state.seconds, 60);
 now += 61000; limited.tick(); assert.equal(limited.state.seconds, 0);
 vm.dispose(); limited.dispose();
});
