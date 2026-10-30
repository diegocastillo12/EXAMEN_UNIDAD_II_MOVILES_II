import { account, accountError, clearAccountCookie } from '../../utils/account';
import { moderationBody, clearModerationCookie } from '../../utils/moderation';
import { AccessFailure } from '../../../shared/features/access/domain/access';
import { clearCredentialCookie } from '../../utils/credentials';
export default defineEventHandler(async event => {
  clearAccountCookie(event); clearModerationCookie(event);
  clearCredentialCookie(event);
  try {
    const body = await moderationBody(event);
    if (typeof body.email !== 'string' || typeof body.password !== 'string') throw new AccessFailure('invalid');
    const services = account(event), session = await services.access.login(body.email, body.password);
    services.save(); return session;
  } catch (error) { return accountError(event, error); }
});

