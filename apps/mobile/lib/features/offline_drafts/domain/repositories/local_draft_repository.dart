import '../entities/local_report_draft.dart';
import 'submission_queue_repository.dart';

abstract interface class LocalDraftRepository
    implements SubmissionQueueRepository {
  Future<List<LocalReportDraft>> list(String owner);
  Future<LocalReportDraft?> read(String owner, String slot);
  Future<void> save(LocalReportDraft draft);

  /// Exact command only: a late receipt must not delete a newer draft.
  Future<void> remove(String owner, String slot, String id);
}
