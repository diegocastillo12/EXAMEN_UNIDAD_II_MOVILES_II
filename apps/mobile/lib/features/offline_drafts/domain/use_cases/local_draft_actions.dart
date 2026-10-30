import '../entities/queued_report.dart';
import '../entities/local_report_draft.dart';
import '../repositories/local_draft_repository.dart';

class CancelLocalSubmission {
  const CancelLocalSubmission(this.repository);
  final LocalDraftRepository repository;
  Future<void> call(String owner, String id) =>
      repository.cancelSubmission(owner, id);
}

class ListLocalDrafts {
  const ListLocalDrafts(this.repository);
  final LocalDraftRepository repository;
  Future<List<LocalReportDraft>> call(String owner) async {
    if (owner.isEmpty) throw const LocalDraftFailure();
    final drafts = await repository.list(owner);
    final published = (await repository.listQueue(owner))
        .where((e) => e.status == SubmissionStatus.published)
        .map((e) => e.command.id)
        .toSet();
    return drafts.where((d) => !published.contains(d.id)).toList();
  }
}

class ReadLocalDraft {
  const ReadLocalDraft(this.repository);
  final LocalDraftRepository repository;
  Future<LocalReportDraft?> call(String owner, String slot) {
    if (owner.isEmpty || slot.isEmpty) throw const LocalDraftFailure();
    return repository.read(owner, slot);
  }
}

class SaveLocalDraft {
  const SaveLocalDraft(this.repository);
  final LocalDraftRepository repository;
  Future<void> call(LocalReportDraft draft) {
    if (draft.owner.isEmpty || draft.slot.isEmpty || draft.id.isEmpty) {
      throw const LocalDraftFailure();
    }
    return repository.save(draft);
  }
}

class RemoveLocalDraft {
  const RemoveLocalDraft(this.repository);
  final LocalDraftRepository repository;
  Future<void> call(String owner, String slot, String id) =>
      repository.remove(owner, slot, id);
}
