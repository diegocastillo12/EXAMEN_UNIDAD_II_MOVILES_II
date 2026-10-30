import '../../domain/entities/case_match.dart';
import '../../domain/repositories/case_matching_repository.dart';

class UnavailableCaseMatchingRepository implements CaseMatchingRepository {
  const UnavailableCaseMatchingRepository();
  @override
  Future<List<MatchSearch>> searches(String owner) async =>
      throw const MatchFailure(MatchIssue.unavailable);
  @override
  Future<CaseMatchResult> search(
    String owner,
    MatchReference reference,
  ) async => throw const MatchFailure(MatchIssue.unavailable);
  @override
  Future<void> review(String owner, MatchReviewCommand command) async =>
      throw const MatchFailure(MatchIssue.unavailable);
}
