import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/utils/new_entity_id.dart';
import '../../domain/entities/moderation_appeal.dart';
import '../../providers/appeals_providers.dart';
import '../state/appeals_state.dart';

final appealsViewModelProvider =
    AsyncNotifierProvider.autoDispose<AppealsViewModel, AppealsState>(
      AppealsViewModel.new,
      retry: (_, _) => null,
    );

class AppealsViewModel extends AsyncNotifier<AppealsState> {
  int _generation = 0;
  @override
  Future<AppealsState> build() async {
    _generation++;
    final session = await ref.watch(appealsSessionProvider.future);
    if (session == null) throw const AppealFailure(AppealIssue.forbidden);
    final page = await ref.watch(readAppealsProvider)(session.userId);
    return AppealsState(
      actor: session.userId,
      items: page.items,
      next: page.next,
    );
  }

  void retry() => ref.invalidateSelf();
  void select(ModeratedDecision? selected, {bool discard = false}) {
    final v = state.asData?.value;
    if (v == null || v.busy || (v.frozen != null && !discard)) return;
    state = AsyncData(
      v.copy(
        selected: selected,
        clearSelected: selected == null,
        reason: '',
        clearFrozen: true,
        refreshRequired: false,
        retrying: false,
      ),
    );
  }

  void edit(String reason) {
    final v = state.asData?.value;
    if (v == null || v.busy || v.frozen != null) return;
    state = AsyncData(v.copy(reason: reason));
  }

  Future<void> load({bool more = false}) async {
    final v = state.asData?.value;
    if (v == null ||
        state.isLoading ||
        v.busy ||
        (more && v.next == null) ||
        (v.frozen != null && !v.refreshRequired)) {
      return;
    }
    final generation = _generation;
    state = AsyncData(v.copy(busy: true));
    try {
      final page = await ref.read(readAppealsProvider)(
        v.actor,
        more ? v.next : null,
      );
      if (!ref.mounted || generation != _generation) return;
      final items = more
          ? List<ModeratedDecision>.unmodifiable([
              ...v.items,
              ...page.items.where(
                (item) => !v.items.any((old) => old.id == item.id),
              ),
            ])
          : page.items;
      final selected = items.where((e) => e.id == v.selected?.id).firstOrNull;
      state = AsyncData(
        v.copy(
          items: items,
          next: page.next,
          clearNext: page.next == null,
          selected: selected,
          clearSelected: selected == null,
          clearFrozen: true,
          refreshRequired: false,
          retrying: false,
        ),
      );
    } catch (error) {
      _fail(v, error, generation);
    }
  }

  void _fail(AppealsState v, Object error, int generation) {
    if (!ref.mounted || generation != _generation) return;
    final issue = error is AppealFailure
        ? error.issue
        : AppealIssue.unavailable;
    state = issue == AppealIssue.forbidden
        ? AsyncError(AppealFailure(issue), StackTrace.current)
        : AsyncData(
            v.copy(
              issue: issue,
              clearFrozen: issue == AppealIssue.invalid,
              retrying: issue != AppealIssue.invalid && v.frozen != null,
              refreshRequired:
                  v.refreshRequired || issue == AppealIssue.conflict,
            ),
          );
  }

  Future<void> submit() async {
    final v = state.asData?.value;
    if (v == null ||
        state.isLoading ||
        v.busy ||
        v.selected == null ||
        v.selected!.appeal != null ||
        v.refreshRequired) {
      return;
    }
    final submit = ref.read(submitAppealProvider);
    try {
      submit.validate(v.reason);
    } on AppealFailure catch (e) {
      state = AsyncData(v.copy(issue: e.issue));
      return;
    }
    final command =
        v.frozen ??
        AppealCommand(
          id: newEntityId(),
          decision: v.selected!.id,
          reason: v.reason.trim(),
        );
    final generation = _generation, keep = ref.keepAlive();
    state = AsyncData(
      v.copy(busy: true, frozen: command, retrying: v.frozen != null),
    );
    try {
      final entry = await submit(
        v.actor,
        command,
      ).timeout(const Duration(seconds: 35));
      if (!ref.mounted || generation != _generation) return;
      state = AsyncData(
        v.copy(
          items: List.unmodifiable(
            v.items.map((e) => e.id == entry.id ? entry : e),
          ),
          selected: entry,
          reason: '',
          clearFrozen: true,
          refreshRequired: false,
          retrying: false,
          saved: true,
        ),
      );
    } catch (error) {
      _fail(v.copy(frozen: command, retrying: true), error, generation);
    } finally {
      keep.close();
    }
  }
}
