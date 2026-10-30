import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/use_cases/local_draft_actions.dart';
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/data/data_sources/local_draft_database.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/data/models/local_report_draft_dto.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/data/repositories/local_draft_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/entities/local_report_draft.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/entities/queued_report.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/use_cases/dispatch_queued_reports.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/use_cases/submission_transport.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/entities/lost_case.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/use_cases/publish_lost_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/use_cases/found_case_actions.dart';
import 'package:flutter_application_entrehuellas/features/sightings/domain/use_cases/sighting_actions.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'lost_cases_test.dart' show FakeCases, fields;
import 'found_cases_test.dart' show FakeFoundCases;
import 'sightings_test.dart' show FakeSightings;
import 'offline_drafts_test.dart' show removeTemporaryDatabaseDirectory;

LocalReportDraft command({
  String owner = 'A',
  String id = 'stable',
  String place = 'Parque',
  String name = 'Luna',
}) => LocalReportDraft(
  owner: owner,
  slot: 'lost',
  id: id,
  frozen: true,
  instant: DateTime.utc(2026, 1, 1, 10, 30, 15, 123),
  latitude: -12,
  longitude: -77,
  place: place,
  selectedPhotos: ['photo'],
  pet: Pet(
    id: 'pet',
    ownerId: owner,
    fields: PetFields(
      name: name,
      species: fields.species,
      size: fields.size,
      ageMonths: fields.ageMonths,
      traits: fields.traits,
    ),
    version: 7,
  ),
);

class IdempotentCases extends FakeCases {
  final stored = <String, PublishedLostCase>{};
  int writes = 0;
  bool offline = false, loseAck = false;
  Completer<void>? gate;
  Completer<void> started = Completer<void>();
  @override
  Future<PublishedLostCase> publish(String owner, LostCaseDraft draft) async {
    attempts.add(draft);
    if (!started.isCompleted) started.complete();
    if (offline) throw const CaseFailure(CaseFailureKind.unavailable);
    final receipt = stored.putIfAbsent(draft.id, () {
      writes++;
      return PublishedLostCase(
        id: draft.id,
        ownerId: owner,
        petId: draft.petId,
        status: 'active',
      );
    });
    await gate?.future;
    if (loseAck) {
      loseAck = false;
      throw const CaseFailure(CaseFailureKind.unavailable);
    }
    return receipt;
  }
}

SubmissionTransport transport(
  FakeCases cases, {
  FakeFoundCases? found,
  FakeSightings? sightings,
}) => SubmissionTransport(
  () => PublishLostCase(cases),
  () => PublishFoundCase(found ?? FakeFoundCases()),
  () => SubmitSighting(sightings ?? FakeSightings()),
);

class DelayedRejection extends FakeCases {
  final started = Completer<void>(), release = Completer<void>();
  @override
  Future<PublishedLostCase> publish(String owner, LostCaseDraft draft) async {
    attempts.add(draft);
    started.complete();
    await release.future;
    throw const CaseFailure(CaseFailureKind.conflict);
  }
}

void main() {
  setUpAll(() {
    if (Platform.isWindows) {
      open.overrideFor(
        OperatingSystem.windows,
        () => DynamicLibrary.open('winsqlite3.dll'),
      );
    }
  });

  test(
    'Schema 1 upgrades to 2 without losing existing drafts or account separation',
    () async {
      final dir = await Directory.systemTemp.createTemp('eh-queue-migration-');
      final file = File('${dir.path}/queue.sqlite');
      final raw = sqlite3.open(file.path);
      raw.execute(
        'CREATE TABLE report_drafts(owner TEXT NOT NULL,slot TEXT NOT NULL,id TEXT NOT NULL,payload TEXT NOT NULL,PRIMARY KEY(owner,slot))',
      );
      raw.execute('PRAGMA user_version=1');
      final d = command();
      raw.execute('INSERT INTO report_drafts VALUES(?,?,?,?)', [
        d.owner,
        d.slot,
        d.id,
        LocalReportDraftDto.encode(d),
      ]);
      raw.dispose();
      final db = LocalDraftDatabase(NativeDatabase(file));
      final repo = LocalDraftRepositoryImpl(db);
      expect((await repo.read('A', 'lost'))!.id, 'stable');
      await repo.enqueue(d);
      expect(
        (await repo.listQueue('A')).single.status,
        SubmissionStatus.pending,
      );
      expect(await repo.listQueue('B'), isEmpty);
      expect(
        (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
          'user_version',
        ),
        2,
      );
      await db.close();
      await removeTemporaryDatabaseDirectory(dir);
    },
  );

  for (final loseAfterPersist in [false, true]) {
    test(
      'Connection loss before/after persist=$loseAfterPersist reopens and confirms exactly one logical write',
      () async {
        final dir = await Directory.systemTemp.createTemp('eh-queue-restart-');
        final file = File('${dir.path}/queue.sqlite');
        var db = LocalDraftDatabase(NativeDatabase(file));
        var repo = LocalDraftRepositoryImpl(db, processId: 'first-process');
        var now = DateTime.utc(2026, 10, 23);
        final server = IdempotentCases()
          ..offline = !loseAfterPersist
          ..loseAck = loseAfterPersist;
        var dispatcher = DispatchQueuedReports(
          repo,
          transport(server),
          now: () => now,
        );
        await expectLater(
          dispatcher.send(command(), isCurrent: () => true),
          throwsA(isA<CaseFailure>()),
        );
        final before = (await repo.listQueue('A')).single;
        expect(before.status, SubmissionStatus.pending);
        expect(before.attempts, 1);
        expect(before.receipt, isNull);
        await db.close();
        db = LocalDraftDatabase(NativeDatabase(file));
        repo = LocalDraftRepositoryImpl(db, processId: 'second-process');
        dispatcher = DispatchQueuedReports(
          repo,
          transport(server),
          now: () => now,
        );
        server.offline = false;
        now = now.add(const Duration(seconds: 6));
        await dispatcher.drain('A', isCurrent: () => true);
        final after = (await repo.listQueue('A')).single;
        expect(after.status, SubmissionStatus.published);
        expect(after.receipt!.id, 'stable');
        expect(server.writes, 1);
        expect(server.attempts.map((d) => d.id), ['stable', 'stable']);
        expect(
          server.attempts.last.occurredAt,
          server.attempts.first.occurredAt,
        );
        expect(server.attempts.last.petVersion, 7);
        await dispatcher.retry('A', 'stable', isCurrent: () => true);
        expect(server.attempts, hasLength(2));
        await db.close();
        await removeTemporaryDatabaseDirectory(dir);
      },
    );
  }

  test(
    'A process killed while sending recovers the exact command and binary evidence',
    () async {
      final dir = await Directory.systemTemp.createTemp('eh-queue-claim-');
      final file = File('${dir.path}/queue.sqlite');
      var db = LocalDraftDatabase(NativeDatabase(file));
      var repo = LocalDraftRepositoryImpl(db, processId: 'dead');
      final d = LocalReportDraft(
        owner: 'A',
        slot: 'community-search',
        id: 'found-id',
        frozen: true,
        attempted: true,
        instant: DateTime.utc(2026),
        latitude: -12,
        longitude: -77,
        place: 'Parque',
        species: 'dog',
        traits: 'Manchas negras',
        photos: [
          FoundPhotoDraft('photo', Uint8List.fromList([255, 216, 255, 1, 2])),
        ],
      );
      await repo.enqueue(d);
      await repo.claimSubmission('A', 'found-id', DateTime.now(), manual: true);
      await db.close();
      db = LocalDraftDatabase(NativeDatabase(file));
      repo = LocalDraftRepositoryImpl(db, processId: 'new');
      final entry = (await repo.listQueue('A')).single;
      expect(entry.status, SubmissionStatus.pending);
      expect(entry.command.photos.single.bytes, [255, 216, 255, 1, 2]);
      final found = FakeFoundCases();
      await DispatchQueuedReports(
        repo,
        transport(FakeCases(), found: found),
      ).drain('A', isCurrent: () => true);
      expect(found.attempts.single.id, 'found-id');
      expect(
        (await repo.listQueue('A')).single.status,
        SubmissionStatus.published,
      );
      expect((await repo.listQueue('A')).single.command.photos, isEmpty);
      await db.close();
      await removeTemporaryDatabaseDirectory(dir);
    },
  );

  test(
    'Concurrent manual/automatic attempts share one flight and late failure cannot overwrite a receipt',
    () async {
      final db = LocalDraftDatabase(NativeDatabase.memory());
      final repo = LocalDraftRepositoryImpl(db);
      addTearDown(db.close);
      final server = IdempotentCases()..gate = Completer<void>();
      final dispatcher = DispatchQueuedReports(repo, transport(server));
      final first = dispatcher.send(command(), isCurrent: () => true);
      await server.started.future;
      final second = dispatcher.send(command(), isCurrent: () => true);
      final old = (await repo.listQueue('A')).single;
      server.gate!.complete();
      await Future.wait([first, second]);
      expect(server.attempts, hasLength(1));
      expect(server.writes, 1);
      await repo.failSubmission(
        old,
        SubmissionIssue.unavailable,
        DateTime.now(),
        retryable: true,
      );
      expect(
        (await repo.listQueue('A')).single.status,
        SubmissionStatus.published,
      );
    },
  );

  test(
    'Two repositories in the same process cannot claim the same command twice',
    () async {
      final db = LocalDraftDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final a = LocalDraftRepositoryImpl(db), b = LocalDraftRepositoryImpl(db);
      await a.enqueue(command());
      final claims = await Future.wait([
        a.claimSubmission('A', 'stable', DateTime.now(), manual: true),
        b.claimSubmission('A', 'stable', DateTime.now(), manual: true),
      ]);
      expect(claims.whereType<QueuedReport>(), hasLength(1));
      expect((await b.listQueue('A')).single.status, SubmissionStatus.sending);
    },
  );

  test(
    'Payload mismatch rejects before HTTP; snapshot-only changes do not change the command',
    () async {
      final db = LocalDraftDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = LocalDraftRepositoryImpl(db);
      final server = IdempotentCases();
      final dispatcher = DispatchQueuedReports(repo, transport(server));
      await repo.enqueue(command());
      await repo.enqueue(command(name: 'Updated snapshot only'));
      await expectLater(
        dispatcher.send(
          command(place: 'Different payload'),
          isCurrent: () => true,
        ),
        throwsA(isA<SubmissionFailure>()),
      );
      expect(server.attempts, isEmpty);
      expect((await repo.listQueue('A')).single.command.place, 'Parque');
    },
  );

  test(
    'Rejected commands stop automatic retries; correcting a known rejection requires explicit resolution',
    () async {
      final db = LocalDraftDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = LocalDraftRepositoryImpl(db);
      final server = FakeCases()..failure = CaseFailureKind.invalid;
      final dispatcher = DispatchQueuedReports(repo, transport(server));
      await expectLater(
        dispatcher.send(command(), isCurrent: () => true),
        throwsA(isA<CaseFailure>()),
      );
      expect(
        (await repo.listQueue('A')).single.status,
        SubmissionStatus.failed,
      );
      await dispatcher.drain('A', isCurrent: () => true);
      expect(server.attempts, hasLength(1));
      await expectLater(
        repo.enqueue(command(place: 'Corrected')),
        throwsA(isA<SubmissionFailure>()),
      );
      await repo.enqueue(command(place: 'Corrected'), resolveRejected: true);
      server.failure = null;
      await dispatcher.drain('A', isCurrent: () => true);
      expect(server.attempts.last.placeReference, 'Corrected');
      expect(
        (await repo.listQueue('A')).single.status,
        SubmissionStatus.published,
      );
      await expectLater(
        repo.enqueue(command(place: 'Another'), resolveRejected: true),
        throwsA(isA<SubmissionFailure>()),
      );
    },
  );

  test(
    'Changing account stops the remaining drain and does not expose the old account queue',
    () async {
      final db = LocalDraftDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = LocalDraftRepositoryImpl(db);
      await repo.enqueue(command(id: 'one'));
      await repo.enqueue(command(id: 'two'));
      final server = IdempotentCases()..gate = Completer<void>();
      final dispatcher = DispatchQueuedReports(repo, transport(server));
      var owner = 'A';
      final run = dispatcher.drain('A', isCurrent: () => owner == 'A');
      await server.started.future;
      owner = 'B';
      server.gate!.complete();
      await run;
      expect(server.attempts, hasLength(1));
      expect(await repo.listQueue('B'), isEmpty);
      expect(
        (await repo.listQueue(
          'A',
        )).where((e) => e.status == SubmissionStatus.pending),
        hasLength(1),
      );
      await expectLater(
        dispatcher.retry('A', 'one', isCurrent: () => false),
        throwsA(isA<SubmissionFailure>()),
      );
    },
  );

  test(
    'Lost storage never dispatches HTTP and a malformed receipt cannot confirm publication',
    () async {
      final db = LocalDraftDatabase(NativeDatabase.memory());
      final repo = LocalDraftRepositoryImpl(db);
      final server = FakeCases()..wrongOwner = true;
      final dispatcher = DispatchQueuedReports(repo, transport(server));
      await expectLater(
        dispatcher.send(command(), isCurrent: () => true),
        throwsA(isA<CaseFailure>()),
      );
      expect(
        (await repo.listQueue('A')).single.status,
        SubmissionStatus.pending,
      );
      await db.close();
      await expectLater(
        dispatcher.send(command(id: 'another'), isCurrent: () => true),
        throwsA(isA<LocalDraftFailure>()),
      );
      expect(server.attempts, hasLength(1));
    },
  );
  test(
    'Explicit discard removes pending intent but cannot revoke a flight or confirmed receipt',
    () async {
      final db = LocalDraftDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = LocalDraftRepositoryImpl(db);
      await repo.enqueue(command());
      await repo.cancelSubmission('A', 'stable');
      expect(await repo.listQueue('A'), isEmpty);
      await repo.save(command());
      await repo.enqueue(command());
      final claim = (await repo.claimSubmission(
        'A',
        'stable',
        DateTime.now(),
        manual: true,
      ))!;
      await expectLater(
        repo.cancelSubmission('A', 'stable'),
        throwsA(isA<SubmissionFailure>()),
      );
      await expectLater(
        repo.completeSubmission(
          claim,
          const SubmissionReceipt.lost(
            PublishedLostCase(
              id: 'stable',
              ownerId: 'another-account',
              petId: 'pet',
              status: 'active',
            ),
          ),
        ),
        throwsA(isA<LocalDraftFailure>()),
      );
      expect(
        (await repo.listQueue('A')).single.status,
        SubmissionStatus.sending,
      );
      await repo.completeSubmission(
        claim,
        const SubmissionReceipt.lost(
          PublishedLostCase(
            id: 'stable',
            ownerId: 'A',
            petId: 'pet',
            status: 'active',
          ),
        ),
      );
      await expectLater(
        repo.cancelSubmission('A', 'stable'),
        throwsA(isA<SubmissionFailure>()),
      );
      expect(
        (await repo.listQueue('A')).single.status,
        SubmissionStatus.published,
      );
      expect(await ListLocalDrafts(repo)('A'), isEmpty);
    },
  );
  test(
    'A terminal server rejection remains failed even if the app pauses while waiting',
    () async {
      final db = LocalDraftDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = LocalDraftRepositoryImpl(db);
      final server = DelayedRejection();
      final dispatcher = DispatchQueuedReports(repo, transport(server));
      var active = true;
      final result = dispatcher.send(command(), isCurrent: () => active);
      final expectation = expectLater(result, throwsA(isA<CaseFailure>()));
      await server.started.future;
      active = false;
      server.release.complete();
      await expectation;
      expect(
        (await repo.listQueue('A')).single.status,
        SubmissionStatus.failed,
      );
      expect(
        (await repo.listQueue('A')).single.issue,
        SubmissionIssue.conflict,
      );
    },
  );
}
