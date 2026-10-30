import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/entities/auth_session.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/case_timeline_repository.dart';
import '../domain/use_cases/timeline_actions.dart';

final caseTimelineRepositoryProvider = Provider<CaseTimelineRepository>(
  (ref) => throw StateError('CaseTimelineRepository must be injected'),
);
final timelineSessionProvider = StreamProvider.autoDispose<AuthSession?>(
  (ref) => ref.watch(watchAuthSessionProvider)(),
  retry: (_, _) => null,
);
final readTimelineAccessProvider = Provider(
  (ref) => ReadTimelineAccess(ref.watch(caseTimelineRepositoryProvider)),
);
final readCaseTimelineProvider = Provider(
  (ref) => ReadCaseTimeline(ref.watch(caseTimelineRepositoryProvider)),
);
final readSightingReviewProvider = Provider(
  (ref) => ReadSightingReview(ref.watch(caseTimelineRepositoryProvider)),
);
final readSightingEvidenceProvider = Provider(
  (ref) => ReadSightingEvidence(ref.watch(caseTimelineRepositoryProvider)),
);
final reviewSightingProvider = Provider(
  (ref) => ReviewSighting(ref.watch(caseTimelineRepositoryProvider)),
);
