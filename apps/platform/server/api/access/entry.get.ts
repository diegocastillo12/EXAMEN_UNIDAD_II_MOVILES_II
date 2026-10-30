import { account, accountCookie, clearAccountCookie } from '../../utils/account';
import { AccessFailure } from '../../../shared/features/access/domain/access';
import { entryDestination, routeAccess, sessionRedirect } from '../../../shared/routing/route_policy';

export default defineEventHandler(async event => {
  const query = getRequestURL(event).searchParams;
  const requested = entryDestination(query.get('destination'));
  query.delete('destination');
  if (getCookie(event, accountCookie)) {
    try {
      const services = account(event);
      const session = await services.access.session();
      services.save();
      const destination = requested || '/iniciar-sesion';
      return sendRedirect(event, sessionRedirect(routeAccess(destination), session.profile.onboardingCompleted) || destination, 302);
    } catch (error) {
      if (!(error instanceof AccessFailure) || error.kind !== 'unauthenticated') return sendRedirect(event, '/inicio?entry=unavailable', 302);
      clearAccountCookie(event);
    }
  }
  query.set('entry', 'checked');
  return sendRedirect(event, (requested && routeAccess(requested) === 'guest' ? requested : '/iniciar-sesion') + '?' + query.toString(), 302);
});
