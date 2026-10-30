import { AccessAccount, CompleteAccountOnboarding, ReadManagementAccess, StartAccountSocialSignIn } from '#shared/features/access/domain/access';
import { HttpAccountRepository } from '#shared/features/access/data/http_account_repository';
import { AccountViewModel } from '#shared/features/access/presentation/account_view_model';
import { AccountSessionTransport } from '#shared/features/access/data/account_session_transport';
export default defineNuxtPlugin(app => {
  const transport = new AccountSessionTransport();
  if (import.meta.client) {
    const channel = new BroadcastChannel('eh-access');
    channel.onmessage = () => transport.invalidate();
    const invalidate = () => transport.invalidate();
    window.addEventListener('focus', invalidate);
    document.addEventListener('visibilitychange', invalidate);
    useNuxtApp().vueApp.onUnmount(() => { channel.close(); window.removeEventListener('focus', invalidate); document.removeEventListener('visibilitychange', invalidate); transport.invalidate(); });
  }
  return { provide: { accountFetch: transport.fetch, accessModel: () => {
  // First hydration must match the server skeleton; only subsequent client
  // navigations can mount directly from the identity checked by the guard.
  const prepared = import.meta.client && !app.isHydrating ? transport.preparedSession() : null;
  const repository = new HttpAccountRepository(transport.fetch, prepared?.actor);
  return new AccountViewModel(new AccessAccount(repository), new StartAccountSocialSignIn(repository), new CompleteAccountOnboarding(repository), new ReadManagementAccess(repository), prepared);
} } };
});

