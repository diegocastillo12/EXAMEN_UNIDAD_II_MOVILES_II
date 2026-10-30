import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/utils/new_entity_id.dart';
import '../../domain/entities/case_closure.dart';
import '../../providers/case_closure_providers.dart';
import '../state/case_closure_state.dart';

final caseClosureViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<CaseClosureViewModel, CaseClosureState, ClosureTarget>(
      CaseClosureViewModel.new,
      retry: (_, _) => null,
    );

class CaseClosureViewModel extends AsyncNotifier<CaseClosureState> {
  CaseClosureViewModel(this.target);
  final ClosureTarget target;
  int _generation = 0;
  @override
  Future<CaseClosureState> build() async {
    _generation++;
    final session = await ref.watch(closureSessionProvider.future);
    if (session == null) throw const ClosureFailure(ClosureIssue.forbidden);
    return CaseClosureState(
      owner: session.userId,
      detail: await ref.watch(readCaseClosureProvider)(session.userId, target),
    );
  }

  bool _current(int generation, String owner) =>
      ref.mounted &&
      _generation == generation &&
      !state.isLoading &&
      !state.hasError &&
      state.asData?.value.owner == owner;
  void retry() => ref.invalidateSelf();
  void edit({String? reason, String? evidence}) {
    final v = state.asData?.value;
    if (v?.editable != true || state.isLoading) return;
    state = AsyncData(v!.copy(reason: reason, evidence: evidence));
  }

  Future<bool> save() async {
    final v = state.asData?.value;
    if (v == null ||
        state.isLoading ||
        v.busy ||
        v.detail.closed ||
        v.requiresRead) {
      return false;
    }
    final action = ref.read(closeRecoveryCaseProvider);
    try {
      action.validate(v.reason, v.evidence);
    } on ClosureFailure catch (e) {
      state = AsyncData(v.copy(issue: e.issue));
      return false;
    }
    final command =
        v.frozen ??
        ClosureCommand(
          id: newEntityId(),
          target: target,
          reason: v.reason.trim(),
          evidence: v.evidence.trim(),
        );
    final generation = _generation, keep = ref.keepAlive();
    state = AsyncData(v.copy(busy: true, frozen: command));
    try {
      final receipt = await action(
        v.owner,
        command,
      ).timeout(const Duration(seconds: 35));
      if (!_current(generation, v.owner)) return false;
      state = AsyncData(
        v.copy(
          detail: ClosureDetail(closed: true, receipt: receipt),
          clearFrozen: true,
          saved: true,
        ),
      );
      return true;
    } catch (error) {
      if (!_current(generation, v.owner)) return false;
      final issue = error is ClosureFailure
          ? error.issue
          : ClosureIssue.unavailable;
      if (issue == ClosureIssue.forbidden) {
        state = AsyncError(ClosureFailure(issue), StackTrace.current);
      } else {
        state = AsyncData(
          state.requireValue.copy(
            issue: issue,
            requiresRead: {
              ClosureIssue.closed,
              ClosureIssue.conflict,
            }.contains(issue),
            clearFrozen: issue == ClosureIssue.invalid,
          ),
        );
      }
      return false;
    } finally {
      keep.close();
    }
  }

  Future<void> refresh() async {
    final v = state.asData?.value;
    if (v == null || v.busy || (v.frozen != null && !v.requiresRead)) {
      return;
    }
    final generation = _generation;
    state = AsyncData(v.copy(busy: true, refreshing: true));
    try {
      final detail = await ref.read(readCaseClosureProvider)(v.owner, target);
      if (_current(generation, v.owner)) {
        state = AsyncData(
          v.copy(detail: detail, clearFrozen: true, requiresRead: false),
        );
      }
    } catch (error) {
      if (!_current(generation, v.owner)) return;
      final issue = error is ClosureFailure
          ? error.issue
          : ClosureIssue.unavailable;
      state = issue == ClosureIssue.forbidden
          ? AsyncError(ClosureFailure(issue), StackTrace.current)
          : AsyncData(v.copy(issue: issue));
    }
  }
}
