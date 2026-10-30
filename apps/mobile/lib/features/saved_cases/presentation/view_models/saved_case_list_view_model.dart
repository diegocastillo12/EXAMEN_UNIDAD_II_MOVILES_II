import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/failures/saved_case_failure.dart';
import '../../providers/saved_cases_providers.dart';
import '../state/saved_case_list_state.dart';
import '../../../offline_cases/providers/case_cache_providers.dart';

final savedCaseListViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      SavedCaseListViewModel,
      SavedCaseListState
    >(SavedCaseListViewModel.new, retry: (_, _) => null);

class SavedCaseListViewModel extends AsyncNotifier<SavedCaseListState> {
  int _generation = 0;
  bool _failedAppend = false;
  @override
  Future<SavedCaseListState> build() async {
    _generation++;
    ref.onDispose(() => _generation++);
    final session = await ref.watch(savedCasesSessionProvider.future);
    if (session == null) {
      throw const SavedCaseFailure(SavedCaseFailureKind.forbidden);
    }
    try {
      final page = await ref.read(listSavedCasesProvider)(session.userId);
      return SavedCaseListState(
        owner: session.userId,
        items: page.items,
        cursor: page.cursor,
      );
    } on SavedCaseFailure catch (error) {
      if (error.kind != SavedCaseFailureKind.unavailable) rethrow;
      final offlineRead = await _readOffline(session.userId);
      if (offlineRead.snapshot != null) return offlineRead.snapshot!;
      if (offlineRead.corrupted) return _unavailableLocalData(session.userId);
      final local = await ref
          .read(listCachedCasesProvider)
          ?.call(session.userId);
      if (local == null || local.isEmpty) rethrow;
      return SavedCaseListState(
        owner: session.userId,
        items: const [],
        offline: true,
      );
    }
  }

  Future<void> refresh() async {
    final current = state.isLoading ? null : state.asData?.value;
    if (current == null) {
      ref.invalidateSelf();
      return;
    }
    if (!current.busy) await _load(current, false);
  }

  Future<void> more() async {
    final current = state.isLoading ? null : state.asData?.value;
    if (current == null || current.busy || current.cursor == null) return;
    await _load(current, true);
  }

  Future<void> retry() => _failedAppend ? more() : refresh();

  Future<_OfflineRead> _readOffline(String owner) async {
    try {
      final items = await ref.read(readListOfflineProvider)?.call(owner);
      return _OfflineRead(
        snapshot: items == null
            ? null
            : SavedCaseListState(owner: owner, items: items, offline: true),
      );
    } catch (_) {
      return const _OfflineRead(corrupted: true);
    }
  }

  SavedCaseListState _unavailableLocalData(String owner) => SavedCaseListState(
    owner: owner,
    items: const [],
    offline: true,
    localUnavailable: true,
    notice: 'Datos locales no disponibles, conéctese para actualizar',
    noticeId: 1,
  );

  Future<void> saveOffline() async {
    final current = state.asData?.value;
    final save = ref.read(saveListOfflineProvider);
    if (current == null ||
        current.busy ||
        current.offline ||
        current.items.isEmpty ||
        save == null) {
      return;
    }
    final generation = _generation;
    state = AsyncData(current.savingNotice(saving: true));
    try {
      await save(current.owner, current.items);
      if (!ref.mounted || generation != _generation) return;
      state = AsyncData(
        current.savingNotice(
          saving: false,
          noticeIsError: false,
          notice: 'Lista guardada sin conexión en este teléfono.',
        ),
      );
    } catch (_) {
      if (!ref.mounted || generation != _generation) return;
      state = AsyncData(
        current.savingNotice(
          saving: false,
          notice: 'No pudimos guardar la lista. Reintenta.',
        ),
      );
    }
  }

  Future<void> _load(SavedCaseListState old, bool append) async {
    final generation = ++_generation;
    _failedAppend = append;
    state = AsyncData(
      SavedCaseListState(
        owner: old.owner,
        items: old.items,
        cursor: old.cursor,
        refreshing: !append,
        appending: append,
        noticeId: old.noticeId,
        offline: old.offline,
      ),
    );
    try {
      final page = await ref.read(listSavedCasesProvider)(
        old.owner,
        cursor: append ? old.cursor : null,
      );
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      if (append && page.cursor == old.cursor) {
        throw const SavedCaseFailure(SavedCaseFailureKind.unavailable);
      }
      state = AsyncData(
        SavedCaseListState(
          owner: old.owner,
          items: append
              ? [
                  ...old.items,
                  ...page.items.where(
                    (item) => !old.items.any((prior) => prior.key == item.key),
                  ),
                ]
              : page.items,
          cursor: page.cursor,
          noticeId: old.noticeId,
        ),
      );
    } catch (error) {
      final offlineRead =
          error is SavedCaseFailure &&
              error.kind == SavedCaseFailureKind.unavailable &&
              !append
          ? await _readOffline(old.owner)
          : const _OfflineRead();
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      if (offlineRead.snapshot != null) {
        state = AsyncData(offlineRead.snapshot!);
        return;
      }
      if (offlineRead.corrupted) {
        state = AsyncData(_unavailableLocalData(old.owner));
        return;
      }
      state = AsyncData(
        SavedCaseListState(
          owner: old.owner,
          items: old.items,
          cursor: old.cursor,
          failed: true,
          offline: old.offline,
          notice:
              'No pudimos consultar tus casos guardados. Puedes reintentar.',
          noticeId: old.noticeId + 1,
        ),
      );
    }
  }
}

class _OfflineRead {
  const _OfflineRead({this.snapshot, this.corrupted = false});
  final SavedCaseListState? snapshot;
  final bool corrupted;
}
