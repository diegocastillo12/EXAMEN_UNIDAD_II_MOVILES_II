import '../entities/local_report_draft.dart';
import '../entities/queued_report.dart';

abstract interface class SubmissionQueueRepository {
  /// Explicitly stops automatic intent; never cancels an in-flight or confirmed publication.
  Future<void> cancelSubmission(String owner, String id);
  Future<QueuedReport> enqueue(
    LocalReportDraft command, {
    bool resolveRejected = false,
  });
  Future<List<QueuedReport>> listQueue(String owner);
  Stream<List<QueuedReport>> watchQueue(String owner);
  Future<QueuedReport?> claimSubmission(
    String owner,
    String id,
    DateTime now, {
    bool manual = false,
  });
  Future<void> completeSubmission(
    QueuedReport claim,
    SubmissionReceipt receipt,
  );
  Future<void> failSubmission(
    QueuedReport claim,
    SubmissionIssue issue,
    DateTime nextAttemptAt, {
    required bool retryable,
  });
}
