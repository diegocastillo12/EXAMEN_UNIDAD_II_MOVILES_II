import type { H3Event } from 'h3';
import { CredentialFailure, RegisterAccount, RequestPasswordRecovery, VerifyAccountCode, ResendAccountCode, ResetAccountPassword, ReadCredentialProgress, CancelCredentialFlow } from '../../shared/features/access/domain/credentials';
import { moderationConfiguration } from '../infrastructure/moderation_session';
import { credentialCookie, openCredentialFlow, sealCredentialFlow } from '../infrastructure/credential_flow';
import { AccountSource } from '../features/access/data/account_source';
import { CredentialSource } from '../features/access/data/credential_source';
import { ServerCredentialRepository } from '../features/access/data/server_credential_repository';
import { accountCookie, saveAccountCookie } from './account';
import { clearModerationCookie } from './moderation';

export function credentials(event: H3Event) {
  let config; try { config = moderationConfiguration(process.env); } catch { throw new CredentialFailure('unavailable'); }
  const repository = new ServerCredentialRepository(new CredentialSource(config), new AccountSource(config), openCredentialFlow(getCookie(event, credentialCookie), config.sessionSecret));
  return { repository, register: new RegisterAccount(repository), recover: new RequestPasswordRecovery(repository), verify: new VerifyAccountCode(repository), resend: new ResendAccountCode(repository),
    reset: new ResetAccountPassword(repository), read: new ReadCredentialProgress(repository), cancel: new CancelCredentialFlow(repository),
    assertGuest() { if (getCookie(event, accountCookie)) throw new CredentialFailure('conflict'); },
    save() {
      if (repository.flow) {
        const value = sealCredentialFlow(repository.flow, config.sessionSecret);
        if (value.length > 3800) throw new CredentialFailure('unavailable');
        setCookie(event, credentialCookie, value, { httpOnly: true, secure: config.secure, sameSite: 'strict', path: '/', maxAge: Math.max(1, Math.floor((repository.flow.expiresAt - Date.now()) / 1000)) });
      } else clearCredentialCookie(event);
      if (repository.established) { clearModerationCookie(event); saveAccountCookie(event, repository.established, config); }
    },
  };
}
export function clearCredentialCookie(event: H3Event) {
  deleteCookie(event, credentialCookie, { path: '/', httpOnly: true, sameSite: 'strict', secure: process.env.PUBLIC_WEB_ORIGIN?.startsWith('https://') === true });
}
export function credentialError(event: H3Event, error: unknown) {
  const kind = error instanceof CredentialFailure ? error.kind : 'unavailable';
  if (kind === 'expired') clearCredentialCookie(event);
  if (kind === 'rate_limited') setHeader(event, 'Retry-After', 60);
  setResponseStatus(event, kind === 'expired' ? 401 : kind === 'rate_limited' ? 429 : kind === 'conflict' ? 409 : kind === 'unavailable' ? 503 : 422);
  return { error: kind };
}
