import { HttpAppealsRepository } from '#shared/features/appeals/data/http_appeals_repository';
import { ReadAppeals, SubmitAppeal, AnswerAppeal } from '#shared/features/appeals/domain/appeals';
import { AppealsViewModel } from '#shared/features/appeals/presentation/appeals_view_model';
export default defineNuxtPlugin(() => ({ provide: { appealsModel: (actor: string, review = false) => {
  const repository = new HttpAppealsRepository(actor);
  return new AppealsViewModel(new ReadAppeals(repository), new SubmitAppeal(repository), new AnswerAppeal(repository), review, () => crypto.randomUUID());
} } }));
