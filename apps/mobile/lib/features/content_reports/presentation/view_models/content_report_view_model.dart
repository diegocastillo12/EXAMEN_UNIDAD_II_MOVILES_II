import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/utils/new_entity_id.dart';
import '../../domain/entities/content_report.dart';
import '../../providers/content_report_providers.dart';
import '../state/content_report_state.dart';

final contentReportViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<ContentReportViewModel, ContentReportState, ReportTarget>(
      ContentReportViewModel.new,
      retry: (_, _) => null,
    );

class ContentReportViewModel extends AsyncNotifier<ContentReportState> {
  ContentReportViewModel(this.target);
  final ReportTarget target;
  int _generation = 0;
  @override
  Future<ContentReportState> build() async {
    _generation++;
    final session = await ref.watch(reportSessionProvider.future);
    if (session == null) throw const ReportFailure(ReportIssue.forbidden);
    return ContentReportState(actor: session.userId);
  }

  void retry() => ref.invalidateSelf();
  void edit({String? reason, String? evidence}) {
    final value = state.asData?.value;
    if (state.isLoading || state.hasError || value?.editable != true) return;
    state = AsyncData(value!.copy(reason: reason, evidence: evidence));
  }

  Future<bool> submit() async {
    final value = state.asData?.value;
    if (state.isLoading ||
        state.hasError ||
        value == null ||
        value.busy ||
        value.receipt != null ||
        value.issue == ReportIssue.conflict) {
      return false;
    }
    final action = ref.read(submitContentReportProvider);
    try {
      action.validate(value.reason, value.evidence);
    } on ReportFailure catch (failure) {
      state = AsyncData(value.copy(issue: failure.issue));
      return false;
    }
    final command =
        value.frozen ??
        ReportCommand(
          id: newEntityId(),
          target: target,
          reason: value.reason.trim(),
          evidence: value.evidence.trim(),
        );
    final generation = _generation, keep = ref.keepAlive();
    state = AsyncData(value.copy(busy: true, frozen: command));
    bool current() =>
        ref.mounted &&
        generation == _generation &&
        !state.isLoading &&
        !state.hasError &&
        state.asData?.value.actor == value.actor;
    try {
      final receipt = await action(
        value.actor,
        command,
      ).timeout(const Duration(seconds: 35));
      if (!current()) return false;
      state = AsyncData(value.copy(receipt: receipt, clearFrozen: true));
      return true;
    } catch (error) {
      if (!current()) return false;
      final issue = error is ReportFailure
          ? error.issue
          : ReportIssue.unavailable;
      state = issue == ReportIssue.forbidden
          ? AsyncError(ReportFailure(issue), StackTrace.current)
          : AsyncData(
              value.copy(
                frozen: command,
                issue: issue,
                clearFrozen: issue == ReportIssue.invalid,
              ),
            );
      return false;
    } finally {
      keep.close();
    }
  }
}
