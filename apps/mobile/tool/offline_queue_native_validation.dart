// Native SQLite acceptance checks. No Auth, backend or application database.
// Run with flutter run --profile -t tool/offline_queue_native_validation.dart.
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/data/data_sources/local_draft_database.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/data/models/local_report_draft_dto.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/data/repositories/local_draft_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/entities/local_report_draft.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/entities/queued_report.dart';

void require(bool condition, String check) {
  if (!condition) throw StateError(check);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final root = await getTemporaryDirectory();
  final directory = await Directory(root.path).createTemp('queue-native-');
  final file = File(path.join(directory.path, 'validation.sqlite'));
  final opened = <LocalDraftDatabase>[];
  final checks = <String>[];
  final timings = <String, int>{};
  LocalDraftDatabase open() {
    final db = LocalDraftDatabase(NativeDatabase.createInBackground(file));
    opened.add(db);
    return db;
  }

  void passed(String check) {
    checks.add(check);
    debugPrint('QUEUE_NATIVE_CHECK_PASS $check');
  }

  try {
    final photo = Uint8List(2097152);
    for (var i = 0; i < photo.length; i++) {
      photo[i] = (i * 31 + 7) % 256;
    }
    photo.setRange(0, 3, [255, 216, 255]);
    LocalReportDraft command({
      String owner = 'A',
      String traits = 'Original',
    }) => LocalReportDraft(
      owner: owner,
      slot: 'community-search',
      id: 'native-stable-command',
      frozen: true,
      instant: DateTime.utc(2026, 10, 23, 10, 20, 30, 456),
      date: DateTime(2026, 10, 23),
      hour: 10,
      latitude: -12,
      longitude: -77,
      species: 'dog',
      traits: traits,
      photos: [for (var i = 0; i < 3; i++) FoundPhotoDraft('photo-$i', photo)],
    );

    final raw = sqlite3.open(file.path);
    try {
      raw.execute(
        'CREATE TABLE report_drafts(owner TEXT NOT NULL,slot TEXT NOT NULL,id TEXT NOT NULL,payload TEXT NOT NULL,PRIMARY KEY(owner,slot))',
      );
      raw.execute('PRAGMA user_version=1');
      raw.execute('INSERT INTO report_drafts VALUES(?,?,?,?)', [
        'A',
        'community-search',
        'native-stable-command',
        LocalReportDraftDto.encode(command()),
      ]);
    } finally {
      raw.dispose();
    }
    final watch = Stopwatch()..start();
    final db = open();
    final a = LocalDraftRepositoryImpl(db, processId: 'native-process-one');
    final restored = (await a.read('A', 'community-search'))!;
    require(restored.minute == null && restored.hour == 10, 'partial-date');
    require(restored.photos.length == 3, 'photo-count');
    final hash = sha256.convert(photo).toString();
    for (final saved in restored.photos) {
      require(saved.bytes.length == 2097152, 'photo-size');
      require(sha256.convert(saved.bytes).toString() == hash, 'photo-hash');
    }
    require(
      (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
            'user_version',
          ) ==
          2,
      'migration-version',
    );
    timings['migrationRead6MiB'] = watch.elapsedMilliseconds;
    passed('schema1_to_2_preserves_three_2MiB_photos_and_partial_date');

    watch.reset();
    await a.enqueue(restored);
    timings['enqueue6MiB'] = watch.elapsedMilliseconds;
    require((await a.listQueue('B')).isEmpty, 'queue-isolation');
    require((await a.list('B')).isEmpty, 'draft-isolation');
    passed('account_isolation');
    try {
      await a.enqueue(command(traits: 'Changed'));
      throw StateError('Changed payload accepted');
    } on SubmissionFailure catch (error) {
      require(error.issue == SubmissionIssue.conflict, 'conflict-kind');
    }
    passed('same_uuid_changed_payload_rejected');

    final db2 = open();
    final b = LocalDraftRepositoryImpl(db2, processId: 'native-process-one');
    final attempts = await Future.wait([
      a
          .claimSubmission('A', restored.id, DateTime.now(), manual: true)
          .then<Object?>((claim) => claim)
          .catchError((Object error) => error),
      b
          .claimSubmission('A', restored.id, DateTime.now(), manual: true)
          .then<Object?>((claim) => claim)
          .catchError((Object error) => error),
    ]);
    final winners = attempts.whereType<QueuedReport>().toList();
    require(winners.length == 1, 'single-claim-across-connections');
    require(
      attempts.every(
        (result) =>
            result == null ||
            result is QueuedReport ||
            result is LocalDraftFailure,
      ),
      'unexpected-concurrent-error',
    );
    passed('independent_sqlite_connections_only_one_claim');
    try {
      await a.cancelSubmission('A', restored.id);
      throw StateError('Sending command cancelled');
    } on SubmissionFailure catch (error) {
      require(error.issue == SubmissionIssue.busy, 'cancel-sending-kind');
    }
    passed('sending_command_cannot_be_discarded');

    await db2.close();
    opened.remove(db2);
    await db.close();
    opened.remove(db);
    final reopened = open();
    final next = LocalDraftRepositoryImpl(
      reopened,
      processId: 'native-process-two',
    );
    final pending = (await next.listQueue('A')).single;
    require(pending.status == SubmissionStatus.pending, 'recover-sending');
    require(pending.attempts == 1, 'preserve-attempts');
    require(
      pending.command.instant == restored.instant &&
          sha256.convert(pending.command.photos.last.bytes).toString() == hash,
      'reopened-original-payload',
    );
    passed('reopen_recovers_claim_with_original_payload');
    final retry = (await next.claimSubmission(
      'A',
      restored.id,
      DateTime.now(),
      manual: true,
    ))!;
    await next.failSubmission(
      winners.single,
      SubmissionIssue.invalid,
      DateTime.now(),
      retryable: false,
    );
    require(
      (await next.listQueue('A')).single.status == SubmissionStatus.sending,
      'stale-claim-must-not-change-current',
    );
    passed('old_claim_cannot_overwrite_new_attempt');
    await next.failSubmission(
      retry,
      SubmissionIssue.unavailable,
      DateTime.now().add(const Duration(seconds: 120)),
      retryable: true,
    );
    require(
      await next.claimSubmission('A', restored.id, DateTime.now()) == null,
      'backoff-not-enforced',
    );
    require(
      await next.claimSubmission(
            'B',
            restored.id,
            DateTime.now(),
            manual: true,
          ) ==
          null,
      'cross-account-claim',
    );
    passed('backoff_and_cross_account_claim_enforced');
    await next.cancelSubmission('A', restored.id);
    require((await next.listQueue('A')).isEmpty, 'cancel-pending');
    require(await next.read('A', restored.slot) != null, 'cancel-keeps-draft');
    passed('cancel_pending_preserves_editor_draft');

    final large = Uint8List(8388608);
    for (var i = 0; i < large.length; i++) {
      large[i] = i % 251;
    }
    final sighting = LocalReportDraft(
      owner: 'A',
      slot: 'sighting:false:native-target',
      id: 'native-sighting',
      photo: large,
    );
    watch.reset();
    await next.save(sighting);
    final reread = (await next.read('A', sighting.slot))!;
    require(
      sha256.convert(reread.photo!).toString() ==
          sha256.convert(large).toString(),
      '8MiB-evidence-hash',
    );
    timings['saveRead8MiB'] = watch.elapsedMilliseconds;
    passed('8MiB_sighting_evidence_roundtrip');
    debugPrint(
      'QUEUE_NATIVE_VALIDATION_PASS checks=${checks.length} timingsMs=$timings',
    );
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('${checks.length} SQLite checks passed')),
        ),
      ),
    );
  } catch (error, stack) {
    debugPrint('QUEUE_NATIVE_VALIDATION_FAIL $error\n$stack');
    rethrow;
  } finally {
    for (final db in opened.reversed) {
      await db.close();
    }
    await directory.delete(recursive: true);
  }
}
