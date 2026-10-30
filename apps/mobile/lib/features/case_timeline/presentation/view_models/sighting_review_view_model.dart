import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/utils/new_entity_id.dart';
import '../../domain/entities/case_timeline.dart';
import '../../providers/case_timeline_providers.dart';
import '../state/case_timeline_state.dart';

typedef ReviewKey = ({TimelineTarget target, String id});
final sightingReviewViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<SightingReviewViewModel, SightingReviewState, ReviewKey>(
      SightingReviewViewModel.new,
      retry: (_, _) => null,
    );

class SightingReviewViewModel extends AsyncNotifier<SightingReviewState> {
  SightingReviewViewModel(this.key);
  final ReviewKey key;
  int _generation = 0;
  @override
  Future<SightingReviewState> build() async {
    _generation++;
    final session = await ref.watch(timelineSessionProvider.future);
    if (session == null) throw const TimelineFailure(TimelineIssue.forbidden);
    final detail = await ref.watch(readSightingReviewProvider)(
      session.userId,
      key.target,
      key.id,
    );
    return SightingReviewState(owner: session.userId, detail: detail);
  }

  bool _current(int generation, String owner) =>
      ref.mounted &&
      generation == _generation &&
      !state.isLoading &&
      state.asData?.value.owner == owner;
  void retry() => ref.invalidateSelf();
  void select(String value) {
    final v = state.asData?.value;
    if (v?.editable != true) return;
    state = AsyncData(v!.copy(selected: value));
  }

  void reason(String value) {
    final v = state.asData?.value;
    if (v?.editable != true) return;
    state = AsyncData(v!.copy(reason: value));
  }

  Future<void> save() async {
    final v = state.asData?.value;
    if (v == null || state.isLoading || v.busy || v.closed || v.conflicted) {
      return;
    }
    final action = ref.read(reviewSightingProvider);
    if (v.frozen == null) {
      try {
        action.validate(v.detail, v.selected, v.reason);
      } on TimelineFailure catch (e) {
        state = AsyncData(v.copy(failure: e.issue));
        return;
      }
    }
    final command =
        v.frozen ??
        ReviewCommand(
          id: newEntityId(),
          sightingId: key.id,
          expectedRevision: v.detail.revision,
          state: v.selected,
          reason: v.reason.trim(),
        );
    final generation = _generation, keep = ref.keepAlive();
    state = AsyncData(v.copy(frozen: command, work: ReviewWork.save));
    try {
      final decision = await action(
        v.owner,
        command,
      ).timeout(const Duration(seconds: 35));
      if (!_current(generation, v.owner)) return;
      state = AsyncData(
        state.requireValue.copy(
          detail: v.detail.withDecision(decision),
          selected: '',
          reason: '',
          clearFrozen: true,
          saved: true,
        ),
      );
    } catch (error) {
      if (!_current(generation, v.owner)) return;
      final issue = error is TimelineFailure
          ? error.issue
          : TimelineIssue.unavailable;
      if (issue == TimelineIssue.forbidden) {
        state = AsyncError(TimelineFailure(issue), StackTrace.current);
        return;
      }
      state = AsyncData(
        state.requireValue.copy(
          failure: issue,
          conflicted: issue == TimelineIssue.conflict,
          closed: issue == TimelineIssue.closed,
          clearFrozen: {
            TimelineIssue.invalid,
            TimelineIssue.transition,
            TimelineIssue.closed,
          }.contains(issue),
        ),
      );
    } finally {
      keep.close();
    }
  }

  Future<void> refresh() async {
    final v = state.asData?.value;
    if (v == null || v.busy || (v.frozen != null && !v.conflicted)) return;
    final generation = _generation;
    state = AsyncData(v.copy(work: ReviewWork.refresh));
    try {
      final detail = await ref.read(readSightingReviewProvider)(
        v.owner,
        key.target,
        key.id,
      );
      if (_current(generation, v.owner)) {
        state = AsyncData(
          state.requireValue.copy(
            detail: detail,
            clearFrozen: true,
            conflicted: false,
            closed: !detail.canReview,
          ),
        );
      }
    } catch (error) {
      _fail(generation, v.owner, error);
    }
  }

  Future<void> evidence() async {
    final v = state.asData?.value;
    if (v == null || v.busy || !v.detail.hasPhoto) return;
    final generation = _generation;
    state = AsyncData(v.copy(work: ReviewWork.photo));
    try {
      final photo = await ref.read(readSightingEvidenceProvider)(
        v.owner,
        key.id,
      );
      if (photo == null) throw const TimelineFailure(TimelineIssue.unavailable);
      if (_current(generation, v.owner)) {
        state = AsyncData(state.requireValue.copy(photo: photo));
      }
    } catch (error) {
      _fail(generation, v.owner, error);
    }
  }

  Future<void> moreHistory() async {
    final v = state.asData?.value;
    if (v == null || v.busy || v.detail.nextRevision == null) return;
    final generation = _generation;
    state = AsyncData(v.copy(work: ReviewWork.history));
    try {
      final page = await ref.read(readSightingReviewProvider)(
        v.owner,
        key.target,
        key.id,
        v.detail.nextRevision,
      );
      final rows = {
        for (final r in [...v.detail.history, ...page.history]) r.commandId: r,
      }.values.toList()..sort((a, b) => b.revision.compareTo(a.revision));
      if (_current(generation, v.owner)) {
        state = AsyncData(
          state.requireValue.copy(
            detail: v.detail.withHistory(rows, page.nextRevision),
          ),
        );
      }
    } catch (error) {
      _fail(generation, v.owner, error);
    }
  }

  void _fail(int generation, String owner, Object error) {
    if (!_current(generation, owner)) return;
    final issue = error is TimelineFailure
        ? error.issue
        : TimelineIssue.unavailable;
    if (issue == TimelineIssue.forbidden) {
      state = AsyncError(TimelineFailure(issue), StackTrace.current);
      return;
    }
    state = AsyncData(state.requireValue.copy(failure: issue));
  }
}
