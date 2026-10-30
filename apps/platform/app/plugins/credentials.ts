import { RegisterAccount, RequestPasswordRecovery, VerifyAccountCode, ResendAccountCode, ResetAccountPassword, ReadCredentialProgress, CancelCredentialFlow } from '#shared/features/access/domain/credentials';
import { HttpCredentialRepository } from '#shared/features/access/data/http_credential_repository';
import { CredentialViewModel } from '#shared/features/access/presentation/credential_view_model';
export default defineNuxtPlugin(() => ({ provide: { credentialModel: () => {
  const repository = new HttpCredentialRepository(useNuxtApp().$accountFetch);
  return new CredentialViewModel(new RegisterAccount(repository), new RequestPasswordRecovery(repository), new VerifyAccountCode(repository), new ResendAccountCode(repository), new ResetAccountPassword(repository), new ReadCredentialProgress(repository), new CancelCredentialFlow(repository));
} } }));
