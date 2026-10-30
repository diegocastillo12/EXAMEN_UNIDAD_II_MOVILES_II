import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/entities/auth_session.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/saved_cases_repository.dart';
import '../domain/use_cases/read_saved_case.dart';
import '../domain/use_cases/set_saved_case.dart';
import '../domain/use_cases/list_saved_cases.dart';
import '../domain/repositories/saved_list_file_repository.dart';
import '../domain/use_cases/save_list_offline.dart';

final savedListFileRepositoryProvider = Provider<SavedListFileRepository?>(
  (ref) => null,
);
final saveListOfflineProvider = Provider((ref) {
  final repository = ref.watch(savedListFileRepositoryProvider);
  return repository == null ? null : SaveListOffline(repository);
});
final readListOfflineProvider = Provider((ref) {
  final repository = ref.watch(savedListFileRepositoryProvider);
  return repository == null ? null : ReadListOffline(repository);
});
final clearOfflineListsProvider = Provider((ref) {
  final repository = ref.watch(savedListFileRepositoryProvider);
  return repository == null ? null : ClearOfflineLists(repository);
});

final listSavedCasesProvider = Provider(
  (ref) => ListSavedCases(ref.watch(savedCasesRepositoryProvider)),
);

final savedCasesRepositoryProvider = Provider<SavedCasesRepository>(
  (ref) => throw StateError('SavedCasesRepository must be injected'),
);
final readSavedCaseProvider = Provider(
  (ref) => ReadSavedCase(ref.watch(savedCasesRepositoryProvider)),
);
final setSavedCaseProvider = Provider(
  (ref) => SetSavedCase(ref.watch(savedCasesRepositoryProvider)),
);
final savedCasesSessionProvider = StreamProvider.autoDispose<AuthSession?>(
  (ref) => ref.watch(watchAuthSessionProvider)(),
  retry: (_, _) => null,
);
