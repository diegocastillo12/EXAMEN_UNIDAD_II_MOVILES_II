import assert from 'node:assert/strict';
import { test } from 'node:test';
import { statisticsFixture, administrator, statisticsResult } from './statistics_fixture.mjs';
import { ordinary, moderator } from './moderation_fixture.mjs';
test('HU16.1 production SSR policy, independent admin access, CSRF, actor binding and revocation', async t => {
 const server = await statisticsFixture(); t.after(server.close);
 const login = async email => {
  const response = await fetch(server.origin + '/api/access/login', { method: 'POST', headers: { Origin: server.origin, 'Content-Type': 'application/json' }, body: JSON.stringify({ email, password: 'test-fixture-password' }) }); assert.equal(response.status, 200);
  return response.headers.getSetCookie().find(c => c.startsWith('eh_access=') && !c.startsWith('eh_access=;')).split(';')[0];
 };
 const period = { from: '2026-10-01', to: '2026-10-24' };
 const read = (cookie = '', actor = administrator, origin = server.origin, body = period) => fetch(server.origin + '/api/statistics/read', { method: 'POST', headers: { Origin: origin, 'Content-Type': 'application/json', Cookie: cookie, 'X-Account-Actor': actor }, body: JSON.stringify(body) });
 const access = (cookie, actor) => fetch(server.origin + '/api/statistics/access', { headers: { Cookie: cookie, 'X-Account-Actor': actor } });
 assert.equal((await read()).status, 401);
 const anonymous = await fetch(server.origin + '/administracion/estadisticas', { redirect: 'manual' }); assert.equal(anonymous.status, 302); assert.match(anonymous.headers.get('location'), /\/api\/access\/entry/);
 for (const [email, actor] of [['ordinario@example.test', ordinary], ['moderador@example.test', moderator]]) {
  const cookie = await login(email);
  assert.deepEqual(await (await access(cookie, actor)).json(), { allowed: false }); assert.equal((await read(cookie, actor)).status, 403);
  const response = await fetch(server.origin + '/administracion/estadisticas', { headers: { Cookie: cookie }, redirect: 'manual' }); assert.equal(response.status, 302); assert.equal(response.headers.get('location'), '/inicio?reason=forbidden');
 }
 const cookie = await login('administrador@example.test');
 assert.deepEqual(await (await access(cookie, administrator)).json(), { allowed: true });
 assert.equal((await read(cookie, ordinary)).status, 409); assert.equal((await read(cookie, administrator, 'https://elsewhere.test')).status, 403);
 assert.equal((await read(cookie, administrator, server.origin, { from: '2026-02-30', to: '2026-03-01' })).status, 422);
 const response = await read(cookie); assert.equal(response.status, 200); assert.equal(response.headers.get('cache-control'), 'no-store'); assert.deepEqual(await response.json(), statisticsResult(period));
 const html = await fetch(server.origin + '/administracion/estadisticas', { headers: { Cookie: cookie } }).then(r => r.text()); assert.match(html, /Estadísticas/); assert.doesNotMatch(html, /private-jwt|PRIVATE|publishedLost/);
 server.fail(true); assert.equal((await read(cookie)).status, 503); server.fail(false); assert.equal((await read(cookie)).status, 200);
 server.revokeStatistics(true); assert.equal((await read(cookie)).status, 403); assert.deepEqual(await (await access(cookie, administrator)).json(), { allowed: false });
});
