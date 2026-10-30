import { ExploreCases, ReadMyPets, SaveMyPet, AddPetPhoto, ReadOpenSearches, PublishRecoveryReport, ReadReportDraft, SaveReportDraft, ClearReportDraft } from '#shared/features/recovery/domain/recovery';
import { BrowserReportDraftRepository } from '#shared/features/recovery/data/browser_report_draft_repository';
import { HttpRecoveryRepository } from '#shared/features/recovery/data/http_recovery_repository';
import { RecoveryViewModel } from '#shared/features/recovery/presentation/recovery_view_model';
export default defineNuxtPlugin(() => ({ provide: { recoveryModel: (actor: string) => {
  const repository = new HttpRecoveryRepository(actor);
  const drafts = new BrowserReportDraftRepository(actor);
  return new RecoveryViewModel(new ExploreCases(repository), new ReadMyPets(repository), new SaveMyPet(repository), new AddPetPhoto(repository), new ReadOpenSearches(repository), new PublishRecoveryReport(repository), new ReadReportDraft(drafts), new SaveReportDraft(drafts), new ClearReportDraft(drafts));
} } }));
