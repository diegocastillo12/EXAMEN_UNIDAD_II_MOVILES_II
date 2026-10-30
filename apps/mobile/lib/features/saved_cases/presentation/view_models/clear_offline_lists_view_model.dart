import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/saved_cases_providers.dart';
import 'saved_case_list_view_model.dart';

class ClearOfflineListsState {
  const ClearOfflineListsState({
    this.busy = false,
    this.message,
    this.error = false,
    this.revision = 0,
    this.canClear = false,
  });
  final bool busy, error, canClear;
  final String? message;
  final int revision;
}

final clearOfflineListsViewModelProvider =
    NotifierProvider.autoDispose<
      ClearOfflineListsViewModel,
      ClearOfflineListsState
    >(ClearOfflineListsViewModel.new);

class ClearOfflineListsViewModel extends Notifier<ClearOfflineListsState> {
  String? _actor;
  int _generation = 0;
  @override
  ClearOfflineListsState build() {
    _generation++;
    _actor = ref.watch(savedCasesSessionProvider).asData?.value?.userId;
    ref.onDispose(() => _generation++);
    return ClearOfflineListsState(canClear: _actor != null);
  }

  Future<void> clear() async {
    if (state.busy || _actor == null) return;
    final actor = _actor!;
    final generation = _generation;
    final revision = state.revision + 1;
    state = ClearOfflineListsState(
      busy: true,
      revision: revision,
      canClear: true,
    );
    try {
      final clear = ref.read(clearOfflineListsProvider);
      if (clear == null) throw StateError('Unavailable');
      await clear(actor);
      if (!ref.mounted || generation != _generation) return;
      ref.invalidate(savedCaseListViewModelProvider);
      state = ClearOfflineListsState(
        revision: revision,
        canClear: true,
        message: 'Listas sin conexión y claves eliminadas de este teléfono.',
      );
    } catch (_) {
      if (!ref.mounted || generation != _generation) return;
      state = ClearOfflineListsState(
        error: true,
        revision: revision,
        canClear: true,
        message: 'No pudimos borrar los datos locales. Reintenta.',
      );
    }
  }
}
