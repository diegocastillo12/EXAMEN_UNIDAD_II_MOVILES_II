import '../entities/case_match.dart';
import '../repositories/case_matching_repository.dart';

class ReadMatchSearches {
  const ReadMatchSearches(this.repository);
  final CaseMatchingRepository repository;
  Future<List<MatchSearch>> call(String owner) {
    if (owner.isEmpty) throw const MatchFailure(MatchIssue.forbidden);
    return repository.searches(owner);
  }
}

class FindCaseMatches {
  const FindCaseMatches(this.repository);
  final CaseMatchingRepository repository;
  Future<CaseMatchResult> call(String owner, MatchReference reference) {
    validateMatchReference(reference);
    if (owner.isEmpty) throw const MatchFailure(MatchIssue.forbidden);
    return repository.search(owner, reference);
  }
}

void validateMatchReference(MatchReference r) {
  if (!{'lost', 'found'}.contains(r.source) ||
      !RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        caseSensitive: false,
      ).hasMatch(r.id)) {
    throw const MatchFailure(MatchIssue.invalid);
  }
}

class ReviewCaseMatch {
  const ReviewCaseMatch(this.repository);
  final CaseMatchingRepository repository;
  Future<void> call(String owner, MatchReviewCommand command) {
    validateMatchReference(command.result.anchor);
    validateMatchReference(command.candidate.reference);
    if (owner.isEmpty) throw const MatchFailure(MatchIssue.forbidden);
    if (command.id.isEmpty ||
        !{'confirmed', 'dismissed'}.contains(command.decision) ||
        command.result.model != 'clip-vit-b32-d15189d-q8-v1' ||
        !command.result.candidates.contains(command.candidate)) {
      throw const MatchFailure(MatchIssue.invalid);
    }
    return repository.review(owner, command);
  }
}
