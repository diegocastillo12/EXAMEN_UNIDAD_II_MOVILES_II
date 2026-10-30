import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/local_report_draft.dart';
import '../../providers/local_draft_providers.dart';

final localDraftsViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      LocalDraftsViewModel,
      List<LocalReportDraft>
    >(LocalDraftsViewModel.new, retry: (_, _) => null);

class LocalDraftsViewModel extends AsyncNotifier<List<LocalReportDraft>> {
  @override
  Future<List<LocalReportDraft>> build() async {
    final session = await ref.watch(localDraftSessionProvider.future);
    if (session == null) throw const LocalDraftFailure();
    return ref.read(listLocalDraftsProvider)(session.userId);
  }

  void reload() {
    if (ref.mounted) ref.invalidateSelf();
  }
}
