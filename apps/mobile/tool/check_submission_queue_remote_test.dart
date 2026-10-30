// Opt-in against a DEVELOPMENT backend. Creates identified QA records, then
// removes cases and archives the QA pet through the existing authorized APIs.
// Credentials/session stay in ignored config/profile_test.local.json.
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:sqlite3/open.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/core/data_sources/photo_gallery_source.dart';
import 'package:flutter_application_entrehuellas/core/domain/utils/new_entity_id.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/data/data_sources/supabase_found_case_data_source.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/data/repositories/found_case_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/use_cases/found_case_actions.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/data/data_sources/supabase_lost_case_data_source.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/data/repositories/lost_case_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/entities/lost_case.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/use_cases/publish_lost_case.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/data/data_sources/local_draft_database.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/data/repositories/local_draft_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/entities/local_report_draft.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/entities/queued_report.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/use_cases/dispatch_queued_reports.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/use_cases/submission_transport.dart';
import 'package:flutter_application_entrehuellas/features/pets/data/data_sources/supabase_pet_data_source.dart';
import 'package:flutter_application_entrehuellas/features/pets/data/data_sources/supabase_pet_photo_source.dart';
import 'package:flutter_application_entrehuellas/features/pets/data/repositories/pet_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/sightings/data/data_sources/sighting_source.dart';
import 'package:flutter_application_entrehuellas/features/sightings/data/repositories/sighting_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/sightings/domain/use_cases/sighting_actions.dart';

class FaultClient extends http.BaseClient {
  final inner = http.Client();
  String? loseResponsePath;
  String? afterCommitPath;
  Future<void> Function()? afterCommit;
  final paths = <String, int>{};
  bool offline = false;
  int requests = 0, lostResponses = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests++;
    paths.update(request.url.path, (count) => count + 1, ifAbsent: () => 1);
    if (offline) throw http.ClientException('QA offline');
    final response = await inner.send(request);
    if (afterCommitPath == request.url.path &&
        response.statusCode >= 200 &&
        response.statusCode < 300) {
      afterCommitPath = null;
      await afterCommit?.call();
    }
    if (loseResponsePath == request.url.path &&
        response.statusCode >= 200 &&
        response.statusCode < 300) {
      await response.stream.drain<void>();
      loseResponsePath = null;
      lostResponses++;
      throw http.ClientException('QA response lost after server commit');
    }
    return response;
  }

  @override
  void close() => inner.close();
}

void main() {
  final config =
      jsonDecode(File('config/profile_test.local.json').readAsStringSync())
          as Map<String, dynamic>;
  final fault = FaultClient();
  final faultB = FaultClient();
  final webFault = FaultClient();
  late SupabaseClient a, b;
  late String owner, other;
  late Pet pet;
  final petId = newEntityId(), petPhotoId = newEntityId();
  final lostId = newEntityId(),
      searchId = newEntityId(),
      noticeId = newEntityId();
  final sightingId = newEntityId();
  late Uint8List jpeg;
  late LostCaseRepositoryImpl lost;
  late FoundCaseRepositoryImpl found;
  late FoundCaseRepositoryImpl foundB;
  late PetRepositoryImpl pets;
  final dbs = <LocalDraftDatabase>[];
  final temporaries = <Directory>[];
  final createdFound = <String>[];
  final createdFoundB = <String>[];
  var createdPet = false, createdLost = false;
  late SubmissionTransport transport;
  late SubmissionTransport transportB;
  LocalDraftRepositoryImpl local(File file, String process) {
    final db = LocalDraftDatabase(NativeDatabase(file));
    dbs.add(db);
    return LocalDraftRepositoryImpl(db, processId: process);
  }

  Future<File> databaseFile() async {
    final dir = await Directory.systemTemp.createTemp('eh-remote-queue-');
    temporaries.add(dir);
    return File('${dir.path}/queue.sqlite');
  }

  void checkpoint(String value) => debugPrint('QUEUE_REMOTE_PASS $value');

  setUpAll(() async {
    if (Platform.isWindows) {
      open.overrideFor(
        OperatingSystem.windows,
        () => DynamicLibrary.open('winsqlite3.dll'),
      );
    }
    a = SupabaseClient(
      config['SUPABASE_URL'] as String,
      config['SUPABASE_PUBLISHABLE_KEY'] as String,
      httpClient: fault,
    );
    b = SupabaseClient(
      config['SUPABASE_URL'] as String,
      config['SUPABASE_PUBLISHABLE_KEY'] as String,
      httpClient: faultB,
    );
    await a.auth.signInWithPassword(
      email: config['PROFILE_TEST_EMAIL_A'] as String,
      password: config['PROFILE_TEST_PASSWORD_A'] as String,
    );
    final refreshB = config['PROFILE_TEST_REFRESH_TOKEN_B'] as String?;
    if (refreshB != null && refreshB.isNotEmpty) {
      final result = await b.auth.setSession(refreshB);
      config['PROFILE_TEST_REFRESH_TOKEN_B'] = result.session!.refreshToken;
      File(
        'config/profile_test.local.json',
      ).writeAsStringSync(jsonEncode(config));
    } else {
      await b.auth.signInWithPassword(
        email: config['PROFILE_TEST_EMAIL_B'] as String,
        password: config['PROFILE_TEST_PASSWORD_B'] as String,
      );
    }
    owner = a.auth.currentUser!.id;
    other = b.auth.currentUser!.id;
    expect(owner, isNot(other), reason: 'Distinct QA accounts are required.');
    checkpoint('two_distinct_authenticated_accounts');
    lost = LostCaseRepositoryImpl(SupabaseLostCaseDataSource(a));
    found = FoundCaseRepositoryImpl(
      SupabaseFoundCaseDataSource(a),
      NativePhotoGallerySource(ImagePicker()),
    );
    foundB = FoundCaseRepositoryImpl(
      SupabaseFoundCaseDataSource(b),
      NativePhotoGallerySource(ImagePicker()),
    );
    final sightingB = SightingRepositoryImpl(
      NativeSightingSource(
        b,
        webFault,
        ImagePicker(),
        config['PUBLIC_CASE_WEB_URL'] as String? ?? 'https://entrehuellas.app',
      ),
    );
    transportB = SubmissionTransport(
      () => PublishLostCase(
        LostCaseRepositoryImpl(SupabaseLostCaseDataSource(b)),
      ),
      () => PublishFoundCase(foundB),
      () => SubmitSighting(sightingB),
    );
    pets = PetRepositoryImpl(SupabasePetDataSource(a));
    final sighting = SightingRepositoryImpl(
      NativeSightingSource(
        a,
        webFault,
        ImagePicker(),
        config['PUBLIC_CASE_WEB_URL'] as String? ?? 'https://entrehuellas.app',
      ),
    );
    transport = SubmissionTransport(
      () => PublishLostCase(lost),
      () => PublishFoundCase(found),
      () => SubmitSighting(sighting),
    );
    final decoded = image.decodePng(
      File('assets/onboarding/dog_waving.png').readAsBytesSync(),
    )!;
    jpeg = Uint8List.fromList(
      image.encodeJpg(image.copyResize(decoded, width: 320), quality: 85),
    );
    File('build/queue-remote-fixtures.json').writeAsStringSync(
      jsonEncode({
        'pet': petId,
        'petPhoto': petPhotoId,
        'lost': lostId,
        'search': searchId,
        'notice': noticeId,
        'sighting': sightingId,
      }),
    );
    pet = await pets.create(
      owner,
      petId,
      const PetFields(
        name: 'QA cola offline',
        species: PetSpecies.dog,
        size: PetSize.medium,
        ageMonths: 24,
        traits: 'Registro automatizado de desarrollo',
        sex: PetSex.male,
      ),
    );
    createdPet = true;
    final uploaded = await SupabasePetPhotoSource(
      a,
    ).upload(owner, petId, petPhotoId, jpeg);
    expect(uploaded.toEntity().ready, isTrue);
    pet = await pets.read(owner, petId);
    checkpoint('real_jpeg_processed_and_private_pet_ready');
  });

  tearDown(() async {
    for (final db in dbs.reversed) {
      await db.close();
    }
    dbs.clear();
    for (final dir in temporaries) {
      await dir.delete(recursive: true);
    }
    temporaries.clear();
  });

  tearDownAll(() async {
    fault.offline = false;
    fault.loseResponsePath = null;
    webFault.loseResponsePath = null;
    faultB.loseResponsePath = null;
    for (final id in createdFoundB.reversed) {
      await foundB.delete(other, id);
    }
    for (final id in createdFound.reversed) {
      await found.delete(owner, id);
    }
    if (createdLost) await lost.delete(owner, lostId);
    if (createdPet) {
      final current = await pets.read(owner, petId);
      if (current.caseHistoryAt == null) {
        await pets.delete(owner, petId, current.version);
      } else {
        await pets.archive(owner, petId, current.version);
      }
    }
    await a.dispose();
    await b.dispose();
    webFault.close();
    checkpoint('qa_cases_removed_and_pet_removed_or_archived');
  });

  test(
    'Hosted lost: offline, lost ACK, restart, concurrent replay and durable receipt',
    () async {
      final file = await databaseFile();
      final repo = local(file, 'remote-one');
      final dispatcher = DispatchQueuedReports(repo, transport);
      final command = LocalReportDraft(
        owner: owner,
        slot: 'lost',
        id: lostId,
        frozen: true,
        pet: pet,
        instant: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
        latitude: -12.0464,
        longitude: -77.0428,
        place: 'QA offline development',
        selectedPhotos: [petPhotoId],
      );
      await repo.save(command);
      fault.offline = true;
      await expectLater(
        dispatcher.send(command, isCurrent: () => true),
        throwsA(isA<CaseFailure>()),
      );
      expect(
        (await repo.listQueue(owner)).single.status,
        SubmissionStatus.pending,
      );
      fault.offline = false;
      fault.loseResponsePath = '/rest/v1/rpc/publish_lost_case';
      await expectLater(
        dispatcher.retry(owner, lostId, isCurrent: () => true),
        throwsA(isA<CaseFailure>()),
      );
      expect(fault.lostResponses, 1);
      createdLost = true;
      expect(
        (await lost.listMine(owner)).where((value) => value.id == lostId),
        hasLength(1),
      );
      await dbs.last.close();
      dbs.removeLast();
      final reopened = local(file, 'remote-two');
      final restarted = DispatchQueuedReports(reopened, transport);
      final receipt = await restarted.retry(
        owner,
        lostId,
        isCurrent: () => true,
      );
      expect(receipt.id, lostId);
      final before = fault.requests;
      expect((await restarted.send(command, isCurrent: () => true)).id, lostId);
      expect(
        fault.requests,
        before,
        reason: 'Durable receipt must avoid HTTP.',
      );
      expect(
        (await reopened.listQueue(owner)).single.status,
        SubmissionStatus.published,
      );
      expect(await reopened.read(owner, 'lost'), isNull);
      final draft = LostCaseDraft(
        id: lostId,
        petId: petId,
        petVersion: pet.version,
        occurredAt: command.instant!,
        latitude: command.latitude!,
        longitude: command.longitude!,
        placeReference: command.place,
        photoIds: command.selectedPhotos,
      );
      final concurrent = await Future.wait([
        lost.publish(owner, draft),
        lost.publish(owner, draft),
      ]);
      expect(concurrent.map((value) => value.id).toSet(), {lostId});
      await expectLater(
        lost.publish(
          owner,
          LostCaseDraft(
            id: lostId,
            petId: petId,
            petVersion: pet.version,
            occurredAt: command.instant!,
            latitude: command.latitude!,
            longitude: command.longitude!,
            placeReference: 'QA changed payload',
            photoIds: command.selectedPhotos,
          ),
        ),
        throwsA(
          isA<CaseFailure>().having(
            (error) => error.kind,
            'conflict',
            CaseFailureKind.conflict,
          ),
        ),
      );
      expect(
        (await lost.listMine(owner)).where((value) => value.id == lostId),
        hasLength(1),
      );
      checkpoint(
        'lost_response_loss_restart_concurrent_replay_no_duplicate_no_http_after_receipt',
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test(
    'Hosted community search: photos, lost ACK and same command retry',
    () async {
      final repo = local(await databaseFile(), 'search');
      final dispatcher = DispatchQueuedReports(repo, transport);
      final command = LocalReportDraft(
        owner: owner,
        slot: 'community-search',
        id: searchId,
        frozen: true,
        instant: DateTime.now().toUtc().subtract(const Duration(minutes: 4)),
        latitude: -12.0464,
        longitude: -77.0428,
        place: 'QA offline development',
        species: 'dog',
        traits: 'QA búsqueda automatizada',
        size: 'medium',
        sex: 'male',
        photos: [
          for (var i = 0; i < 3; i++) FoundPhotoDraft(newEntityId(), jpeg),
        ],
      );
      createdFound.add(searchId);
      fault.loseResponsePath = '/rest/v1/rpc/publish_recovery_report';
      final losses = fault.lostResponses;
      await expectLater(
        dispatcher.send(command, isCurrent: () => true),
        throwsA(isA<FoundFailure>()),
      );
      expect(fault.lostResponses, losses + 1);
      final receipt = await dispatcher.retry(
        owner,
        searchId,
        isCurrent: () => true,
      );
      expect(receipt.id, searchId);
      expect(
        (await found.listMine(owner)).where((value) => value.id == searchId),
        hasLength(1),
      );
      expect((await repo.listQueue(owner)).single.command.photos, isEmpty);
      FoundCaseDraft changed({required bool replacePhotos}) => FoundCaseDraft(
        id: command.id,
        occurredAt: command.instant!,
        latitude: command.latitude!,
        longitude: command.longitude!,
        placeReference: command.place,
        species: command.species,
        size: command.size,
        sex: command.sex,
        traits: replacePhotos ? command.traits : '${command.traits} changed',
        photos: replacePhotos
            ? [FoundPhotoDraft(newEntityId(), jpeg)]
            : command.photos,
      );
      for (final replacePhotos in [false, true]) {
        await expectLater(
          found.publish(owner, changed(replacePhotos: replacePhotos)),
          throwsA(
            isA<FoundFailure>().having(
              (error) => error.kind,
              'conflict',
              FoundFailureKind.conflict,
            ),
          ),
        );
      }
      checkpoint(
        'community_search_real_photo_ack_loss_one_publication_prepare_and_publish_conflicts',
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test(
    'Hosted linked found: second author, real JPEG, lost ACK and deduplicated retry',
    () async {
      final repo = local(await databaseFile(), 'notice');
      final dispatcher = DispatchQueuedReports(repo, transportB);
      final command = LocalReportDraft(
        owner: other,
        slot: 'found:false:$lostId',
        id: noticeId,
        reportKind: 'with_reporter',
        frozen: true,
        instant: DateTime.now().toUtc().subtract(const Duration(minutes: 3)),
        latitude: -12.0464,
        longitude: -77.0428,
        place: 'QA notice development',
        species: 'dog',
        traits: 'QA encontrado automatizado',
        custody: 'with_me',
        photos: [FoundPhotoDraft(newEntityId(), jpeg)],
      );
      createdFoundB.add(noticeId);
      faultB.loseResponsePath = '/rest/v1/rpc/publish_recovery_report';
      await expectLater(
        dispatcher.send(command, isCurrent: () => true),
        throwsA(isA<FoundFailure>()),
      );
      expect(faultB.lostResponses, 1);
      final result = await dispatcher.retry(
        other,
        noticeId,
        isCurrent: () => true,
      );
      expect(result.id, noticeId);
      expect(
        (await foundB.listMine(other)).where((value) => value.id == noticeId),
        hasLength(1),
      );
      final requests = faultB.requests;
      await dispatcher.send(command, isCurrent: () => true);
      expect(faultB.requests, requests);
      checkpoint(
        'linked_found_second_author_real_jpeg_ack_loss_one_publication',
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test(
    'Hosted sighting: actual Nuxt endpoint, evidence, lost ACK and identical receipt',
    () async {
      final repo = local(await databaseFile(), 'sighting');
      final dispatcher = DispatchQueuedReports(repo, transportB);
      final command = LocalReportDraft(
        owner: other,
        slot: 'sighting:false:$lostId',
        id: sightingId,
        frozen: true,
        instant: DateTime.now().toUtc().subtract(const Duration(minutes: 2)),
        latitude: -12.0464,
        longitude: -77.0428,
        comment: 'QA avistamiento cola',
        photo: jpeg,
      );
      webFault.loseResponsePath = '/api/app/cases/lost/$lostId/sightings';
      await expectLater(
        dispatcher.send(command, isCurrent: () => true),
        throwsA(anything),
      );
      expect(webFault.lostResponses, 1);
      final receipt = await dispatcher.retry(
        other,
        sightingId,
        isCurrent: () => true,
      );
      expect(receipt.id, sightingId);
      final before = webFault.requests;
      final replay = await dispatcher.send(command, isCurrent: () => true);
      expect(replay.sighting!.receivedAt, receipt.sighting!.receivedAt);
      expect(webFault.requests, before);
      expect((await repo.listQueue(other)).single.command.photo, isNull);
      expect(
        (await repo.listQueue(other)).single.status,
        SubmissionStatus.published,
      );
      checkpoint(
        'nuxt_sighting_real_evidence_ack_loss_same_receipt_no_http_replay',
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test(
    'Hosted accounts: private rows, denied authorship and logout stop sending',
    () async {
      expect(await b.from('pets').select('id').eq('id', petId), isEmpty);
      await expectLater(
        b.rpc('delete_lost_case', params: {'p_id': lostId}),
        throwsA(
          isA<PostgrestException>().having(
            (error) => error.code,
            'authorization SQLSTATE',
            '42501',
          ),
        ),
      );
      final repo = local(await databaseFile(), 'logout');
      final command = LocalReportDraft(
        owner: other,
        slot: 'community-search',
        id: newEntityId(),
        frozen: true,
        instant: DateTime.now().toUtc().subtract(const Duration(minutes: 2)),
        latitude: -12,
        longitude: -77,
        place: 'QA isolation',
        species: 'dog',
        traits: 'QA',
        photos: [FoundPhotoDraft(newEntityId(), jpeg)],
      );
      await repo.enqueue(command);
      final dispatcher = DispatchQueuedReports(repo, transport);
      final before = fault.requests;
      await dispatcher.drain(other, isCurrent: () => false);
      expect(fault.requests, before);
      expect(await repo.listQueue(owner), isEmpty);
      await expectLater(
        dispatcher.retry(other, command.id, isCurrent: () => true),
        throwsA(isA<FoundFailure>()),
      );
      expect(
        (await repo.listQueue(other)).single.status,
        SubmissionStatus.failed,
      );
      expect(
        (await repo.listQueue(other)).single.issue,
        SubmissionIssue.forbidden,
      );
      checkpoint(
        'private_rows_cross_author_denied_logout_no_http_wrong_identity_failed',
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'Hosted session revocation between commit and ACK stops next item and safely resumes',
    () async {
      final repo = local(await databaseFile(), 'revocation');
      final dispatcher = DispatchQueuedReports(repo, transport);
      final commands = [
        for (var i = 0; i < 2; i++)
          LocalReportDraft(
            owner: owner,
            slot: 'community-search',
            id: newEntityId(),
            frozen: true,
            instant: DateTime.now().toUtc().subtract(
              const Duration(minutes: 1),
            ),
            latitude: -12,
            longitude: -77,
            place: 'QA session revocation',
            species: 'dog',
            traits: 'QA sesión $i',
            photos: [FoundPhotoDraft(newEntityId(), jpeg)],
          ),
      ];
      for (final command in commands) {
        createdFound.add(command.id);
        await repo.enqueue(command);
      }
      const endpoint = '/rest/v1/rpc/publish_recovery_report';
      final before = fault.paths[endpoint] ?? 0;
      final oldRefresh = a.auth.currentSession!.refreshToken!;
      fault.afterCommitPath = endpoint;
      fault.afterCommit = () => a.auth.signOut(scope: SignOutScope.local);
      bool current() => a.auth.currentUser?.id == owner;
      await dispatcher.drain(owner, isCurrent: current);
      expect(current(), isFalse);
      expect((fault.paths[endpoint] ?? 0) - before, 1);
      expect(
        (await repo.listQueue(
          owner,
        )).every((entry) => entry.status == SubmissionStatus.pending),
        isTrue,
      );
      final revoked = SupabaseClient(
        config['SUPABASE_URL'] as String,
        config['SUPABASE_PUBLISHABLE_KEY'] as String,
      );
      try {
        await expectLater(
          revoked.auth.setSession(oldRefresh),
          throwsA(isA<AuthException>()),
        );
      } finally {
        await revoked.dispose();
      }
      await a.auth.signInWithPassword(
        email: config['PROFILE_TEST_EMAIL_A'] as String,
        password: config['PROFILE_TEST_PASSWORD_A'] as String,
      );
      for (final command in commands) {
        final result = await dispatcher.retry(
          owner,
          command.id,
          isCurrent: current,
        );
        expect(result.id, command.id);
      }
      expect(
        (await repo.listQueue(
          owner,
        )).every((entry) => entry.status == SubmissionStatus.published),
        isTrue,
      );
      final published = await found.listMine(owner);
      for (final command in commands) {
        expect(
          published.where((entry) => entry.id == command.id),
          hasLength(1),
        );
      }
      checkpoint(
        'session_revoked_refresh_rejected_next_item_stopped_relogin_same_uuid',
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
