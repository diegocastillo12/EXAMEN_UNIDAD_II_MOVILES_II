import 'dart:async';
import '../../../lost_cases/domain/entities/lost_case.dart';
import '../../../found_cases/domain/entities/found_case.dart';
import '../../../sightings/domain/entities/sighting.dart';
import '../entities/local_report_draft.dart';
import '../entities/queued_report.dart';
import '../repositories/local_draft_repository.dart';
import 'submission_transport.dart';

SubmissionIssue submissionIssue(Object error) {
  if (error is SubmissionFailure) return error.issue;
  if (error is CaseFailure) {
    return switch (error.kind) {
      CaseFailureKind.conflict ||
      CaseFailureKind.activeCase => SubmissionIssue.conflict,
      CaseFailureKind.forbidden => SubmissionIssue.forbidden,
      CaseFailureKind.invalid ||
      CaseFailureKind.incompletePet => SubmissionIssue.invalid,
      CaseFailureKind.photosUnverified => SubmissionIssue.photo,
      CaseFailureKind.busy => SubmissionIssue.busy,
      _ => SubmissionIssue.unavailable,
    };
  }
  if (error is FoundFailure) {
    return switch (error.kind) {
      FoundFailureKind.conflict => SubmissionIssue.conflict,
      FoundFailureKind.forbidden => SubmissionIssue.forbidden,
      FoundFailureKind.blocked => SubmissionIssue.blocked,
      FoundFailureKind.targetClosed => SubmissionIssue.closed,
      FoundFailureKind.invalid => SubmissionIssue.invalid,
      FoundFailureKind.photoInvalid ||
      FoundFailureKind.photos => SubmissionIssue.photo,
      FoundFailureKind.draftLimit => SubmissionIssue.rateLimited,
      _ => SubmissionIssue.unavailable,
    };
  }
  if (error is SightingFailure) {
    return switch (error.issue) {
      SightingIssue.conflict => SubmissionIssue.conflict,
      SightingIssue.forbidden => SubmissionIssue.forbidden,
      SightingIssue.blocked => SubmissionIssue.blocked,
      SightingIssue.closed => SubmissionIssue.closed,
      SightingIssue.invalid => SubmissionIssue.invalid,
      SightingIssue.photo => SubmissionIssue.photo,
      SightingIssue.rateLimited => SubmissionIssue.rateLimited,
      _ => SubmissionIssue.unavailable,
    };
  }
  return SubmissionIssue.unavailable;
}

class DispatchQueuedReports {
  DispatchQueuedReports(
    this.repository,
    this.transport, {
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;
  final LocalDraftRepository repository;
  final SubmissionTransport transport;
  final DateTime Function() now;
  final _inFlight = <(String, String), Future<SubmissionReceipt>>{};

  Future<SubmissionReceipt> send(
    LocalReportDraft command, {
    required bool Function() isCurrent,
    bool resolveRejected = false,
  }) async {
    transport.validate(command);
    if (!isCurrent()) throw const SubmissionFailure(SubmissionIssue.forbidden);
    final entry = await repository.enqueue(
      command,
      resolveRejected: resolveRejected,
    );
    if (entry.receipt != null) return entry.receipt!;
    return retry(command.owner, command.id, isCurrent: isCurrent, manual: true);
  }

  Future<SubmissionReceipt> retry(
    String owner,
    String id, {
    required bool Function() isCurrent,
    bool manual = true,
  }) {
    final key = (owner, id);
    if (!isCurrent()) {
      return Future.error(const SubmissionFailure(SubmissionIssue.forbidden));
    }
    return _inFlight[key] ??= _attempt(owner, id, isCurrent, manual)
        .whenComplete(() {
          _inFlight.remove(key);
        });
  }

  Future<SubmissionReceipt> _attempt(
    String owner,
    String id,
    bool Function() isCurrent,
    bool manual,
  ) async {
    if (!isCurrent()) throw const SubmissionFailure(SubmissionIssue.forbidden);
    final entry = await repository.claimSubmission(
      owner,
      id,
      now(),
      manual: manual,
    );
    if (entry == null) {
      final known = (await repository.listQueue(
        owner,
      )).where((e) => e.command.id == id).firstOrNull;
      if (known?.receipt != null) return known!.receipt!;
      throw const SubmissionFailure(SubmissionIssue.busy);
    }
    try {
      if (!isCurrent()) {
        throw const SubmissionFailure(SubmissionIssue.forbidden);
      }
      final receipt = await transport.send(entry.command);
      await repository.completeSubmission(entry, receipt);
      try {
        await repository.remove(owner, entry.command.slot, id);
      } catch (_) {
        /* Durable receipt prevents another send. */
      }
      return receipt;
    } catch (error) {
      final issue = submissionIssue(error);
      final retryable =
          issue == SubmissionIssue.unavailable ||
          issue == SubmissionIssue.busy ||
          (issue == SubmissionIssue.forbidden && !isCurrent());
      final delay = [5, 15, 30, 60, 120][(entry.attempts - 1).clamp(0, 4)];
      await repository.failSubmission(
        entry,
        issue,
        now().add(Duration(seconds: delay)),
        retryable: retryable,
      );
      rethrow;
    }
  }

  Future<void> drain(String owner, {required bool Function() isCurrent}) async {
    final entries = await repository.listQueue(owner);
    for (final entry in entries) {
      if (!isCurrent()) return;
      if (entry.status != SubmissionStatus.pending ||
          entry.nextAttemptAt.isAfter(now())) {
        continue;
      }
      try {
        await retry(
          owner,
          entry.command.id,
          isCurrent: isCurrent,
          manual: false,
        );
      } on LocalDraftFailure {
        rethrow;
      } catch (_) {
        /* Status and bounded retry time are persisted; rejected commands stop. */
      }
    }
  }
}
