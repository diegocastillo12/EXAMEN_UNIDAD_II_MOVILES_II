import type { H3Event } from 'h3';
import { moderationBody } from './moderation';
import { accountError } from './account';
import { moderationConfiguration } from '../infrastructure/moderation_session';
import { authorizeSocialUrl, newOAuthFlow, sealOAuthFlow, oauthCookie, oauthCookiePath } from '../infrastructure/social_oauth';
export async function startAccountOAuth(event: H3Event) {
  try {
    const body = await moderationBody(event);
    const config = moderationConfiguration(process.env);
    const origin = process.env.PUBLIC_WEB_ORIGIN || (import.meta.dev ? getRequestURL(event).origin : 'https://entrehuellas.app');
    const flow = newOAuthFlow(body.provider);
    setCookie(event, oauthCookie, sealOAuthFlow(flow, config.sessionSecret), { httpOnly: true, secure: origin.startsWith('https://'), sameSite: 'lax', path: oauthCookiePath, maxAge: 600 });
    return { url: authorizeSocialUrl(config.url, origin, flow) };
  } catch (error) { return accountError(event, error); }
}

