import { randomBytes } from 'node:crypto';
import { productionFixture } from './server_fixture.mjs';
export const credentialActor = '55555555-5555-4555-8555-555555555555';
export async function credentialFixture() {
  const users = new Map([['existente@example.test', { id: credentialActor, name: 'Cuenta existente', password: 'original-password', confirmed: true, onboarded: true }]]);
  const tokens = new Map(), codes = new Map(), calls = [];
  let failure = '', autoConfirm = false, wrongActor = false;
  const send = (res, value, status = 200) => { res.writeHead(status, { 'Content-Type': 'application/json' }); res.end(JSON.stringify(value)); };
  const issue = (email, recovery = false) => { const token = randomBytes(24).toString('base64url'); tokens.set(token, { email, recovery }); return { access_token: token, expires_in: 3600, refresh_token: 'PRIVATE_REFRESH_TOKEN', user: { id: credentialActor } }; };
  async function handle(req, res) {
    const url = new URL(req.url, 'http://fixture'), path = url.pathname;
    if (!path.startsWith('/auth/v1/') && !path.startsWith('/rest/v1/')) return false;
    let body = {}; if (['POST', 'PUT'].includes(req.method)) { const chunks = []; for await (const chunk of req) chunks.push(chunk); body = JSON.parse(Buffer.concat(chunks).toString() || '{}'); }
    calls.push({ path, method: req.method });
    if (path === failure) { send(res, { message: 'PRIVATE_AUTH_FAILURE' }, 503); return true; }
    const token = req.headers.authorization?.replace('Bearer ', ''), identity = tokens.get(token), user = identity && users.get(identity.email);
    if (path === '/auth/v1/signup') {
      let record = users.get(body.email);
      if (!record) { record = { id: credentialActor, name: body.data.full_name, password: body.password, confirmed: autoConfirm, onboarded: false }; users.set(body.email, record); }
      if (!record.confirmed) codes.set(body.email + ':email', '123456');
      send(res, autoConfirm ? issue(body.email) : { id: credentialActor, identities: record.confirmed ? [] : [{}] }); return true;
    }
    if (path === '/auth/v1/recover') { if (users.has(body.email)) codes.set(body.email + ':recovery', '123456'); send(res, {}); return true; }
    if (path === '/auth/v1/resend') { if (users.has(body.email) && !users.get(body.email).confirmed) codes.set(body.email + ':email', '123456'); send(res, {}); return true; }
    if (path === '/auth/v1/verify') {
      const key = body.email + ':' + body.type;
      if (codes.get(key) !== body.token) { send(res, { error_code: 'otp_expired', message: 'PRIVATE_EXPIRED' }, 403); return true; }
      codes.delete(key); if (body.type === 'email') users.get(body.email).confirmed = true;
      send(res, issue(body.email, body.type === 'recovery')); return true;
    }
    if (path === '/auth/v1/token') {
      const record = users.get(body.email);
      if (!record?.confirmed || record.password !== body.password) send(res, { error_code: 'invalid_credentials' }, 400);
      else send(res, issue(body.email)); return true;
    }
    if (path === '/auth/v1/user') {
      if (!user) { send(res, { error_code: 'session_not_found' }, 401); return true; }
      if (req.method === 'PUT') {
        if (body.password === user.password) { send(res, { error_code: 'same_password' }, 422); return true; }
        user.password = body.password;
      }
      send(res, { id: wrongActor ? '66666666-6666-4666-8666-666666666666' : user.id, email: identity.email }); return true;
    }
    if (path === '/auth/v1/logout') { tokens.delete(token); send(res, {}); return true; }
    if (path === '/rest/v1/profiles') { send(res, user ? [{ id: user.id, display_name: user.name, city: null, onboarding_completed_at: user.onboarded ? '2026-10-19T00:00:00Z' : null }] : []); return true; }
    if (path === '/rest/v1/rpc/complete_onboarding') { user.onboarded = true; res.writeHead(204); res.end(); return true; }
    if (path === '/rest/v1/rpc/require_content_reviewer') { send(res, { code: '42501' }, 403); return true; }
    return false;
  }
  const server = await productionFixture(undefined, { handle, env: { SUPABASE_PUBLISHABLE_KEY: 'sb_publishable_fixture_123456', MODERATION_SESSION_SECRET: 'fixture-session-secret-only-not-a-production-key' } });
  return { ...server, calls, fail: path => { failure = path; }, autoConfirm: value => { autoConfirm = value; }, wrongActor: value => { wrongActor = value; } };
}
