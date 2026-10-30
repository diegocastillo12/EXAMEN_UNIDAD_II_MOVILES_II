import { account } from '../../../utils/account';
import { clearModerationCookie } from '../../../utils/moderation';
import { moderationConfiguration } from '../../../infrastructure/moderation_session';
import { oauthCookie, oauthCookiePath, openOAuthFlow } from '../../../infrastructure/social_oauth';
import { CompleteAccountSocialSignIn } from '../../../../shared/features/access/domain/access';
import { clearCredentialCookie } from '../../../utils/credentials';
export default defineEventHandler(async event => {
  const cookie = getCookie(event, oauthCookie), query = getQuery(event);
  deleteCookie(event, oauthCookie, { path: oauthCookiePath, httpOnly: true, sameSite: 'lax', secure: process.env.PUBLIC_WEB_ORIGIN?.startsWith('https://') === true });
  let destination = '/iniciar-sesion?reason=oauth-failed';
  try {
    const config = moderationConfiguration(process.env), flow = openOAuthFlow(cookie, query.flow, config.sessionSecret);
    if (query.error) { if (query.error === 'access_denied') destination = '/iniciar-sesion?reason=oauth-cancelled'; }
    else {
      const services = account(event);
      const session = await new CompleteAccountSocialSignIn(services.repository).execute(typeof query.code === 'string' ? query.code : '', flow.verifier);
      services.save(); clearModerationCookie(event); clearCredentialCookie(event);
      destination = session.profile.onboardingCompleted ? '/inicio' : '/bienvenida';
    }
  } catch { /* Never expose provider errors, codes or tokens. */ }
  return sendRedirect(event, destination, 303);
});
