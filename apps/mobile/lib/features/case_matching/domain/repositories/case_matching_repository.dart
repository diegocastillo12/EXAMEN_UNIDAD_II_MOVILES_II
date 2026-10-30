import '../entities/case_match.dart';

abstract interface class CaseMatchingRepository {
  Future<List<MatchSearch>> searches(String owner);
  Future<CaseMatchResult> search(String owner, MatchReference reference);
  Future<void> review(String owner, MatchReviewCommand command);
}
