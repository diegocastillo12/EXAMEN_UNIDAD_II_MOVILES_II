import { account, clearAccountCookie } from '../../utils/account';
import { clearModerationCookie } from '../../utils/moderation';
import { clearCredentialCookie } from '../../utils/credentials';
export default defineEventHandler(event => {
  clearAccountCookie(event);
  clearModerationCookie(event);
  clearCredentialCookie(event);
  try {
    const services = account(event);
    event.waitUntil(services.access.logout().catch(() => { console.warn('[access] Remote sign-out did not complete.'); }));
  } catch { console.warn('[access] Remote sign-out could not be scheduled.'); }
  return { signedOut: true };
});

