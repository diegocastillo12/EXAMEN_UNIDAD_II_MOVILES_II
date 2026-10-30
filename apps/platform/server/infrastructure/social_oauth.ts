import { createCipheriv, createDecipheriv, createHash, randomBytes, timingSafeEqual } from 'node:crypto';
import { AccessFailure, socialProvider } from '../../shared/features/access/domain/access.ts';
import type { SocialProvider } from '../../shared/features/access/domain/access';
export const oauthCookie = 'eh_oauth';
export const oauthCookiePath = '/api/moderation/oauth';
type Flow = { state: string; verifier: string; provider: SocialProvider; expiresAt: number };
const aad = Buffer.from('entrehuellas:oauth:v1');
export function newOAuthFlow(provider: unknown): Flow {
  return { provider: socialProvider(provider), state: randomBytes(32).toString('base64url'), verifier: randomBytes(48).toString('base64url'), expiresAt: Date.now()+600000 };
}
export function sealOAuthFlow(flow: Flow, secret: string) {
  const iv=randomBytes(12),cipher=createCipheriv('aes-256-gcm',createHash('sha256').update(secret).digest(),iv);cipher.setAAD(aad);
  const bytes=Buffer.concat([cipher.update(JSON.stringify(flow),'utf8'),cipher.final()]);
  return Buffer.concat([iv,cipher.getAuthTag(),bytes]).toString('base64url');
}
export function openOAuthFlow(cookie: string | undefined, state: unknown, secret: string): Flow {
  try {
    if (!cookie || cookie.length>2048 || typeof state!=='string' || !/^[A-Za-z0-9_-]{43}$/.test(state)) throw Error();
    const bytes=Buffer.from(cookie,'base64url'),decipher=createDecipheriv('aes-256-gcm',createHash('sha256').update(secret).digest(),bytes.subarray(0,12));
    decipher.setAAD(aad);decipher.setAuthTag(bytes.subarray(12,28));
    const flow=JSON.parse(Buffer.concat([decipher.update(bytes.subarray(28)),decipher.final()]).toString()) as Flow;
    if(typeof flow.state!=='string' || flow.state.length!==state.length || !timingSafeEqual(Buffer.from(flow.state),Buffer.from(state)) ||
      !/^[A-Za-z0-9_-]{64}$/.test(flow.verifier) || !Number.isFinite(flow.expiresAt) || flow.expiresAt<=Date.now() || flow.expiresAt>Date.now()+600001)throw Error();
    socialProvider(flow.provider);return flow;
  } catch { throw new AccessFailure('unauthenticated'); }
}
export function authorizeSocialUrl(backend: string, origin: string, flow: Flow) {
  const callback=new URL('/api/moderation/oauth/callback',origin);callback.searchParams.set('flow',flow.state);
  const url=new URL('/auth/v1/authorize',backend);
  url.searchParams.set('provider',flow.provider);url.searchParams.set('redirect_to',callback.href);
  url.searchParams.set('code_challenge',createHash('sha256').update(flow.verifier).digest('base64url'));
  url.searchParams.set('code_challenge_method','s256');return url.href;
}
