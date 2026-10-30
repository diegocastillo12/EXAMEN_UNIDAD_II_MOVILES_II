import '../domain/entities/found_case.dart';
import '../domain/use_cases/delete_found_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/domain/entities/auth_session.dart';
import '../domain/repositories/found_case_repository.dart';
import '../domain/use_cases/found_case_actions.dart';
import '../../lost_cases/providers/lost_case_providers.dart';
import '../domain/use_cases/recovery_report_actions.dart';
import '../domain/use_cases/read_recovery_search.dart';

final foundCaseRepositoryProvider = Provider<FoundCaseRepository>(
  (ref) => throw StateError('FoundCaseRepository must be injected'),
);
final publishFoundCaseProvider = Provider(
  (ref) => PublishFoundCase(ref.watch(foundCaseRepositoryProvider)),
);
final chooseFoundPhotoProvider = Provider(
  (ref) => ChooseFoundPhoto(ref.watch(foundCaseRepositoryProvider)),
);
final readPublicFoundCaseProvider = Provider(
  (ref) => ReadPublicFoundCase(ref.watch(foundCaseRepositoryProvider)),
);
final listMyFoundCasesProvider = Provider(
  (ref) => ListMyFoundCases(ref.watch(foundCaseRepositoryProvider)),
);
final discardFoundDraftProvider = Provider(
  (ref) => DiscardFoundDraft(ref.watch(foundCaseRepositoryProvider)),
);
final foundSessionProvider = StreamProvider.autoDispose<AuthSession?>(
  (ref) => ref.watch(watchAuthSessionProvider)(),
);

final deleteFoundPublicationProvider = Provider(
  (ref) => DeleteFoundPublication(ref.watch(foundCaseRepositoryProvider)),
);

final foundEditorContextProvider = Provider<FoundEditorContext>(
  (ref) => const FoundEditorContext(),
  dependencies: const [],
);
final listOpenRecoverySearchesProvider = Provider(
  (ref) => ListOpenRecoverySearches(ref.watch(foundCaseRepositoryProvider)),
);
final resolveRecoverySearchProvider = Provider(
  (ref) => ResolveRecoverySearch(ref.watch(foundCaseRepositoryProvider)),
);

final readRecoveryObservationsProvider = Provider(
  (ref) => ReadRecoveryObservations(ref.watch(foundCaseRepositoryProvider)),
);

final listRecoveryReportsProvider = Provider(
  (ref) => ListRecoveryReports(
    ref.watch(listMyLostCasesProvider),
    ref.watch(listMyFoundCasesProvider),
  ),
);
final readRecoverySearchProvider = Provider(
  (ref) => ReadRecoverySearch(
    ref.watch(lostCaseRepositoryProvider),
    ref.watch(foundCaseRepositoryProvider),
  ),
);
final removeRecoveryReportProvider = Provider(
  (ref) => RemoveRecoveryReport(
    ref.watch(deletePublishedLostCaseProvider),
    ref.watch(deleteFoundPublicationProvider),
    ref.watch(discardFoundDraftProvider),
  ),
);
