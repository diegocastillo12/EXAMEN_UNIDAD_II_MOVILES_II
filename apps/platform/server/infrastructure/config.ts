import { isIP } from 'node:net';
export function configuration(env: NodeJS.ProcessEnv) {
  const url = new URL(env.SUPABASE_URL || 'invalid:');
  const local = ['localhost', '127.0.0.1', '[::1]'].includes(url.hostname);
  const key = env.SUPABASE_SERVER_KEY || '';
  if ((url.protocol !== 'https:' && !(url.protocol === 'http:' && local)) || url.username || url.password ||
    !['', '/'].includes(url.pathname) || url.search || url.hash || key.length < 20 ||
    !(key.startsWith('sb_secret_') || (key.startsWith('eyJ') && key.split('.').length === 3))) throw Error('invalid_config');
  if (key.startsWith('eyJ')) {
    try { if (JSON.parse(Buffer.from(key.split('.')[1]!, 'base64url').toString()).role !== 'service_role') throw Error(); }
    catch { throw Error('invalid_config'); }
  }
  const trustedProxies = (env.TRUSTED_PROXY_IPS || '').split(',').map(v => v.trim()).filter(Boolean);
  if (trustedProxies.some(ip => !isIP(ip))) throw Error('invalid_config');
  return { url: url.origin, key, trustedProxies };
}
