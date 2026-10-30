import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/saved_case_ref.dart';
import '../../domain/failures/saved_case_failure.dart';
import '../../providers/saved_cases_providers.dart';
import '../state/saved_case_state.dart';

final savedCaseViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<SavedCaseViewModel, SavedCaseState, SavedCaseRef>(
      SavedCaseViewModel.new,
      retry: (_, _) => null,
    );

class SavedCaseViewModel extends AsyncNotifier<SavedCaseState> {
  SavedCaseViewModel(this.target);
  final SavedCaseRef target;
  int _generation = 0;
  ({bool saved, int version})? _pending;

  @override
  Future<SavedCaseState> build() async {
    final generation = ++_generation;
    _pending = null;
    ref.onDispose(() {
      _generation++;
      _pending = null;
    });
    final session = await ref.watch(savedCasesSessionProvider.future);
    if (session == null || !ref.mounted || generation != _generation) {
      throw const SavedCaseFailure(SavedCaseFailureKind.forbidden);
    }
    final mark = await ref.read(readSavedCaseProvider)(session.userId, target);
    return SavedCaseState(owner: session.userId, mark: mark);
  }

  void retry() => ref.invalidateSelf();

  Future<void> toggle() async {
    final old = state.isLoading ? null : state.asData?.value;
    if (old == null || old.busy) return;
    if (old.reloadRequired) {
      retry();
      return;
    }
    final desired =
        _pending ?? (saved: !old.mark.saved, version: old.mark.version);
    _pending = desired;
    final generation = ++_generation;
    state = AsyncData(
      SavedCaseState(
        owner: old.owner,
        mark: old.mark,
        busy: true,
        noticeId: old.noticeId,
      ),
    );
    try {
      final mark = await ref.read(setSavedCaseProvider)(
        old.owner,
        target,
        saved: desired.saved,
        expectedVersion: desired.version,
      );
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      _pending = null;
      state = AsyncData(
        SavedCaseState(
          owner: old.owner,
          mark: mark,
          notice: mark.saved ? 'Caso guardado' : 'Caso quitado de guardados',
          noticeId: old.noticeId + 1,
        ),
      );
    } catch (error) {
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      final kind = error is SavedCaseFailure
          ? error.kind
          : SavedCaseFailureKind.unavailable;
      final reload = kind != SavedCaseFailureKind.unavailable;
      if (reload) _pending = null;
      state = AsyncData(
        SavedCaseState(
          owner: old.owner,
          mark: old.mark,
          error: true,
          reloadRequired: reload,
          noticeId: old.noticeId + 1,
          notice: switch (kind) {
            SavedCaseFailureKind.conflict =>
              'El guardado cambió en otro dispositivo. Consulta de nuevo para continuar.',
            SavedCaseFailureKind.hidden =>
              'Este caso ya no está disponible para guardarlo.',
            SavedCaseFailureKind.forbidden =>
              'No pudimos verificar tu sesión. Vuelve a consultar el guardado.',
            _ =>
              'No pudimos confirmar el cambio. Toca el marcador para reintentar.',
          },
        ),
      );
    }
  }
}
