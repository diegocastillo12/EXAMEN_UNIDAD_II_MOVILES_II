import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/case_timeline.dart';
import '../../providers/case_timeline_providers.dart';
import '../state/case_timeline_state.dart';

final timelineAccessViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<TimelineAccessViewModel, bool, TimelineTarget>(
      TimelineAccessViewModel.new,
      retry: (_, _) => null,
    );

class TimelineAccessViewModel extends AsyncNotifier<bool> {
  TimelineAccessViewModel(this.target);
  final TimelineTarget target;
  @override
  Future<bool> build() async {
    final session = await ref.watch(timelineSessionProvider.future);
    if (session == null) return false;
    return ref.watch(readTimelineAccessProvider)(session.userId, target);
  }

  void retry() => ref.invalidateSelf();
}

final caseTimelineViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<CaseTimelineViewModel, CaseTimelineState, TimelineTarget>(
      CaseTimelineViewModel.new,
      retry: (_, _) => null,
    );

class CaseTimelineViewModel extends AsyncNotifier<CaseTimelineState> {
  CaseTimelineViewModel(this.target);
  final TimelineTarget target;
  int _generation = 0;
  @override
  Future<CaseTimelineState> build() async {
    _generation++;
    final session = await ref.watch(timelineSessionProvider.future);
    if (session == null) throw const TimelineFailure(TimelineIssue.forbidden);
    final page = await ref.watch(readCaseTimelineProvider)(
      session.userId,
      target,
    );
    return CaseTimelineState(owner: session.userId, page: page);
  }

  void retry() => ref.invalidateSelf();
  Future<void> refresh() => _read(false);
  Future<void> more() => _read(true);
  Future<void> _read(bool more) async {
    final v = state.asData?.value;
    if (v == null ||
        state.isLoading ||
        v.busy ||
        (more && v.page.next == null)) {
      return;
    }
    final generation = _generation;
    state = AsyncData(
      CaseTimelineState(
        owner: v.owner,
        page: v.page,
        busy: true,
        notice: v.notice,
      ),
    );
    try {
      final page = await ref.read(readCaseTimelineProvider)(
        v.owner,
        target,
        more ? v.page.next : null,
      );
      if (!ref.mounted ||
          generation != _generation ||
          state.asData?.value.owner != v.owner) {
        return;
      }
      final items = more
          ? {
              for (final e in [...v.page.items, ...page.items]) e.key: e,
            }.values.toList()
          : page.items.toList();
      items.sort((a, b) {
        final time = b.observedAt.compareTo(a.observedAt);
        return time == 0 ? b.key.compareTo(a.key) : time;
      });
      state = AsyncData(
        CaseTimelineState(
          owner: v.owner,
          page: TimelinePage(page.caseStatus, items, page.next),
          notice: v.notice,
        ),
      );
    } catch (error) {
      if (!ref.mounted ||
          generation != _generation ||
          state.asData?.value.owner != v.owner) {
        return;
      }
      final failure = error is TimelineFailure
          ? error
          : const TimelineFailure(TimelineIssue.unavailable);
      if (failure.issue == TimelineIssue.forbidden) {
        state = AsyncError(failure, StackTrace.current);
        return;
      }
      state = AsyncData(
        CaseTimelineState(
          owner: v.owner,
          page: v.page,
          failure: failure.issue,
          notice: v.notice + 1,
        ),
      );
    }
  }
}
