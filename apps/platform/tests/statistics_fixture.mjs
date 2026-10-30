import { moderationFixture, moderator, ordinary } from './moderation_fixture.mjs';
export const administrator = '44444444-4444-4444-8444-444444444450';
export function statisticsResult(period) {
 return { period, timezone: 'America/Lima', publishedLost: 4, publishedFound: 2, sightings: 8, recovered: 1, cancelled: 2, archived: 1, reports: 3 };
}
export async function statisticsFixture() {
 let revoked = false, failed = false, empty = false, calls = 0, barrier = null;
 const send = (res, value, status = 200) => { res.writeHead(status, { 'Content-Type': 'application/json' }); res.end(JSON.stringify(value)); };
 const server = await moderationFixture(undefined, { handle: async (req, res) => {
  const isAdmin = req.headers.authorization === 'Bearer ' + 's'.repeat(30);
  if (req.url === '/auth/v1/token?grant_type=password') {
   const chunks = []; for await (const b of req) chunks.push(b); const body = JSON.parse(Buffer.concat(chunks).toString());
   if (body.email === 'administrador@example.test' && body.password === 'test-fixture-password') send(res, { access_token: 's'.repeat(30), expires_in: 3600, user: { id: administrator } });
   else if (body.password === 'test-fixture-password') send(res, { access_token: (body.email === 'moderador@example.test' ? 'm' : 'o').repeat(30), expires_in: 3600, user: { id: body.email === 'moderador@example.test' ? moderator : ordinary } });
   else send(res, {}, 401);
   return true;
  }
  if (isAdmin && req.url === '/auth/v1/user') { send(res, { id: administrator, email: 'administrador@example.test' }); return true; }
  if (isAdmin && req.url?.startsWith('/rest/v1/profiles?')) { send(res, [{ id: administrator, display_name: 'Administrador de prueba', city: 'Lima', onboarding_completed_at: '2026-10-01T12:00:00Z' }]); return true; }
  if (req.url === '/rest/v1/rpc/require_platform_administrator' || req.url === '/rest/v1/rpc/read_pilot_statistics') {
   const chunks = []; for await (const b of req) chunks.push(b); const body = JSON.parse(Buffer.concat(chunks).toString() || '{}');
   if (!isAdmin || revoked) { send(res, { code: '42501', message: 'statistics_forbidden' }, 403); return true; }
   if (req.url.endsWith('require_platform_administrator')) { send(res, administrator); return true; }
   calls++; if (barrier) await barrier.wait;
   if (failed) { send(res, { message: 'PRIVATE SQL FAILURE' }, 503); return true; }
   const result = statisticsResult({ from: body.p_from, to: body.p_to });
   if (empty) for (const key of Object.keys(result)) if (typeof result[key] === 'number') result[key] = 0;
   send(res, result); return true;
  }
  if (isAdmin && req.url === '/rest/v1/rpc/require_content_reviewer') { send(res, { code: '42501', message: 'moderation_forbidden' }, 403); return true; }
  return false;
 } });
 return { ...server, administrator, calls: () => calls, fail: value => { failed = value; }, empty: value => { empty = value; }, revokeStatistics: value => { revoked = value; }, pause() { let release; const wait = new Promise(r => release = r); barrier = { wait }; return () => { barrier = null; release(); }; } };
}
