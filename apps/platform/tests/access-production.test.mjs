import assert from 'node:assert/strict';
import { test } from 'node:test';
import { moderationFixture, ordinary, moderator } from './moderation_fixture.mjs';
import { routePolicies } from '../shared/routing/route_policy.ts';
import { request } from 'node:http';
const cookieOf = r => r.headers.getSetCookie().find(c => c.startsWith('eh_access=') && !c.startsWith('eh_access=;'))?.split(';')[0];
const post = (s, path, body = {}, cookie = '', actor = ordinary, origin = s.origin) => fetch(s.origin + '/api/access/' + path, {
 method: 'POST', headers: { Origin: origin, 'Content-Type': 'application/json', Cookie: cookie, 'X-Account-Actor': actor }, body: JSON.stringify(body),
});
const login = (s, email = 'ordinario@example.test') => post(s, 'login', { email, password: 'test-fixture-password' });

test('Both web logout endpoints clear cookies and respond while Supabase logout is still pending', async t => {
 const s = await moderationFixture(); t.after(s.close);
 for (const namespace of ['access', 'moderation']) {
  const cookie = cookieOf(await login(s, 'moderador@example.test'));
  const paused = s.pauseLogout();
  try {
   const responsePromise = fetch(s.origin + '/api/' + namespace + '/logout', {
    method: 'POST', headers: { Origin: s.origin, 'Content-Type': 'application/json', Cookie: cookie }, body: '{}', signal: AbortSignal.timeout(2000),
   });
   await paused.started;
   const response = await responsePromise;
   assert.equal(response.status, 200); assert.deepEqual(await response.json(), { signedOut: true });
   const removed = response.headers.getSetCookie();
   for (const path of ['/', '/api']) assert.ok(removed.some(c => c.startsWith('eh_access=;') && c.includes('Path=' + path + ';') && c.includes('Max-Age=0')));
   assert.ok(removed.some(c => c.startsWith('eh_moderation=;') && c.includes('Max-Age=0')));
   assert.equal((await fetch(s.origin + '/api/access/session')).status, 401);
   assert.equal((await fetch(s.origin + '/api/moderation/session')).status, 401);
  } finally { paused.release(); }
 }
});

test('Web logout clears cookies even if backend configuration is unavailable; cross-origin logout remains denied', async t => {
 const { productionFixture } = await import('./server_fixture.mjs');
 const s = await productionFixture(undefined, { env: { SUPABASE_PUBLISHABLE_KEY: '', MODERATION_SESSION_SECRET: '' } }); t.after(s.close);
 for (const namespace of ['access', 'moderation']) {
  const response = await fetch(s.origin + '/api/' + namespace + '/logout', { method: 'POST', headers: { Origin: s.origin, Cookie: 'eh_access=invalid; eh_moderation=invalid', 'Content-Type': 'application/json' }, body: '{}' });
  assert.equal(response.status, 200); assert.deepEqual(await response.json(), { signedOut: true });
  assert.ok(response.headers.getSetCookie().filter(c => c.includes('Max-Age=0')).length >= 3);
  const denied = await fetch(s.origin + '/api/' + namespace + '/logout', { method: 'POST', headers: { Origin: 'https://untrusted.example', 'Content-Type': 'application/json' }, body: '{}' });
  assert.equal(denied.status, 403); assert.equal(denied.headers.getSetCookie().length, 0);
 }
});

test('External document navigation reaches login through the entry bridge while cross-site API calls remain denied', async t => {
 const s = await moderationFixture(); t.after(s.close);
 const headers = { 'Sec-Fetch-Site': 'cross-site', 'Sec-Fetch-Mode': 'navigate', 'Sec-Fetch-Dest': 'document' };
 // Node fetch overwrites Sec-Fetch-Mode with cors; use raw HTTP to reproduce
 // browser navigation metadata exactly (also exercised in real Chrome).
 const navigate = path => new Promise((resolve, reject) => {
  const req = request(s.origin + path, { headers }, res => {
   const chunks = []; res.on('data', chunk => chunks.push(chunk));
   res.on('end', () => resolve({ status: res.statusCode, location: res.headers.location, body: Buffer.concat(chunks).toString() }));
  }); req.on('error', reject); req.end();
 });
 const r = await navigate('/api/access/entry?destination=%2Finicio');
 assert.equal(r.status, 302); assert.equal(r.location, '/iniciar-sesion?entry=checked');
 const initial = await navigate('/inicio'); assert.equal(initial.status, 302);
 const bridge = await navigate(initial.location); assert.equal(bridge.status, 302);
 const page = await navigate(bridge.location); assert.equal(page.status, 200); assert.match(page.body, /Inicia sesión/);
 for (const path of ['/api/access/session', '/api/access/management', '/api/moderation/session']) {
  assert.equal((await fetch(s.origin + path, { headers })).status, 403, path);
 }
 for (const extra of [{}, { 'Sec-Fetch-Mode': 'cors', 'Sec-Fetch-Dest': 'empty' }, { 'Sec-Fetch-Mode': 'navigate', 'Sec-Fetch-Dest': 'iframe' }]) {
  assert.equal((await fetch(s.origin + '/api/access/entry', { headers: { 'Sec-Fetch-Site': 'cross-site', ...extra }, redirect: 'manual' })).status, 403);
 }
 assert.equal((await post(s, 'login', { email: 'ordinario@example.test', password: 'test-fixture-password' }, '', ordinary, 'https://untrusted.example')).status, 403);
});

test('Every registered route applies the common policy on SSR, including public pages, redirects, QR and reviewer permissions', async t => {
 const s = await moderationFixture(); t.after(s.close);
 for (const [pattern, access] of Object.entries(routePolicies)) {
  const path = pattern.replace(':slug', 'a'.repeat(64)).replace(':path(.*)*', 'no-existe');
  const r = await fetch(s.origin + path, { redirect: 'manual' });
  if (access === 'public') {
   assert.equal(r.status, ['/login', '/terms', '/privacy'].includes(path) ? 308 : 200, path);
  } else {
   assert.equal(r.status, 302, path);
   assert.doesNotMatch(await r.text(), /account-layout|moderation-screen|skeleton/, path);
   const form = await fetch(s.origin + path);
     assert.equal(new URL(form.url).pathname, access === 'guest' ? path : access === 'recovery' ? '/recuperar-contrasena' : '/iniciar-sesion', path);
  }
  assert.match(r.headers.get('cache-control'), /no-store/, path);
 }
 const ordinaryCookie = cookieOf(await login(s));
 const denied = await fetch(s.origin + '/moderacion', { headers: { Cookie: ordinaryCookie }, redirect: 'manual' });
 assert.equal(denied.status, 302); assert.equal(denied.headers.get('location'), '/inicio?reason=forbidden');
 assert.doesNotMatch(await denied.text(), /moderation-screen|skeleton|PRIVATE_REPORT_REASON/);
 s.setOnboarding(ordinary, false);
 const pending = await fetch(s.origin + '/moderacion', { headers: { Cookie: ordinaryCookie }, redirect: 'manual' });
 assert.equal(pending.headers.get('location'), '/bienvenida');
 const reviewerCookie = cookieOf(await login(s, 'moderador@example.test'));
 const reviewer = await fetch(s.origin + '/moderacion', { headers: { Cookie: reviewerCookie }, redirect: 'manual' });
 assert.equal(reviewer.status, 200); assert.doesNotMatch(await reviewer.text(), /PRIVATE_REPORT_REASON|mmmmmmmm/);
 const migrated = await fetch(s.origin + '/api/access/entry?destination=%2Fmoderacion', { headers: { Cookie: reviewerCookie }, redirect: 'manual' });
 assert.equal(migrated.headers.get('location'), '/moderacion');
 const external = await fetch(s.origin + '/api/access/entry?destination=https://untrusted.example', { headers: { Cookie: reviewerCookie }, redirect: 'manual' });
 assert.equal(external.headers.get('location'), '/inicio');
 s.revoke(true);
 const revoked = await fetch(s.origin + '/moderacion', { headers: { Cookie: reviewerCookie }, redirect: 'manual' });
 assert.equal(revoked.headers.get('location'), '/inicio?reason=forbidden');
});
test('Ordinary users enter a general session; private account data stays out of SSR and moderation remains denied', async t => {
 const s = await moderationFixture(); t.after(s.close);
 const r = await login(s); assert.equal(r.status, 200); const cookie = cookieOf(r), session = await r.json(); assert.equal(session.actor, ordinary); assert.equal(session.profile.city, 'Lima');
 const rawCookie = r.headers.getSetCookie().find(c => c.startsWith('eh_access=') && !c.startsWith('eh_access=;'));
 assert.match(rawCookie, /HttpOnly/); assert.match(rawCookie, /SameSite=Strict/i); assert.match(rawCookie, /Path=\/;/);
 assert.doesNotMatch(JSON.stringify(session), /access_token|refresh_token|ooooooo|sb_publishable|session-secret/);
 const headers = { Cookie: cookie, 'X-Account-Actor': ordinary };
 assert.equal((await fetch(s.origin + '/api/access/session', { headers })).status, 200);
 const roles = await fetch(s.origin + '/api/access/management', { headers }); assert.deepEqual(await roles.json(), { canReviewReports: false });
 const denied = await fetch(s.origin + '/api/moderation/session', { headers }); assert.equal(denied.status, 403);
 assert.equal((await fetch(s.origin + '/api/access/session', { headers })).status, 200);
 for (const route of ['/inicio', '/bienvenida', '/iniciar-sesion']) {
  const page = await fetch(s.origin + route, { headers }); assert.equal(page.status, 200);
  assert.doesNotMatch(await page.text(), /ordinario@example.test|Usuario de prueba|PRIVATE_REPORT_REASON|ooooooo|sb_publishable_fixture/);
  assert.match(page.headers.get('cache-control'), /no-store/);
 }
 assert.equal((await post(s, 'onboarding', {}, cookie, moderator)).status, 409);
 assert.equal((await post(s, 'logout', {}, cookie)).status, 200);
 assert.equal((await fetch(s.origin + '/api/access/session')).status, 401);
});

test('Login redirects before rendering HTML, validates onboarding and never redirects to arbitrary destinations', async t => {
 const s = await moderationFixture(); t.after(s.close);
 const cookie = cookieOf(await login(s));
 for (const completed of [true, false]) {
  s.setOnboarding(ordinary, completed);
  const r = await fetch(s.origin + '/iniciar-sesion?next=https://untrusted.example&entry=checked', { headers: { Cookie: cookie }, redirect: 'manual' });
  assert.equal(r.status, 302); assert.equal(r.headers.get('location'), completed ? '/inicio' : '/bienvenida');
  assert.match(r.headers.get('cache-control'), /no-store/);
  assert.doesNotMatch(await r.text(), /Inicia sesión|login-form|ordinario@example.test|ooooooo/);
 }
 s.profileFailure(true);
 const failure = await fetch(s.origin + '/iniciar-sesion', { headers: { Cookie: cookie }, redirect: 'manual' });
 assert.equal(failure.headers.get('location'), '/inicio');
 assert.ok(!failure.headers.getSetCookie().some(c => /Max-Age=0/.test(c)));
});

test('Signed-out account pages redirect before rendering their shell; authenticated pages enforce onboarding before HTML', async t => {
 const s = await moderationFixture(); t.after(s.close);
 const cookie = cookieOf(await login(s));
 await post(s, 'logout', {}, cookie);
 for (const path of ['/inicio', '/bienvenida']) {
  for (const supplied of ['', 'eh_access=forged']) {
   const r = await fetch(s.origin + path, { headers: { Cookie: supplied }, redirect: 'manual' });
   assert.equal(r.status, 302);
   assert.doesNotMatch(await r.text(), /account-layout|account-main|skeleton|Consultando tu cuenta/);
   assert.match(r.headers.get('cache-control'), /no-store/);
   const form = await fetch(s.origin + path);
   assert.equal(new URL(form.url).pathname, '/iniciar-sesion');
   const html = await form.text(); assert.match(html, /Inicia sesión/);
   assert.doesNotMatch(html, /account-layout|account-main/);
  }
 }
 const active = cookieOf(await login(s));
 for (const completed of [true, false]) {
  s.setOnboarding(ordinary, completed);
  const right = completed ? '/inicio' : '/bienvenida', wrong = completed ? '/bienvenida' : '/inicio';
  const r = await fetch(s.origin + wrong, { headers: { Cookie: active }, redirect: 'manual' });
  assert.equal(r.status, 302); assert.equal(r.headers.get('location'), right);
  assert.doesNotMatch(await r.text(), /account-layout|skeleton/);
 }
 s.profileFailure(true);
 const failure = await fetch(s.origin + '/inicio', { headers: { Cookie: active }, redirect: 'manual' });
 assert.equal(failure.status, 200); assert.match(await failure.text(), /account-layout/);
 const legacyFailure = await fetch(s.origin + '/api/access/entry', { headers: { Cookie: active }, redirect: 'manual' });
 assert.equal(legacyFailure.headers.get('location'), '/inicio?entry=unavailable');
 const retryShell = await fetch(s.origin + legacyFailure.headers.get('location'), { redirect: 'manual' });
 assert.equal(retryShell.status, 200); assert.doesNotMatch(await retryShell.text(), /Usuario de prueba|ordinario@example.test/);
});

test('API-only sessions migrate without rendering login; anonymous/forged sessions reach the form without loops', async t => {
 const s = await moderationFixture(); t.after(s.close);
 const cookie = cookieOf(await login(s));
 const bridge = await fetch(s.origin + '/iniciar-sesion?reason=expired', { redirect: 'manual' });
 assert.equal(bridge.status, 302); assert.equal(bridge.headers.get('location'), '/api/access/entry?reason=expired');
 const recovered = await fetch(s.origin + bridge.headers.get('location'), { headers: { Cookie: cookie }, redirect: 'manual' });
 assert.equal(recovered.headers.get('location'), '/inicio');
 assert.ok(recovered.headers.getSetCookie().some(c => /Path=\/api;/.test(c) && /Max-Age=0/.test(c)));
 assert.ok(recovered.headers.getSetCookie().some(c => /Path=\/;/.test(c) && !/Max-Age=0/.test(c)));
 for (const supplied of ['', 'eh_access=forged']) {
  const guest = await fetch(s.origin + '/api/access/entry?reason=expired&next=https://untrusted.example', { headers: { Cookie: supplied }, redirect: 'manual' });
  assert.equal(guest.status, 302);
  const target = new URL(guest.headers.get('location'), s.origin);
  assert.equal(target.origin, s.origin); assert.equal(target.pathname, '/iniciar-sesion');
  assert.equal(target.searchParams.get('reason'), 'expired');
  const form = await fetch(target); assert.equal(form.status, 200); assert.match(await form.text(), /Inicia sesión/);
 }
 const invalid = await fetch(s.origin + '/iniciar-sesion', { headers: { Cookie: 'eh_access=forged' }, redirect: 'manual' });
 assert.equal(invalid.status, 200); assert.match(await invalid.text(), /Inicia sesión/);
 assert.ok(invalid.headers.getSetCookie().filter(c => /Max-Age=0/.test(c)).length >= 2);
 const logout = await post(s, 'logout', {}, cookie);
 assert.ok(logout.headers.getSetCookie().some(c => /eh_access=;/.test(c) && /Path=\/;/.test(c) && /Max-Age=0/.test(c)));
 assert.ok(logout.headers.getSetCookie().some(c => /eh_access=;/.test(c) && /Path=\/api;/.test(c) && /Max-Age=0/.test(c)));
});
test('A reviewer uses the same login; each moderation request rechecks role and revocation does not remove normal access', async t => {
 const s = await moderationFixture(); t.after(s.close);
 const r = await login(s, 'moderador@example.test'); assert.equal(r.status, 200);
 const cookie = cookieOf(r), headers = { Cookie: cookie, 'X-Account-Actor': moderator, 'X-Moderation-Actor': moderator };
 assert.deepEqual(await (await fetch(s.origin + '/api/access/management', { headers })).json(), { canReviewReports: true });
 assert.equal((await fetch(s.origin + '/api/moderation/session', { headers })).status, 200);
 s.revoke(true);
 assert.equal((await fetch(s.origin + '/api/moderation/session', { headers })).status, 403);
 assert.deepEqual(await (await fetch(s.origin + '/api/access/management', { headers })).json(), { canReviewReports: false });
 assert.equal((await fetch(s.origin + '/api/access/session', { headers })).status, 200);
});
test('Onboarding persists using existing account RPC, is idempotent and uses the cookie identity', async t => {
 const s = await moderationFixture(); t.after(s.close); s.setOnboarding(ordinary, false); s.setOnboarding(moderator, false);
 const r = await login(s); const cookie = cookieOf(r); assert.equal((await r.json()).profile.onboardingCompleted, false);
 assert.equal((await post(s, 'onboarding', { actor: moderator }, cookie, moderator)).status, 409);
 const done = await post(s, 'onboarding', { actor: moderator }, cookie); assert.equal(done.status, 200); assert.equal((await done.json()).profile.onboardingCompleted, true);
 assert.equal((await post(s, 'onboarding', {}, cookie)).status, 200); assert.equal(s.completions(), 1);
 const reviewer = await login(s, 'moderador@example.test'); assert.equal((await reviewer.json()).profile.onboardingCompleted, false);
});
test('Access APIs reject cross-origin/anonymous/forged cookies and failures are sanitized; missing profile does not become empty success', async t => {
 const s = await moderationFixture(); t.after(s.close);
 assert.equal((await post(s, 'login', {}, '', ordinary, 'https://untrusted.example')).status, 403);
 assert.equal((await post(s, 'onboarding')).status, 401);
 const forged = await fetch(s.origin + '/api/access/session', { headers: { Cookie: 'eh_access=forged' } }); assert.equal(forged.status, 401);
 assert.equal((await post(s, 'login', { email: 'bad', password: '' })).status, 422);
 const wrong = await post(s, 'login', { email: 'user@example.test', password: 'wrong' }); assert.equal(wrong.status, 401);
 s.profileFailure(true); const unavailable = await login(s); assert.equal(unavailable.status, 503); assert.deepEqual(await unavailable.json(), { error: 'unavailable' });
});
test('Old navigation URLs redirect permanently to Spanish routes, preserving flow parameters with a fixed internal destination', async t => {
 const s = await moderationFixture(); t.after(s.close);
 for (const [old, next] of [['login', 'iniciar-sesion'], ['terms', 'terminos'], ['privacy', 'privacidad']]) {
  const r = await fetch(s.origin + '/' + old + '?reason=expired&next=https%3A%2F%2Funtrusted.example', { redirect: 'manual' });
  assert.equal(r.status, 308); const target = new URL(r.headers.get('location'), s.origin);
  assert.equal(target.origin, s.origin); assert.equal(target.pathname, '/' + next); assert.equal(target.searchParams.get('reason'), 'expired');
  assert.equal((await fetch(s.origin + '/' + next)).status, 200);
 }
});
test('Social callbacks establish normal accounts without reviewer role and send incomplete accounts to onboarding', async t => {
 const s = await moderationFixture(); t.after(s.close); s.oauthDenied(true); s.setOnboarding(ordinary, false);
 const begin = await post(s, 'oauth/start', { provider: 'google' }); assert.equal(begin.status, 200);
 const flowCookie = begin.headers.getSetCookie().find(c => c.startsWith('eh_oauth=')).split(';')[0];
 const { url } = await begin.json(), redirect = await fetch(url, { redirect: 'manual' });
 const callback = await fetch(redirect.headers.get('location'), { redirect: 'manual', headers: { Cookie: flowCookie, 'Sec-Fetch-Site': 'cross-site' } });
 assert.equal(callback.status, 303); assert.equal(callback.headers.get('location'), '/bienvenida'); assert.ok(cookieOf(callback));
});

