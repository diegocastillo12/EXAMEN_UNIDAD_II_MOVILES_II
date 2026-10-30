import '../../domain/entities/case_match.dart';
import '../../domain/repositories/case_matching_repository.dart';
import '../data_sources/matching_source.dart';
import '../models/case_match_dto.dart';

class CaseMatchingRepositoryImpl implements CaseMatchingRepository {
  const CaseMatchingRepositoryImpl(this.source);
  final MatchingSource source;
  @override
  Future<List<MatchSearch>> searches(String owner) async {
    try {
      return CaseMatchDto.searches(await source.call(owner, 'searches', {}));
    } on MatchFailure {
      rethrow;
    } catch (_) {
      throw const MatchFailure(MatchIssue.unavailable);
    }
  }

  @override
  Future<CaseMatchResult> search(String owner, MatchReference ref) async {
    try {
      final value = CaseMatchDto.result(
        await source.call(owner, 'search', {
          'source': ref.source,
          'id': ref.id,
        }),
      );
      if (value.anchor.key != ref.key) {
        throw const MatchFailure(MatchIssue.unavailable);
      }
      return value;
    } on MatchFailure {
      rethrow;
    } catch (_) {
      throw const MatchFailure(MatchIssue.unavailable);
    }
  }

  @override
  Future<void> review(String owner, MatchReviewCommand c) async {
    final value = await source.call(owner, 'review', {
      'id': c.id,
      'anchor': {'source': c.result.anchor.source, 'id': c.result.anchor.id},
      'anchorRevision': c.result.revision,
      'candidate': {
        'source': c.candidate.reference.source,
        'id': c.candidate.reference.id,
      },
      'candidateRevision': c.candidate.revision,
      'decision': c.decision,
      'model': c.result.model,
    });
    if (value is! Map || value['saved'] != true) {
      throw const MatchFailure(MatchIssue.unavailable);
    }
  }
}
