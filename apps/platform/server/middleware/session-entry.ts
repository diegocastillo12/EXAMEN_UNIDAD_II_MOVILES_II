import { account, accountCookie, clearAccountCookie } from '../utils/account';
import { AccessFailure } from '../../shared/features/access/domain/access';
import { routeAccess, sessionRedirect } from '../../shared/routing/route_policy';
import { credentials, clearCredentialCookie } from '../utils/credentials';
import { CredentialFailure } from '../../shared/features/access/domain/credentials';
import { statistics } from '../utils/statistics';

export default defineEventHandler(async event => {
  const url = getRequestURL(event);
  if (!['GET', 'HEAD'].includes(event.method)) return;
  const access = routeAccess(url.pathname);
  if (access === 'public') return;
  if (access === 'recovery') {
    try { await credentials(event).read.resetAccess(); }
    catch (error) {
      if (error instanceof CredentialFailure && error.kind === 'expired') { clearCredentialCookie(event); return sendRedirect(event, '/recuperar-contrasena?reason=expired', 302); }
      // Only the existing retry UI can render on backend failure, never password inputs.
    }
    return;
  }
  const login = access === 'guest';
  if (!getCookie(event, accountCookie)) {
    // Older sessions are scoped to /api and can only be recovered there.
    // This marker only terminates the anonymous redirect, never authorizes access.
    if (login && url.searchParams.get('entry') === 'checked') return;
    // A failed legacy lookup can render the existing retry shell, never data.
    if (!login && url.searchParams.get('entry') === 'unavailable') return;
    if (!login || url.pathname !== '/iniciar-sesion') url.searchParams.set('destination', url.pathname);
    return sendRedirect(event, '/api/access/entry' + url.search, 302);
  }
  try {
    const services = account(event);
    const session = await services.access.session();
    const destination = sessionRedirect(access, session.profile.onboardingCompleted);
    if (destination) return sendRedirect(event, destination, 302);
    if (access === 'reviewer' && !await services.management.execute()) return sendRedirect(event, '/inicio?reason=forbidden', 302);
    if (access === 'administrator' && !await (await statistics(event, false)).access.execute()) return sendRedirect(event, '/inicio?reason=forbidden', 302);
  } catch (error) {
    if (error instanceof AccessFailure && error.kind === 'unauthenticated') {
      clearAccountCookie(event);
      if (!login) return sendRedirect(event, '/iniciar-sesion?entry=checked&reason=expired', 302);
      return;
    }
    // Preserve the existing retry screen for backend failure, rather than
    // presenting credentials as though the user had signed out.
    if (login) return sendRedirect(event, '/inicio', 302);
  }
});
