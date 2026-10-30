import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/local_draft_repository.dart';
import '../domain/use_cases/local_draft_actions.dart';
import '../../auth/providers/auth_providers.dart';

final cancelLocalSubmissionProvider = Provider(
  (ref) => CancelLocalSubmission(ref.watch(localDraftRepositoryProvider)),
);

final localDraftSessionProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(watchAuthSessionProvider)(),
);
final listLocalDraftsProvider = Provider(
  (ref) => ListLocalDrafts(ref.watch(localDraftRepositoryProvider)),
);

final localDraftRepositoryProvider = Provider<LocalDraftRepository>(
  (ref) => throw StateError('LocalDraftRepository must be injected.'),
);
final readLocalDraftProvider = Provider(
  (ref) => ReadLocalDraft(ref.watch(localDraftRepositoryProvider)),
);
final saveLocalDraftProvider = Provider(
  (ref) => SaveLocalDraft(ref.watch(localDraftRepositoryProvider)),
);
final removeLocalDraftProvider = Provider(
  (ref) => RemoveLocalDraft(ref.watch(localDraftRepositoryProvider)),
);
