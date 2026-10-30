import 'dart:async';
import '../../../../core/domain/utils/new_entity_id.dart';
import '../../domain/entities/queued_report.dart';
import '../models/queued_report_dto.dart';
import '../../domain/entities/local_report_draft.dart';
import '../../domain/repositories/local_draft_repository.dart';
import '../data_sources/local_draft_database.dart';
import '../models/local_report_draft_dto.dart';

class LocalDraftRepositoryImpl implements LocalDraftRepository {
  LocalDraftRepositoryImpl(this.database, {String? processId})
    : _process = processId ?? _processId;
  final LocalDraftDatabase database;
  Future<void> _tail = Future.value();
  static final String _processId = newEntityId();
  final String _process;
  final _changes = StreamController<String>.broadcast(sync: true);

  @override
  Future<void> cancelSubmission(String owner, String id) => _queueOperation(
    () async {
      final state = await database.cancelQueue(owner, id);
      if (state != null) {
        throw SubmissionFailure(
          state == 'sending' ? SubmissionIssue.busy : SubmissionIssue.conflict,
        );
      }
    },
    changedOwner: owner,
  );

  Future<T> _queueOperation<T>(
    Future<T> Function() action, {
    String? changedOwner,
  }) => _ordered(() async {
    try {
      final result = await action();
      if (changedOwner != null) _changes.add(changedOwner);
      return result;
    } on QueuePayloadConflict {
      throw const SubmissionFailure(SubmissionIssue.conflict);
    } on SubmissionFailure {
      rethrow;
    } catch (_) {
      throw const LocalDraftFailure();
    }
  });
  @override
  Future<QueuedReport> enqueue(
    LocalReportDraft command, {
    bool resolveRejected = false,
  }) => _queueOperation(() async {
    if (!_owned(command, command.owner) || !command.frozen) {
      throw const LocalDraftFailure();
    }
    final row = await database.enqueueSubmission(
      command.owner,
      command.id,
      LocalReportDraftDto.encode(command),
      QueuedReportDto.fingerprint(command),
      DateTime.now().toUtc().millisecondsSinceEpoch,
      resolveRejected,
    );
    return QueuedReportDto.decode(row);
  }, changedOwner: command.owner);
  @override
  Future<List<QueuedReport>> listQueue(String owner) =>
      _queueOperation(() async {
        await database.recoverQueue(owner, _process);
        final entries = (await database.queueRows(
          owner,
        )).map(QueuedReportDto.decode).toList();
        if (entries.any((e) => !_owned(e.command, owner))) {
          throw const LocalDraftFailure();
        }
        return List.unmodifiable(entries);
      });
  @override
  Stream<List<QueuedReport>> watchQueue(String owner) =>
      Stream.multi((controller) {
        var active = true;
        Future<void> tail = Future.value();
        void emit() {
          tail = tail.then((_) async {
            try {
              final rows = await listQueue(owner);
              if (active) controller.add(rows);
            } catch (error, stack) {
              if (active) controller.addError(error, stack);
            }
          });
        }

        final subscription = _changes.stream
            .where((changed) => changed == owner)
            .listen((_) => emit());
        emit();
        controller.onCancel = () {
          active = false;
          return subscription.cancel();
        };
      });
  @override
  Future<QueuedReport?> claimSubmission(
    String owner,
    String id,
    DateTime now, {
    bool manual = false,
  }) => _queueOperation(() async {
    final row = await database.claimQueue(
      owner,
      id,
      _process,
      newEntityId(),
      now.toUtc().millisecondsSinceEpoch,
      manual,
    );
    return row == null ? null : QueuedReportDto.decode(row);
  }, changedOwner: owner);
  @override
  Future<void> completeSubmission(
    QueuedReport claim,
    SubmissionReceipt receipt,
  ) => _queueOperation(() async {
    final d = claim.command;
    if (!QueuedReportDto.receiptMatches(d, receipt) || claim.claim == null) {
      throw const LocalDraftFailure();
    }
    await database.completeQueue(
      d.owner,
      d.id,
      claim.claim!,
      QueuedReportDto.encodeReceipt(receipt),
      QueuedReportDto.withoutEvidence(LocalReportDraftDto.encode(d)),
    );
  }, changedOwner: claim.command.owner);
  @override
  Future<void> failSubmission(
    QueuedReport claim,
    SubmissionIssue issue,
    DateTime nextAttemptAt, {
    required bool retryable,
  }) => _queueOperation(() async {
    if (claim.claim == null) throw const LocalDraftFailure();
    await database.failQueue(
      claim.command.owner,
      claim.command.id,
      claim.claim!,
      retryable ? 'pending' : 'failed',
      issue.name,
      nextAttemptAt.toUtc().millisecondsSinceEpoch,
    );
  }, changedOwner: claim.command.owner);

  @override
  Future<List<LocalReportDraft>> list(String owner) => _ordered(() async {
    try {
      final drafts = (await database.listPayloads(
        owner,
      )).map(LocalReportDraftDto.decode).toList();
      if (drafts.any((d) => !_owned(d, owner))) throw const LocalDraftFailure();
      return List.unmodifiable(drafts);
    } catch (_) {
      throw const LocalDraftFailure();
    }
  });

  bool _owned(LocalReportDraft d, String owner) =>
      d.owner == owner &&
      (d.pet == null || d.pet!.ownerId == owner) &&
      d.pets.every((p) => p.ownerId == owner) &&
      d.petPhotos.every((p) => p.ownerId == owner);

  // Order edits, receipts and reads even when a widget is disposed mid-write.
  Future<T> _ordered<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  @override
  Future<LocalReportDraft?> read(String owner, String slot) =>
      _ordered(() async {
        try {
          final payload = await database.readPayload(owner, slot);
          if (payload == null) return null;
          final draft = LocalReportDraftDto.decode(payload);
          if (draft.owner != owner ||
              draft.slot != slot ||
              draft.pets.any((p) => p.ownerId != owner) ||
              (draft.pet != null && draft.pet!.ownerId != owner) ||
              draft.petPhotos.any((p) => p.ownerId != owner)) {
            throw const LocalDraftFailure();
          }
          return draft;
        } catch (_) {
          throw const LocalDraftFailure();
        }
      });
  @override
  Future<void> save(LocalReportDraft draft) {
    // Capture bytes now, before the caller edits the next revision.
    final String payload;
    try {
      if (!_owned(draft, draft.owner)) throw const LocalDraftFailure();
      payload = LocalReportDraftDto.encode(draft);
    } catch (_) {
      return Future.error(const LocalDraftFailure());
    }
    return _ordered(() async {
      try {
        await database.put(draft.owner, draft.slot, draft.id, payload);
      } catch (_) {
        throw const LocalDraftFailure();
      }
    });
  }

  @override
  Future<void> remove(String owner, String slot, String id) =>
      _ordered(() async {
        try {
          await database.remove(owner, slot, id);
        } catch (_) {
          throw const LocalDraftFailure();
        }
      });
}
