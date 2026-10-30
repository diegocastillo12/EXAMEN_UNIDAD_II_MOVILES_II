import 'dart:async';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/entities/queued_report.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/data/models/queued_report_dto.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/entities/local_report_draft.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/repositories/local_draft_repository.dart';

class FakeLocalDrafts implements LocalDraftRepository {
  final drafts = <(String, String), LocalReportDraft>{};
  bool fail = false;
  final submissions = <(String, String), QueuedReport>{};
  final fingerprints = <(String, String), String>{};
  final changes = StreamController<String>.broadcast(sync: true);
  @override
  Future<void> cancelSubmission(String owner, String id) async {
    if (fail) throw const LocalDraftFailure();
    final status = submissions[(owner, id)]?.status;
    if (status == SubmissionStatus.sending ||
        status == SubmissionStatus.published) {
      throw const SubmissionFailure(SubmissionIssue.busy);
    }
    submissions.remove((owner, id));
    fingerprints.remove((owner, id));
    changes.add(owner);
  }

  @override
  Future<QueuedReport> enqueue(
    LocalReportDraft command, {
    bool resolveRejected = false,
  }) async {
    if (fail) throw const LocalDraftFailure();
    final key = (command.owner, command.id),
        signature = QueuedReportDto.fingerprint(command);
    final old = submissions[key];
    if (old != null &&
        fingerprints[key] != signature &&
        !(resolveRejected &&
            old.status == SubmissionStatus.failed &&
            [
              SubmissionIssue.invalid,
              SubmissionIssue.photo,
            ].contains(old.issue))) {
      throw const SubmissionFailure(SubmissionIssue.conflict);
    }
    if (old != null && fingerprints[key] == signature) return old;
    fingerprints[key] = signature;
    final entry = QueuedReport(
      command: command,
      status: SubmissionStatus.pending,
      attempts: 0,
      createdAt: DateTime.now(),
      nextAttemptAt: DateTime.now(),
    );
    submissions[key] = entry;
    changes.add(command.owner);
    return entry;
  }

  @override
  Future<List<QueuedReport>> listQueue(String owner) async {
    if (fail) throw const LocalDraftFailure();
    return submissions.values.where((e) => e.command.owner == owner).toList();
  }

  @override
  Stream<List<QueuedReport>> watchQueue(String owner) =>
      Stream.multi((controller) {
        var active = true;
        Future<void> emit() async {
          try {
            final rows = await listQueue(owner);
            if (active) controller.add(rows);
          } catch (e, s) {
            if (active) controller.addError(e, s);
          }
        }

        final sub = changes.stream.where((o) => o == owner).listen((_) {
          unawaited(emit());
        });
        unawaited(emit());
        controller.onCancel = () {
          active = false;
          return sub.cancel();
        };
      });
  @override
  Future<QueuedReport?> claimSubmission(
    String owner,
    String id,
    DateTime now, {
    bool manual = false,
  }) async {
    if (fail) throw const LocalDraftFailure();
    final old = submissions[(owner, id)];
    if (old == null ||
        old.status == SubmissionStatus.published ||
        old.status == SubmissionStatus.sending ||
        (!manual &&
            (old.status == SubmissionStatus.failed ||
                old.nextAttemptAt.isAfter(now)))) {
      return null;
    }
    final entry = QueuedReport(
      command: old.command,
      status: SubmissionStatus.sending,
      attempts: old.attempts + 1,
      createdAt: old.createdAt,
      nextAttemptAt: old.nextAttemptAt,
      claim: 'claim-${old.attempts + 1}',
    );
    submissions[(owner, id)] = entry;
    changes.add(owner);
    return entry;
  }

  @override
  Future<void> completeSubmission(
    QueuedReport claim,
    SubmissionReceipt receipt,
  ) async {
    if (fail) throw const LocalDraftFailure();
    final d = claim.command;
    submissions[(d.owner, d.id)] = QueuedReport(
      command: d,
      status: SubmissionStatus.published,
      attempts: claim.attempts,
      createdAt: claim.createdAt,
      nextAttemptAt: claim.nextAttemptAt,
      receipt: receipt,
    );
    changes.add(d.owner);
  }

  @override
  Future<void> failSubmission(
    QueuedReport claim,
    SubmissionIssue issue,
    DateTime nextAttemptAt, {
    required bool retryable,
  }) async {
    if (fail) throw const LocalDraftFailure();
    final d = claim.command;
    submissions[(d.owner, d.id)] = QueuedReport(
      command: d,
      status: retryable ? SubmissionStatus.pending : SubmissionStatus.failed,
      attempts: claim.attempts,
      createdAt: claim.createdAt,
      nextAttemptAt: nextAttemptAt,
      issue: issue,
    );
    changes.add(d.owner);
  }

  @override
  Future<List<LocalReportDraft>> list(String owner) async {
    if (fail) throw const LocalDraftFailure();
    return drafts.values.where((draft) => draft.owner == owner).toList();
  }

  @override
  Future<LocalReportDraft?> read(String owner, String slot) async {
    if (fail) throw const LocalDraftFailure();
    return drafts[(owner, slot)];
  }

  @override
  Future<void> save(LocalReportDraft draft) async {
    if (fail) throw const LocalDraftFailure();
    drafts[(draft.owner, draft.slot)] = draft;
  }

  @override
  Future<void> remove(String owner, String slot, String id) async {
    if (fail) throw const LocalDraftFailure();
    if (drafts[(owner, slot)]?.id == id) drafts.remove((owner, slot));
  }
}
