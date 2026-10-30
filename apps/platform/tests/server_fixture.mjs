import { createServer } from 'node:http';
import { once } from 'node:events';
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { rawActive } from './fixtures.mjs';
export async function productionFixture(jpeg = new Uint8Array([255, 216, 255, 217]), options = {}) {
  let value = rawActive(); let fail = false; let reads = 0;
  const sightings = new Map(); let ambiguous = false; const sightingCalls = [];
  const backend = createServer(async (req, res) => {
    if (options.handle && await options.handle(req, res)) return;
    if (req.url === '/auth/v1/user') {
      if (req.headers.authorization !== 'Bearer '+ 'a'.repeat(30)) {res.writeHead(401);res.end();return;}
      res.writeHead(200, {'Content-Type':'application/json'});res.end(JSON.stringify({id:'11111111-1111-4111-8111-111111111125'}));return;
    }
    if (req.url === '/rest/v1/rpc/read_qr_case') {
      reads++; for await (const chunk of req) { /* Drain test request; never record token. */ }
      if (fail) { res.writeHead(503); res.end('PRIVATE SDK FAILURE'); return; }
      res.writeHead(200, { 'Content-Type': 'application/json' }); res.end(JSON.stringify(value)); return;
    }
    if (req.url === '/rest/v1/rpc/submit_public_sighting' || req.url === '/rest/v1/rpc/submit_app_sighting') {
      const chunks = []; for await (const chunk of req) chunks.push(chunk);
      const input = JSON.parse(Buffer.concat(chunks).toString()); sightingCalls.push(input);
      if (value.state !== 'active') { res.writeHead(400, { 'Content-Type': 'application/json' }); res.end(JSON.stringify({ message: 'sighting_closed' })); return; }
      const id = input.p_report.id; let saved = sightings.get(id);
      if (saved && saved.hash !== input.p_request_hash) { res.writeHead(400, { 'Content-Type': 'application/json' }); res.end(JSON.stringify({ message: 'sighting_conflict' })); return; }
      if (!saved) { saved = { hash: input.p_request_hash, receipt: { id, receivedAt: new Date().toISOString(), late: Date.parse(input.p_report.observedAt) < Date.now() - 86400000 } }; sightings.set(id, saved); }
      if (ambiguous) { ambiguous = false; res.writeHead(503); res.end('PRIVATE failure after commit'); return; }
      res.writeHead(200, { 'Content-Type': 'application/json' }); res.end(JSON.stringify(saved.receipt)); return;
    }
    if (req.url.startsWith('/storage/v1/object/authenticated/')) { res.writeHead(200, { 'Content-Type': 'image/jpeg' }); res.end(jpeg); return; }
    res.writeHead(404); res.end();
  });
  backend.listen(0, '127.0.0.1'); await once(backend, 'listening');
  const reservation = createServer(); reservation.listen(0, '127.0.0.1'); await once(reservation, 'listening');
  const port = reservation.address().port; await new Promise(resolve => reservation.close(resolve));
  const env = { ...process.env, HOST: '127.0.0.1', PORT: String(port), NITRO_HOST: '127.0.0.1', NITRO_PORT: String(port), NODE_ENV: 'production', NUXT_PUBLIC_MAP_TILE_URL: 'https://basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}.png?key=test-map-key',
    SUPABASE_URL: `http://127.0.0.1:${backend.address().port}`, SUPABASE_SERVER_KEY: 'sb_secret_test-private-canary', TRUSTED_PROXY_IPS: '', PUBLIC_WEB_ORIGIN: `http://127.0.0.1:${port}`, ...(options.env || {}) };
  const child = spawn(process.execPath, ['.output/server/index.mjs'], { cwd: fileURLToPath(new URL('../', import.meta.url)), env, stdio: ['ignore', 'pipe', 'pipe'] });
  let logs = ''; child.stderr.on('data', b => { logs += b; });
  const close = async () => {
    if (child.exitCode == null) { const exited = once(child, 'exit'); child.kill(); await exited; }
    backend.closeAllConnections();
    await new Promise(resolve => backend.close(resolve));
  };
  try {
    await new Promise((resolve, reject) => {
      const timer = setTimeout(() => reject(Error('Production bootstrap timeout')), 15000);
      child.once('error', e => { clearTimeout(timer); reject(e); });
      child.once('exit', () => { clearTimeout(timer); reject(Error(`Production bootstrap failed: ${logs}`)); });
      child.stdout.once('data', () => { clearTimeout(timer); resolve(); });
    });
  } catch (error) { await close(); throw error; }
  return { origin: `http://127.0.0.1:${port}`, port, env, close, set: v => { value = v; }, fail: v => { fail = v; }, reads: () => reads, logs: () => logs,
    ambiguous: () => { ambiguous = true; }, sightings: () => sightings.size, sightingCalls: () => sightingCalls };
}
