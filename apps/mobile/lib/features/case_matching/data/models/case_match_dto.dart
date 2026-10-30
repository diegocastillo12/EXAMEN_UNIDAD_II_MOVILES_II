import '../../domain/entities/case_match.dart';
import '../../domain/use_cases/case_match_actions.dart';

class CaseMatchDto {
  static MatchReference reference(dynamic row) {
    final r = MatchReference(row['source'] as String, row['id'] as String);
    validateMatchReference(r);
    return r;
  }

  static List<MatchSearch> searches(dynamic value) {
    if (value is! List || value.length > 100) {
      throw const MatchFailure(MatchIssue.unavailable);
    }
    return value
        .map(
          (r) => MatchSearch(
            reference(r['ref']),
            r['name'] as String,
            r['species'] as String,
          ),
        )
        .toList();
  }

  static CaseMatchResult result(dynamic r) {
    if (r is! Map ||
        r['model'] != 'clip-vit-b32-d15189d-q8-v1' ||
        r['complete'] is! bool ||
        r['pendingPhotos'] is! int ||
        r['pendingPhotos'] < 0 ||
        r['pendingPhotos'] > 303 ||
        r['candidates'] is! List ||
        (r['candidates'] as List).length > 5 ||
        !RegExp(r'^[0-9a-f]{32}$').hasMatch(r['revision'] as String)) {
      throw const MatchFailure(MatchIssue.unavailable);
    }
    return CaseMatchResult(
      anchor: reference(r['anchor']),
      revision: r['revision'] as String,
      model: r['model'] as String,
      pendingPhotos: r['pendingPhotos'] as int,
      complete: r['complete'] as bool,
      candidates: [for (final c in r['candidates'] as List) _candidate(c)],
    );
  }

  static CaseMatchCandidate _candidate(dynamic c) {
    if (c['distanceMeters'] is! int ||
        c['distanceMeters'] < 0 ||
        c['daysApart'] is! int ||
        c['daysApart'] < 0 ||
        !{null, 'confirmed', 'dismissed'}.contains(c['review']) ||
        !RegExp(r'^[0-9a-f]{32}$').hasMatch(c['revision'] as String)) {
      throw const MatchFailure(MatchIssue.unavailable);
    }
    return CaseMatchCandidate(
      reference: reference(c['ref']),
      revision: c['revision'] as String,
      name: c['name'] as String,
      distanceMeters: c['distanceMeters'] as int,
      daysApart: c['daysApart'] as int,
      review: c['review'] as String?,
    );
  }
}
