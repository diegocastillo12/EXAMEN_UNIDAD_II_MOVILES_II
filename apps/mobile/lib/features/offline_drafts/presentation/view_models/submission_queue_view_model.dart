import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/local_report_draft.dart';
import '../../domain/entities/queued_report.dart';
import '../../domain/use_cases/dispatch_queued_reports.dart';
import '../../providers/local_draft_providers.dart';
import '../../providers/submission_queue_providers.dart';
import '../state/submission_queue_state.dart';

final submissionQueueViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      SubmissionQueueViewModel,
      SubmissionQueueState
    >(SubmissionQueueViewModel.new, retry: (_, _) => null);

class SubmissionQueueViewModel extends AsyncNotifier<SubmissionQueueState> {
  int _generation = 0;
  @override
  Future<SubmissionQueueState> build() async {
    final generation = ++_generation;
    final session = await ref.watch(localDraftSessionProvider.future);
    if (session == null) throw const LocalDraftFailure();
    final owner = session.userId;
    ref.listen(queuedReportsProvider(owner), (previous, next) {
      if (!ref.mounted ||
          generation != _generation ||
          state.isLoading ||
          state.asData?.value.owner != owner) {
        return;
      }
      if (next.hasError) {
        state = AsyncData(
          state.requireValue.copy(issue: SubmissionIssue.unavailable),
        );
      } else if (next.asData != null) {
        state = AsyncData(state.requireValue.copy(entries: next.requireValue));
      }
    });
    return SubmissionQueueState(
      owner: owner,
      entries: await ref.read(queuedReportsProvider(owner).future),
    );
  }

  void reload() {
    ref.invalidate(queuedReportsProvider);
    ref.invalidateSelf();
  }

  void showIssue(SubmissionIssue? issue) {
    final v = state.asData?.value;
    if (v != null) {
      state = AsyncData(v.copy(issue: issue ?? SubmissionIssue.unavailable));
    }
  }

  Future<void> retry(String id) async {
    final v = state.asData?.value;
    if (v == null || state.isLoading || v.busyId != null) return;
    final generation = _generation, keep = ref.keepAlive();
    bool current() =>
        ref.mounted &&
        generation == _generation &&
        !state.isLoading &&
        state.asData?.value.owner == v.owner;
    state = AsyncData(v.copy(busyId: id, clearIssue: true));
    try {
      await ref
          .read(dispatchQueuedReportsProvider)
          .retry(v.owner, id, isCurrent: current);
    } catch (error) {
      if (current()) {
        state = AsyncData(
          state.requireValue.copy(issue: submissionIssue(error)),
        );
      }
    } finally {
      if (current()) {
        state = AsyncData(state.requireValue.copy(clearBusy: true));
      }
      keep.close();
    }
  }
}
