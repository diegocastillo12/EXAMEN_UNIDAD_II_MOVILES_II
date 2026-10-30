import { routeAccess, sessionRedirect } from '#shared/routing/route_policy';
import { CredentialFailure } from '#shared/features/access/domain/credentials';

export default defineNuxtRouteMiddleware(async to => {
  // Server middleware uses the same policy before any page HTML is generated.
  if (import.meta.server) return;
  const access = routeAccess(to.path);
  if (access === 'public') return;
  if (access === 'recovery') {
    const model = useNuxtApp().$credentialModel();
    try { await model.checkResetAccess(); }
    catch (error) { if (error instanceof CredentialFailure && error.kind === 'expired') return navigateTo('/recuperar-contrasena?reason=expired', { replace: true }); }
    finally { model.dispose(); }
    return;
  }
  const model = useNuxtApp().$accessModel();
  try {
    await model.checkSession();
    // A broadcast can invalidate preparation while this read is in flight.
    // Re-read the current identity once instead of routing on the discarded one.
    if (model.state.failure?.kind === 'conflict') await model.checkSession();
    const session = model.state.session;
    if (!session) {
      if (model.state.failure) {
        if (access === 'guest') return navigateTo('/inicio', { replace: true });
        return; // Keep the existing retry screen for connection failures.
      }
      if (access !== 'guest') return navigateTo('/iniciar-sesion', { replace: true });
      if (to.query.entry === 'checked') {
        const { entry: _, ...query } = to.query;
        return navigateTo({ path: to.path, query, hash: to.hash }, { replace: true });
      }
      return;
    }
    const destination = sessionRedirect(access, session.profile.onboardingCompleted);
    if (destination) return navigateTo(destination, { replace: true });
    if (access === 'administrator') {
      const statistics = useNuxtApp().$statisticsModel(session.actor);
      try {
        await statistics.checkAccess();
        if (statistics.state.failure === 'unauthenticated' || statistics.state.failure === 'conflict') return navigateTo('/iniciar-sesion?reason=expired', { replace: true });
        if (statistics.state.allowed === false) return navigateTo('/inicio?reason=forbidden', { replace: true });
      } finally { statistics.dispose(); }
    }
    if (access === 'reviewer') {
      await model.loadManagementAccess();
      if (model.state.canReview === false) return navigateTo('/inicio?reason=forbidden', { replace: true });
      if (!model.state.session) return navigateTo('/iniciar-sesion', { replace: true });
      // A transient permission lookup failure retains the moderation retry UI.
    }
  } finally { model.dispose(); }
});
