import { HttpMatchingRepository } from '#shared/features/matching/data/http_matching_repository';
import { FindCaseMatches, ReadMatchSearches, ReviewCaseMatch } from '#shared/features/matching/domain/matching';
import { MatchingViewModel } from '#shared/features/matching/presentation/matching_view_model';
export default defineNuxtPlugin(()=>({provide:{matchingModel:(actor:string)=>{
  const repository=new HttpMatchingRepository(actor);
  return new MatchingViewModel(new ReadMatchSearches(repository),new FindCaseMatches(repository),new ReviewCaseMatch(repository));
}}}));
