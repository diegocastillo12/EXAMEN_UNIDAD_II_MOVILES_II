import { HttpModerationRepository } from '#shared/features/moderation/data/http_moderation_repository';
import { AccessModeration,ReviewReports,DecideReport } from '#shared/features/moderation/domain/moderation';
import { ModerationViewModel } from '#shared/features/moderation/presentation/moderation_view_model';
export default defineNuxtPlugin(()=>({provide:{moderationModel:()=>{
  const repository=new HttpModerationRepository(useNuxtApp().$accountFetch);
  return new ModerationViewModel(new AccessModeration(repository),new ReviewReports(repository),new DecideReport(repository),()=>crypto.randomUUID());
}}}));
