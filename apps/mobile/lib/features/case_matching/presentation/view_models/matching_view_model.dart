import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/utils/new_entity_id.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../domain/entities/case_match.dart';
import '../../providers/case_matching_providers.dart';
import '../state/matching_state.dart';

final matchingViewModelProvider =
    AsyncNotifierProvider.autoDispose<MatchingViewModel, MatchingState>(
      MatchingViewModel.new,
      retry: (_, _) => null,
    );

class MatchingViewModel extends AsyncNotifier<MatchingState> {
  int _generation = 0;
  MatchReviewCommand? _pending;
  @override
  Future<MatchingState> build() async {
    ++_generation;
    _pending = null;
    ref.onDispose(() => _generation++);
    final session = await ref.watch(authSessionProvider.future);
    if (!ref.mounted) throw const MatchFailure(MatchIssue.forbidden);
    if (session == null) throw const MatchFailure(MatchIssue.forbidden);
    final searches = await ref.watch(readMatchSearchesProvider)(session.userId);
    return MatchingState(
      owner: session.userId,
      searches: searches,
      selected: searches.firstOrNull?.reference,
    );
  }

  bool _current(int g, String owner) =>
      ref.mounted &&
      g == _generation &&
      !state.isLoading &&
      state.asData?.value.owner == owner;
  void select(String key) {
    final v = state.asData?.value;
    if (v == null || v.busy) return;
    final target = v.searches.where((s) => s.reference.key == key).firstOrNull;
    if (target == null) return;
    _pending = null;
    state = AsyncData(
      v.copyWith(
        selected: target.reference,
        clearResult: true,
        clearIssue: true,
      ),
    );
  }

  void retry() => ref.invalidateSelf();
  Future<void> search() async {
    final v = state.asData?.value;
    if (v == null || state.isLoading || v.busy || v.selected == null) return;
    final g = ++_generation;
    _pending = null;
    state = AsyncData(v.copyWith(busy: true, clearIssue: true));
    try {
      final result = await ref.read(findCaseMatchesProvider)(
        v.owner,
        v.selected!,
      );
      if (_current(g, v.owner)) {
        state = AsyncData(
          state.requireValue.copyWith(result: result, busy: false),
        );
      }
    } catch (e) {
      if (_current(g, v.owner)) _fail(e);
    }
  }

  Future<void> decide(CaseMatchCandidate candidate, String decision) async {
    final v = state.asData?.value;
    if (v == null || state.isLoading || v.busy || v.result == null) return;
    final g = ++_generation, previous = _pending;
    final command =
        previous != null &&
            previous.candidate.reference.key == candidate.reference.key &&
            previous.decision == decision
        ? previous
        : MatchReviewCommand(
            id: newEntityId(),
            result: v.result!,
            candidate: candidate,
            decision: decision,
          );
    _pending = command;
    state = AsyncData(v.copyWith(busy: true, clearIssue: true));
    try {
      await ref.read(reviewCaseMatchProvider)(v.owner, command);
      if (_current(g, v.owner)) {
        _pending = null;
        state = AsyncData(
          state.requireValue.copyWith(
            result: v.result!.reviewed(candidate.reference.key, decision),
            busy: false,
            saved: v.saved + 1,
          ),
        );
      }
    } catch (e) {
      if (_current(g, v.owner)) _fail(e);
    }
  }

  void _fail(Object error) {
    final kind = error is MatchFailure ? error.kind : MatchIssue.unavailable;
    state = AsyncData(
      state.requireValue.copyWith(
        busy: false,
        issue: kind,
        clearResult: {MatchIssue.forbidden, MatchIssue.conflict}.contains(kind),
      ),
    );
  }
}
