import assert from 'node:assert/strict';
import { test } from 'node:test';
import { credentialFixture, credentialActor } from './credential_fixture.mjs';
const cookie = (r, name = 'eh_credentials') => r.headers.getSetCookie().find(c => c.startsWith(name + '=') && !c.startsWith(name + '=;'))?.split(';')[0];
const post = (s, action, body, cookies = '', origin = s.origin) => fetch(s.origin + '/api/access/credentials/' + action, { method: 'POST', headers: { Origin: origin, 'Content-Type': 'application/json', Cookie: cookies }, body: JSON.stringify(body) });
const register = (s, email = 'nuevo@example.test') => post(s, 'register', { name: 'Nueva cuenta', email, password: 'original-password', confirmation: 'original-password' });
const recovery = s => post(s, 'recover', { email: 'existente@example.test' });
test('Web registration validates before Auth, verifies code, establishes general cookie and follows account onboarding', async t => {
 const s = await credentialFixture(); t.after(s.close);
 const invalid = await post(s, 'register', { name: '', email: 'bad', password: 'short', confirmation: 'other' }); assert.equal(invalid.status, 422); assert.equal(s.calls.length, 0);
 const r = await register(s); assert.equal(r.status, 200); const pending = await r.json(), c = cookie(r); assert.equal(pending.progress.kind, 'registration'); assert.equal(pending.session, null); assert.equal(cookie(r, 'eh_access'), undefined);
 const header = r.headers.getSetCookie().find(v => v.startsWith('eh_credentials=')); assert.match(header, /HttpOnly/); assert.match(header, /SameSite=Strict/); assert.match(header, /Path=\/;/);
 assert.doesNotMatch(JSON.stringify(pending), /access_token|refresh_token|PRIVATE/);
 const restored = await fetch(s.origin + '/api/access/credentials', { headers: { Cookie: c } }); assert.equal((await restored.json()).progress.id, pending.progress.id);
 const bad = await post(s, 'verify', { kind: 'registration', id: pending.progress.id, code: '000000' }, c); assert.equal(bad.status, 422); assert.deepEqual(await bad.json(), { error: 'invalid_code' }); assert.equal(bad.headers.getSetCookie().length, 0);
 const good = await post(s, 'verify', { kind: 'registration', id: pending.progress.id, code: '123456' }, c); assert.equal(good.status, 200); const result = await good.json(); assert.equal(result.session.actor, credentialActor); assert.equal(result.session.profile.onboardingCompleted, false);
 const account = cookie(good, 'eh_access'); assert.ok(account); assert.ok(good.headers.getSetCookie().some(v => v.startsWith('eh_credentials=;')));
 const entry = await fetch(s.origin + '/crear-cuenta', { headers: { Cookie: account }, redirect: 'manual' }); assert.equal(entry.headers.get('location'), '/bienvenida');
 assert.doesNotMatch(JSON.stringify(result), /access_token|refresh_token|PRIVATE/);
});
test('Registration accepts Auth auto-confirm sessions and preserves indistinguishable pending results for existing addresses', async t => {
 const s = await credentialFixture(); t.after(s.close);
 const duplicate = await register(s, 'existente@example.test'); assert.equal(duplicate.status, 200); assert.equal((await duplicate.json()).session, null);
 s.autoConfirm(true); const confirmed = await register(s); assert.equal(confirmed.status, 200); assert.ok(cookie(confirmed, 'eh_access')); assert.equal((await confirmed.json()).progress, null);
});
test('Recovery verification grants only a short-lived reset capability, blocks normal pages and completes a real password update', async t => {
 const s = await credentialFixture(); t.after(s.close);
 const r = await recovery(s); assert.equal(r.status, 200); let c = cookie(r), p = (await r.json()).progress;
 const early = await fetch(s.origin + '/restablecer-contrasena', { headers: { Cookie: c }, redirect: 'manual' }); assert.equal(early.headers.get('location'), '/recuperar-contrasena?reason=expired'); assert.doesNotMatch(await early.text(), /Nueva contraseña|login-field/);
 const resend = await post(s, 'resend', { kind: 'recovery', id: p.id }, c); assert.equal(resend.status, 429); assert.equal(resend.headers.get('retry-after'), '60');
 const verified = await post(s, 'verify', { kind: 'recovery', id: p.id, code: '123456' }, c); assert.equal(verified.status, 200); c = cookie(verified); p = (await verified.json()).progress; assert.equal(p.stage, 'reset'); assert.equal(cookie(verified, 'eh_access'), undefined);
 assert.equal((await fetch(s.origin + '/api/access/session', { headers: { Cookie: c } })).status, 401);
 assert.equal((await fetch(s.origin + '/api/moderation/session', { headers: { Cookie: c } })).status, 401);
 const protectedPage = await fetch(s.origin + '/inicio', { headers: { Cookie: c }, redirect: 'manual' }); assert.equal(protectedPage.status, 302); assert.doesNotMatch(await protectedPage.text(), /account-layout/);
 const resetPage = await fetch(s.origin + '/restablecer-contrasena', { headers: { Cookie: c }, redirect: 'manual' }); assert.equal(resetPage.status, 200); assert.doesNotMatch(await resetPage.text(), /existente@example.test|PRIVATE|access_token/);
 const invalid = await post(s, 'reset', { id: p.id, password: 'short', confirmation: 'short' }, c); assert.equal(invalid.status, 422);
 const same = await post(s, 'reset', { id: p.id, password: 'original-password', confirmation: 'original-password' }, c); assert.equal(same.status, 422); assert.deepEqual(await same.json(), { error: 'same_password' });
 const saved = await post(s, 'reset', { id: p.id, password: 'updated-password', confirmation: 'updated-password' }, c); assert.equal(saved.status, 200); assert.deepEqual(await saved.json(), { updated: true }); assert.ok(saved.headers.getSetCookie().some(v => v.startsWith('eh_credentials=;')));
 const login = password => fetch(s.origin + '/api/access/login', { method: 'POST', headers: { Origin: s.origin, 'Content-Type': 'application/json' }, body: JSON.stringify({ email: 'existente@example.test', password }) });
 assert.equal((await login('original-password')).status, 401); assert.equal((await login('updated-password')).status, 200);
});
test('Credential endpoints reject CSRF, foreign flows and forged capabilities; unknown recovery emails do not reveal account existence', async t => {
 const s = await credentialFixture(); t.after(s.close);
 assert.equal((await post(s, 'recover', { email: 'existente@example.test' }, '', 'https://untrusted.example')).status, 403); assert.equal(s.calls.length, 0);
 const missing = await post(s, 'recover', { email: 'missing@example.test' }); assert.equal(missing.status, 200); const p = (await missing.json()).progress;
 const fake = await post(s, 'reset', { id: p.id, password: 'new-password', confirmation: 'new-password' }, 'eh_credentials=forged'); assert.equal(fake.status, 401); assert.equal(s.calls.filter(c => c.method === 'PUT').length, 0);
 const wrongKind = await post(s, 'verify', { kind: 'registration', id: p.id, code: '123456' }, cookie(missing)); assert.equal(wrongKind.status, 409); assert.equal(wrongKind.headers.getSetCookie().length, 0);
 const direct = await fetch(s.origin + '/restablecer-contrasena', { redirect: 'manual' }); assert.equal(direct.status, 302); assert.doesNotMatch(await direct.text(), /credential-layout|Nueva contraseña/);
 for (const route of ['/crear-cuenta', '/recuperar-contrasena']) { const page = await fetch(s.origin + route); assert.equal(new URL(page.url).pathname, route); assert.equal(page.status, 200); }
});
test('Recovery failures keep the verified capability for retry, and cancellation removes it without producing a normal session', async t => {
 const s = await credentialFixture(); t.after(s.close);
 const r = await recovery(s), p = (await r.json()).progress;
 const verified = await post(s, 'verify', { kind: 'recovery', id: p.id, code: '123456' }, cookie(r)), c = cookie(verified);
 s.fail('/auth/v1/user'); const failed = await post(s, 'reset', { id: p.id, password: 'updated-password', confirmation: 'updated-password' }, c); assert.equal(failed.status, 503); assert.deepEqual(await failed.json(), { error: 'unavailable' }); assert.equal(failed.headers.getSetCookie().length, 0);
 s.fail(''); const status = await fetch(s.origin + '/api/access/credentials/reset-access', { headers: { Cookie: c } }); assert.equal(status.status, 200);
 const cancelled = await post(s, 'cancel', {}, c); assert.equal(cancelled.status, 200); assert.ok(cancelled.headers.getSetCookie().some(v => v.startsWith('eh_credentials=;'))); assert.equal(cookie(cancelled, 'eh_access'), undefined);
 assert.equal((await fetch(s.origin + '/api/access/credentials/reset-access', { headers: { Cookie: c } })).status, 401);
});
