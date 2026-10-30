import { randomBytes } from 'node:crypto';
import { RateLimit, clientAddress } from '../infrastructure/rate_limit';
const limiter = new RateLimit(); let inFlight = 0; let writes = 0;
const writeLimiter = new RateLimit({ limit: 10, windowMs: 60000, maxClients: 10000, now: Date.now });
const moderationLimiter = new RateLimit({ limit: 60, windowMs: 60000, maxClients: 10000, now: Date.now });
const loginLimiter = new RateLimit({ limit: 6, windowMs: 60000, maxClients: 10000, now: Date.now });
const credentialLimiter = new RateLimit({ limit: 10, windowMs: 60000, maxClients: 10000, now: Date.now });
const matchingLimiter = new RateLimit({ limit: 10, windowMs: 60000, maxClients: 10000, now: Date.now });
export default defineEventHandler(event => {
  const path = getRequestURL(event).pathname;
  const trusted = (process.env.TRUSTED_PROXY_IPS || '').split(',').map(v => v.trim()).filter(Boolean);
  // Internal SSR fetch inherits server context, never a visitor-supplied header.
  const peer = typeof event.context.readerPeer === 'string' ? event.context.readerPeer : clientAddress(event.node.req, trusted);
  event.context.readerPeer = peer;
  setHeaders(event, {
    'Cache-Control': 'no-store', 'Referrer-Policy': 'no-referrer', 'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY', 'Cross-Origin-Resource-Policy': 'same-origin',
    'X-Robots-Tag': path === '/' ? 'index, follow' : 'noindex, nofollow, noarchive, nosnippet',
    'Permissions-Policy': 'camera=(self), microphone=(), geolocation=(self)',
  });
  const nonce = randomBytes(18).toString('base64'); event.context.cspNonce = nonce;
  if (!import.meta.dev) setHeader(event, 'Content-Security-Policy',
    `default-src 'none'; script-src 'self' 'nonce-${nonce}'; style-src 'self' 'nonce-${nonce}'; img-src 'self' https://basemaps.cartocdn.com; connect-src 'self'; font-src 'self'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'`);
  const nativeSubmission = event.method === 'POST' && (/^\/api\/app\/cases\/(lost|found)\/[0-9a-f-]{36}\/sightings$/.test(path) || /^\/api\/app\/matching\/(search|review|searches)$/.test(path));
  const oauthCallback = event.method==='GET' && path==='/api/moderation/oauth/callback';
  // Redirects keep the initiating site's Fetch Metadata. The entry bridge is
  // navigation-only and returns fixed internal redirects, never account data.
  const accountEntryNavigation = ['GET', 'HEAD'].includes(event.method) && path === '/api/access/entry' &&
    getHeader(event, 'sec-fetch-mode') === 'navigate' && getHeader(event, 'sec-fetch-dest') === 'document';
  const recoveryPath = path.startsWith('/api/recovery/');
  const recoveryWrite = event.method === 'POST' && ['/api/recovery/case','/api/recovery/explore','/api/recovery/pets','/api/recovery/reports','/api/recovery/pet-photo'].includes(path);
  const blockPath = path.startsWith('/api/user-blocks/');
  const blockWrite = event.method === 'POST' && ['/api/user-blocks/prepare','/api/user-blocks/set'].includes(path);
  const notificationPath = blockPath || path.startsWith('/api/notifications/');
  const notificationWrite = event.method === 'POST' && path === '/api/notifications/read';
  const appealPath = path.startsWith('/api/appeals/');
  const appealWrite = event.method === 'POST' && ['/api/appeals/list','/api/appeals/submit','/api/appeals/answer'].includes(path);
  const statisticsPath = path.startsWith('/api/statistics/');
  const statisticsRead = event.method === 'POST' && path === '/api/statistics/read';
  const matchingPath = path.startsWith('/api/matching/');
  const matchingWrite = event.method === 'POST' && /^\/api\/matching\/(search|review|searches)$/.test(path);
  const nativeMatching = event.method === 'POST' && /^\/api\/app\/matching\/(search|review|searches)$/.test(path);
  const matchingCompute = (matchingWrite || nativeMatching) && path.endsWith('/search');
  const moderationPath = matchingPath || statisticsPath || appealPath || notificationPath || recoveryPath || path.startsWith('/api/moderation/') || path.startsWith('/api/access/');
  const credentialWrite = event.method === 'POST' && /^\/api\/access\/credentials\/(register|recover|verify|resend|reset|cancel)$/.test(path);
  const moderationWrite = credentialWrite || (event.method === 'POST' && ['/api/access/login','/api/access/logout','/api/access/onboarding','/api/access/oauth/start','/api/moderation/login','/api/moderation/oauth/start','/api/moderation/logout','/api/moderation/queue','/api/moderation/decisions'].includes(path));
  if (moderationPath && !oauthCallback && !accountEntryNavigation && getHeader(event,'sec-fetch-site') === 'cross-site') { setResponseStatus(event,403); return {error:'forbidden'}; }
  const submission = matchingWrite || statisticsRead || blockWrite || appealWrite || notificationWrite || recoveryWrite || moderationWrite || nativeSubmission || (event.method === 'POST' && /^\/api\/c\/[0-9a-f]{64}\/sightings$/.test(path));
  if (event.method !== 'GET' && event.method !== 'HEAD' && !submission) {
    setHeader(event, 'Allow', 'GET, HEAD'); setResponseStatus(event, 405); return { error: 'method_not_allowed' };
  }
  if ((event.node.req.url?.length || 0) > 2048) { setResponseStatus(event, 414); return { error: 'invalid_request' }; }
  if (submission) {
    const origin = process.env.PUBLIC_WEB_ORIGIN || (import.meta.dev ? getRequestURL(event).origin : 'https://entrehuellas.app');
    if ((!nativeSubmission && getHeader(event, 'origin') !== origin) || getHeader(event, 'sec-fetch-site') === 'cross-site' ||
      (nativeSubmission && (!/^Bearer [A-Za-z0-9._-]{20,8192}$/.test(getHeader(event, 'authorization') || '') || getHeader(event, 'origin')))) {
      setResponseStatus(event, 403); return { error: 'invalid_request' };
    }
    const requestLimiter = matchingCompute ? matchingLimiter : matchingWrite || nativeMatching || statisticsRead || moderationWrite || appealWrite || path === '/api/recovery/explore' ? moderationLimiter : writeLimiter;
    if (!requestLimiter.allow(peer) || (credentialWrite && !path.endsWith('/cancel') && !credentialLimiter.allow(peer)) || (['/api/access/login','/api/access/oauth/start','/api/moderation/login','/api/moderation/oauth/start'].includes(path) && !loginLimiter.allow(peer))) { setHeader(event, 'Retry-After', 60); setResponseStatus(event, 429); return { error: 'rate_limited' }; }
    if (writes >= 4) { setResponseStatus(event, 503); return { error: 'unavailable' }; }
    writes++; let released = false;
    const releaseWrite = () => { if (!released) { released = true; writes--; } };
    event.node.res.once('finish', releaseWrite); event.node.res.once('close', releaseWrite);
  }
  if (!path.startsWith('/api/c/')) return;
  if (!limiter.allow(peer)) {
    setHeader(event, 'Retry-After', 60); setResponseStatus(event, 429); return { error: 'try_later' };
  }
  if (inFlight >= 64) { setResponseStatus(event, 503); return { error: 'unavailable' }; }
  inFlight++; let finished = false;
  const release = () => { if (!finished) { finished = true; inFlight--; } };
  event.node.res.once('finish', release); event.node.res.once('close', release);
});
