import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/case_matching_repository.dart';
import '../domain/use_cases/case_match_actions.dart';

final caseMatchingRepositoryProvider = Provider<CaseMatchingRepository>(
  (ref) => throw StateError('CaseMatchingRepository must be injected'),
);
final readMatchSearchesProvider = Provider(
  (ref) => ReadMatchSearches(ref.watch(caseMatchingRepositoryProvider)),
);
final findCaseMatchesProvider = Provider(
  (ref) => FindCaseMatches(ref.watch(caseMatchingRepositoryProvider)),
);
final reviewCaseMatchProvider = Provider(
  (ref) => ReviewCaseMatch(ref.watch(caseMatchingRepositoryProvider)),
);
