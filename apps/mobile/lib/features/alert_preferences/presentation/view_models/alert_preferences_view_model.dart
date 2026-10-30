import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/failures/preference_failure.dart';
import '../../providers/alert_preference_providers.dart';
import '../state/preference_view_state.dart';

final alertPreferencesViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      AlertPreferencesViewModel,
      PreferenceViewState
    >(AlertPreferencesViewModel.new, retry: (_, _) => null);

class AlertPreferencesViewModel extends AsyncNotifier<PreferenceViewState> {
  int _generation = 0;
  int _noticeId = 0;
  @override
  Future<PreferenceViewState> build() async {
    _generation++;
    final read = ref.watch(readAlertPreferencesProvider);
    final session = await ref.watch(preferenceSessionProvider.future);
    if (session == null) {
      throw const PreferenceFailure(PreferenceFailureKind.signedOut);
    }
    final preferences = await read(session.userId);
    return PreferenceViewState(saved: preferences, draft: preferences);
  }

  void retry() => ref.invalidateSelf();
  bool _current(int generation, String owner) =>
      ref.mounted &&
      generation == _generation &&
      !state.isLoading &&
      !state.hasError &&
      state.asData?.value.saved.ownerId == owner;

  void edit({
    bool? enabled,
    bool? lostPets,
    bool? foundPets,
    bool? caseUpdates,
    bool? inApp,
    bool? push,
  }) {
    final current = state.asData?.value;
    if (current == null || current.busy || state.isLoading || state.hasError) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        draft: current.draft.copyWith(
          enabled: enabled,
          lostPets: lostPets,
          foundPets: foundPets,
          caseUpdates: caseUpdates,
          inApp: inApp,
          push: push,
        ),
        clearIssue: current.issue != PreferenceFailureKind.conflict,
        confirmed: false,
      ),
    );
  }

  void discard() {
    final current = state.asData?.value;
    if (current == null || current.busy || state.isLoading || state.hasError) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        draft: current.saved,
        clearIssue: current.issue != PreferenceFailureKind.conflict,
        confirmed: false,
      ),
    );
  }

  Future<void> save() async {
    final current = state.asData?.value;
    if (current == null ||
        !current.dirty ||
        current.issue == PreferenceFailureKind.conflict ||
        current.busy ||
        state.isLoading ||
        state.hasError) {
      return;
    }
    final generation = _generation;
    final keepAlive = ref.keepAlive();
    final save = ref.read(saveAlertPreferencesProvider);
    state = AsyncData(
      current.copyWith(saving: true, clearIssue: true, confirmed: false),
    );
    try {
      final saved = await save(current.draft);
      if (_current(generation, current.saved.ownerId)) {
        state = AsyncData(
          PreferenceViewState(
            saved: saved,
            draft: saved,
            confirmed: true,
            noticeId: ++_noticeId,
          ),
        );
      }
    } catch (error) {
      if (_current(generation, current.saved.ownerId)) {
        state = AsyncData(
          current.copyWith(
            saving: false,
            confirmed: false,
            issue: error is PreferenceFailure
                ? error.kind
                : PreferenceFailureKind.unavailable,
          ),
        );
      }
    } finally {
      keepAlive.close();
    }
  }

  /// Same-account explicit refresh preserves content; dirty drafts need UI confirmation.
  Future<void> refresh({bool discardDraft = false}) async {
    final current = state.asData?.value;
    if (current == null ||
        current.busy ||
        state.isLoading ||
        state.hasError ||
        (current.dirty && !discardDraft)) {
      return;
    }
    final generation = _generation;
    final read = ref.read(readAlertPreferencesProvider);
    state = AsyncData(
      current.copyWith(refreshing: true, clearIssue: true, confirmed: false),
    );
    try {
      final remote = await read(current.saved.ownerId);
      if (_current(generation, current.saved.ownerId)) {
        state = AsyncData(PreferenceViewState(saved: remote, draft: remote));
      }
    } catch (_) {
      if (_current(generation, current.saved.ownerId)) {
        state = AsyncData(
          current.copyWith(
            refreshing: false,
            confirmed: false,
            issue: PreferenceFailureKind.unavailable,
          ),
        );
      }
    }
  }
}
