import type { H3Event } from 'h3';
import { ModerationFailure } from '../../shared/features/moderation/domain/moderation';
import { AccessAccount, AccessFailure, CompleteAccountOnboarding, ReadManagementAccess } from '../../shared/features/access/domain/access';
import { moderationConfiguration } from '../infrastructure/moderation_session';
import { openAccountSession, sealAccountSession } from '../infrastructure/account_session';
import type { PrivateAccountSession } from '../infrastructure/account_session';
import type { AccountConfig } from '../features/access/data/account_source';
import { AccountSource } from '../features/access/data/account_source';
import { ServerAccountRepository } from '../features/access/data/server_account_repository';
export const accountCookie = 'eh_access';
export function account(event: H3Event, bind = false) {
  let config;
  try { config = moderationConfiguration(process.env); } catch { throw new AccessFailure('unavailable'); }
  const session = openAccountSession(getCookie(event, accountCookie), config.sessionSecret);
  if (bind && !session) throw new AccessFailure('unauthenticated');
  if (bind && getHeader(event, 'x-account-actor') !== session?.actor) throw new AccessFailure('conflict');
  const repository = new ServerAccountRepository(new AccountSource(config), session);
  return { repository, access: new AccessAccount(repository), onboarding: new CompleteAccountOnboarding(repository), management: new ReadManagementAccess(repository),
    save() {
      const s = repository.established;
      if (!s) throw new AccessFailure('unauthenticated');
      saveAccountCookie(event, s, config);
    },
  };
}
export function saveAccountCookie(event: H3Event, session: PrivateAccountSession, config: AccountConfig) {
  const sealed = sealAccountSession(session, config.sessionSecret);
  if (sealed.length > 3800) throw new AccessFailure('unavailable');
  deleteCookie(event, accountCookie, { path: '/api', httpOnly: true, secure: config.secure, sameSite: 'strict' });
  setCookie(event, accountCookie, sealed, { httpOnly: true, secure: config.secure, sameSite: 'strict', path: '/', maxAge: Math.max(1, Math.floor((session.expiresAt - Date.now()) / 1000)) });
}
export function clearAccountCookie(event: H3Event) {
  for (const path of ['/', '/api']) deleteCookie(event, accountCookie, { path, httpOnly: true, sameSite: 'strict', secure: process.env.PUBLIC_WEB_ORIGIN?.startsWith('https://') === true });
}
export function accountError(event: H3Event, error: unknown) {
  const kind = error instanceof AccessFailure || error instanceof ModerationFailure ? error.kind : 'unavailable';
  if (kind === 'unauthenticated') clearAccountCookie(event);
  setResponseStatus(event, kind === 'unauthenticated' ? 401 : kind === 'forbidden' ? 403 : kind === 'conflict' ? 409 : kind === 'invalid' ? 422 : 503);
  return { error: kind };
}

