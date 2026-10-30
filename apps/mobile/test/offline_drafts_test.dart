import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:sqlite3/open.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/data/data_sources/local_draft_database.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/data/models/local_report_draft_dto.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/data/repositories/local_draft_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/entities/local_report_draft.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/repositories/local_draft_repository.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/providers/local_draft_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/providers/lost_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/presentation/view_models/case_editor_view_model.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/providers/found_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/view_models/found_editor_view_model.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet_photo.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/sightings/domain/entities/sighting.dart';
import 'package:flutter_application_entrehuellas/features/sightings/providers/sighting_providers.dart';
import 'package:flutter_application_entrehuellas/features/sightings/presentation/view_models/sighting_view_model.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/data/data_sources/offline_onboarding_data_source.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/data/data_sources/onboarding_completion_cache.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/data/data_sources/onboarding_data_source.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/data/models/onboarding_record_dto.dart';
import 'support/fake_local_drafts.dart';
import 'support/fake_pets.dart';
import 'support/fake_pet_photos.dart';
import 'lost_cases_test.dart' show fields, FakeCases;
import 'found_cases_test.dart' show FakeFoundCases;
import 'sightings_test.dart' show FakeSightings, target;

ProviderContainer editors(
  LocalDraftRepository local, {
  FakeCases? cases,
  FakePets? pets,
  FakePetPhotos? photos,
  FakeFoundCases? found,
  FakeSightings? sightings,
  String owner = 'owner',
  Stream<AuthSession?>? sessions,
  FoundEditorContext context = const FoundEditorContext(),
}) => ProviderContainer(
  overrides: [
    localDraftRepositoryProvider.overrideWithValue(local),
    caseSessionProvider.overrideWith(
      (ref) => sessions ?? Stream.value(AuthSession(userId: owner)),
    ),
    foundSessionProvider.overrideWith(
      (ref) => sessions ?? Stream.value(AuthSession(userId: owner)),
    ),
    sightingSessionProvider.overrideWith(
      (ref) => sessions ?? Stream.value(AuthSession(userId: owner)),
    ),
    petRepositoryProvider.overrideWithValue(pets ?? FakePets()),
    petPhotoRepositoryProvider.overrideWithValue(photos ?? FakePetPhotos()),
    lostCaseRepositoryProvider.overrideWithValue(cases ?? FakeCases()),
    foundCaseRepositoryProvider.overrideWithValue(found ?? FakeFoundCases()),
    sightingRepositoryProvider.overrideWithValue(sightings ?? FakeSightings()),
    sightingTargetProvider.overrideWithValue(target),
    foundEditorContextProvider.overrideWithValue(context),
  ],
);

class MemoryOnboardingCache implements OnboardingCompletionCache {
  final values = <String, bool>{};
  @override
  Future<bool?> read(String owner) async => values[owner];
  @override
  Future<void> write(String owner, bool completed) async {
    values[owner] = completed;
  }
}

class TestOnboardingSource implements OnboardingDataSource {
  Object? failure;
  bool completed = true;
  @override
  Future<OnboardingRecordDto> read(String userId) async {
    if (failure != null) throw failure!;
    return OnboardingRecordDto(completed: completed);
  }

  @override
  Future<void> complete() async {
    if (failure != null) throw failure!;
  }
}

Future<void> removeTemporaryDatabaseDirectory(Directory directory) async {
  final root = await Directory.systemTemp.resolveSymbolicLinks();
  final target = await directory.resolveSymbolicLinks();
  if (!target.startsWith('$root${Platform.pathSeparator}')) {
    throw StateError('Unexpected cleanup target');
  }
  await directory.delete(recursive: true);
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
    'Lost frozen checkpoint retries original pet version, instant and evidence after restart',
    () async {
      final local = FakeLocalDrafts();
      final pet = Pet(id: 'pet', ownerId: 'owner', fields: fields, version: 7);
      final instant = DateTime.utc(2026, 1, 1, 10, 30, 15, 123);
      await local.save(
        LocalReportDraftDto.decode(
          LocalReportDraftDto.encode(
            LocalReportDraft(
              owner: 'owner',
              slot: 'lost',
              id: 'original-lost-command',
              pet: pet,
              pets: [pet],
              instant: instant,
              latitude: -12,
              longitude: -77,
              place: 'Frente al parque',
              selectedPhotos: ['photo'],
              frozen: true,
              petPhotos: [
                const PetPhoto(
                  id: 'photo',
                  petId: 'pet',
                  ownerId: 'owner',
                  ready: true,
                ),
              ],
            ),
          ),
        ),
      );
      final cases = FakeCases();
      final c = editors(local, cases: cases);
      addTearDown(c.dispose);
      c.listen(caseEditorViewModelProvider, (_, _) {});
      final restored = await c.read(caseEditorViewModelProvider.future);
      expect(restored.lockedDraft!.petVersion, 7);
      await c.read(caseEditorViewModelProvider.notifier).publish();
      expect(cases.attempts.single.id, 'original-lost-command');
      expect(cases.attempts.single.occurredAt, instant);
      expect(cases.attempts.single.photoIds, ['photo']);
      expect(await local.read('owner', 'lost'), isNull);
    },
  );
  test(
    'Found frozen checkpoint preserves photo bytes and only discards after server confirmation',
    () async {
      final local = FakeLocalDrafts();
      final instant = DateTime.utc(2026, 1, 1, 10, 30, 15, 123);
      await local.save(
        LocalReportDraftDto.decode(
          LocalReportDraftDto.encode(
            LocalReportDraft(
              owner: 'owner',
              slot: 'community-search',
              id: 'original-found-command',
              instant: instant,
              latitude: -12,
              longitude: -77,
              place: 'Frente al parque',
              species: 'dog',
              traits: 'Manchas negras',
              frozen: true,
              attempted: true,
              photos: [
                FoundPhotoDraft(
                  'photo',
                  Uint8List.fromList([255, 216, 255, 1, 2]),
                ),
              ],
            ),
          ),
        ),
      );
      final found = FakeFoundCases()..failDiscard = true;
      final c = editors(local, found: found);
      addTearDown(c.dispose);
      c.listen(foundEditorViewModelProvider, (_, _) {});
      await c.read(foundEditorViewModelProvider.future);
      final m = c.read(foundEditorViewModelProvider.notifier);
      expect(await m.discardLocalDraft('original-found-command'), isFalse);
      expect(await local.read('owner', 'community-search'), isNotNull);
      found.failDiscard = false;
      expect(await m.discardLocalDraft('original-found-command'), isTrue);
      expect(found.discards, [
        'original-found-command',
        'original-found-command',
      ]);
      expect(await local.read('owner', 'community-search'), isNull);
    },
  );
  test(
    'Found restored command publishes exact evidence and timestamp after an ambiguous result',
    () async {
      final local = FakeLocalDrafts();
      final instant = DateTime.utc(2026, 1, 1, 10, 30, 15, 123);
      await local.save(
        LocalReportDraftDto.decode(
          LocalReportDraftDto.encode(
            LocalReportDraft(
              owner: 'owner',
              slot: 'community-search',
              id: 'original-found-command',
              instant: instant,
              latitude: -12,
              longitude: -77,
              place: 'Frente al parque',
              species: 'dog',
              traits: 'Manchas negras',
              frozen: true,
              attempted: true,
              photos: [
                FoundPhotoDraft(
                  'photo',
                  Uint8List.fromList([255, 216, 255, 1, 2]),
                ),
              ],
            ),
          ),
        ),
      );
      final found = FakeFoundCases();
      final c = editors(local, found: found);
      addTearDown(c.dispose);
      c.listen(foundEditorViewModelProvider, (_, _) {});
      await c.read(foundEditorViewModelProvider.future);
      await c.read(foundEditorViewModelProvider.notifier).publish();
      expect(found.attempts.single.id, 'original-found-command');
      expect(found.attempts.single.occurredAt, instant);
      expect(found.attempts.single.photos.single.id, 'photo');
      expect(found.attempts.single.photos.single.bytes, [255, 216, 255, 1, 2]);
      expect(await local.read('owner', 'community-search'), isNull);
    },
  );
  test(
    'SQLite close/reopen restores fields, partial date, binary evidence and exact identity',
    () async {
      final directory = await Directory.systemTemp.createTemp('eh-drafts-');
      final file = File('${directory.path}/drafts.sqlite');
      var db = LocalDraftDatabase(NativeDatabase(file));
      var repository = LocalDraftRepositoryImpl(db);
      final bytes = Uint8List.fromList([0, 255, 42, 1]);
      final draft = LocalReportDraft(
        owner: 'A',
        slot: 'community-search',
        id: 'stable-id',
        date: DateTime(2026, 10, 22),
        hour: null,
        minute: null,
        traits: 'Mancha café 🐾',
        latitude: -12,
        longitude: -77,
        photos: [FoundPhotoDraft('photo-id', bytes)],
      );
      await repository.save(draft);
      bytes[0] = 99;
      await db.close();
      db = LocalDraftDatabase(NativeDatabase(file));
      repository = LocalDraftRepositoryImpl(db);
      final restored = (await repository.read('A', 'community-search'))!;
      expect(restored.id, 'stable-id');
      expect(restored.hour, isNull);
      expect(restored.date, draft.date);
      expect(restored.traits, 'Mancha café 🐾');
      expect(restored.photos.single.id, 'photo-id');
      expect(restored.photos.single.bytes, [0, 255, 42, 1]);
      expect(await repository.read('B', 'community-search'), isNull);
      expect(await repository.list('B'), isEmpty);
      await db.close();
      await removeTemporaryDatabaseDirectory(directory);
    },
  );

  test(
    'Ordered edits survive failed reads; old receipt cannot delete a newer command',
    () async {
      final db = LocalDraftDatabase(NativeDatabase.memory());
      final repository = LocalDraftRepositoryImpl(db);
      addTearDown(db.close);
      final first = repository.save(
        LocalReportDraft(
          owner: 'A',
          slot: 'lost',
          id: 'first',
          place: 'Primero',
        ),
      );
      final second = repository.save(
        LocalReportDraft(
          owner: 'A',
          slot: 'lost',
          id: 'second',
          place: 'Último',
        ),
      );
      await Future.wait([first, second]);
      await repository.remove('A', 'lost', 'first');
      expect((await repository.read('A', 'lost'))!.place, 'Último');
      await db.put('A', 'broken', 'broken', '{invalid');
      await expectLater(
        repository.read('A', 'broken'),
        throwsA(isA<LocalDraftFailure>()),
      );
      expect((await repository.read('A', 'lost'))!.id, 'second');
      await repository.remove('A', 'lost', 'second');
      expect(await repository.read('A', 'lost'), isNull);
    },
  );

  test(
    'DTO excludes expiring photo URLs, preserves pet versions and evidence references',
    () {
      final pet = Pet(
        id: 'pet',
        ownerId: 'A',
        fields: fields,
        version: 7,
        coverUri: Uri.parse('https://private.invalid/signed?token=secret'),
      );
      final data = LocalReportDraftDto.encode(
        LocalReportDraft(
          owner: 'A',
          slot: 'lost',
          id: 'id',
          pet: pet,
          pets: [pet],
          petPhotos: [
            PetPhoto(
              id: 'photo',
              petId: 'pet',
              ownerId: 'A',
              ready: true,
              uri: Uri.parse('https://private.invalid/signed?token=secret'),
            ),
          ],
          selectedPhotos: ['photo'],
        ),
      );
      expect(data, isNot(contains('secret')));
      final restored = LocalReportDraftDto.decode(data);
      expect(restored.pet!.version, 7);
      expect(restored.selectedPhotos, ['photo']);
      expect(restored.petPhotos.single.uri, isNull);
    },
  );

  test(
    'Lost editor recreates offline before requesting pets and retains selected photo IDs',
    () async {
      final local = FakeLocalDrafts();
      final pets = FakePets()
        ..pets['pet'] = const Pet(
          id: 'pet',
          ownerId: 'owner',
          fields: fields,
          version: 3,
        );
      final photos = FakePetPhotos()
        ..photos['photo'] = const PetPhoto(
          id: 'photo',
          petId: 'pet',
          ownerId: 'owner',
          ready: true,
        );
      final first = editors(local, pets: pets, photos: photos);
      first.listen(caseEditorViewModelProvider, (_, _) {});
      await first.read(caseEditorViewModelProvider.future);
      final model = first.read(caseEditorViewModelProvider.notifier);
      await model.selectPet('pet');
      model.togglePhoto('photo');
      model.chooseTime(7, 13);
      model.edit(placeReference: 'Frente al parque');
      expect(await model.saveForLater(), isTrue);
      final id = first.read(caseEditorViewModelProvider).requireValue.draftId;
      first.dispose();
      pets.fail = true;
      photos.failList = true;
      final second = editors(local, pets: pets, photos: photos);
      addTearDown(second.dispose);
      second.listen(caseEditorViewModelProvider, (_, _) {});
      final restored = await second.read(caseEditorViewModelProvider.future);
      expect(restored.draftId, id);
      expect(restored.pet!.version, 3);
      expect(restored.selectedPhotos, {'photo'});
      expect(restored.dateTimeDraft.date, isNull);
      expect(restored.dateTimeDraft.hour, 7);
      expect(restored.placeReference, 'Frente al parque');
      expect(restored.published, isNull);
      expect(restored.busy, isFalse);
      expect(
        await second
            .read(caseEditorViewModelProvider.notifier)
            .discardLocalDraft(id),
        isTrue,
      );
      expect(await local.read('owner', 'lost'), isNull);
    },
  );

  test(
    'Found fields, photos and target resume offline in the same context only',
    () async {
      final local = FakeLocalDrafts();
      const context = FoundEditorContext(
        communitySearch: false,
        targetId: 'case',
        communityTarget: false,
      );
      final d = LocalReportDraft(
        owner: 'owner',
        slot: 'found:false:case',
        id: 'same-command',
        target: const RecoverySearch(
          id: 'case',
          community: false,
          name: 'Luna',
          species: 'dog',
        ),
        species: 'dog',
        traits: 'Orejas negras',
        reportKind: 'with_reporter',
        custody: 'with_me',
        photos: [
          FoundPhotoDraft('image', Uint8List.fromList([1, 2, 3])),
        ],
      );
      await local.save(d);
      final found = FakeFoundCases()..failRead = true;
      final c = editors(local, found: found, context: context);
      addTearDown(c.dispose);
      c.listen(foundEditorViewModelProvider, (_, _) {});
      final restored = await c.read(foundEditorViewModelProvider.future);
      expect(restored.draftId, 'same-command');
      expect(restored.target!.name, 'Luna');
      expect(restored.reportKind, 'with_reporter');
      expect(restored.photos.single.bytes, [1, 2, 3]);
      expect(await local.read('owner', 'found:true:case'), isNull);
      expect(found.attempts, isEmpty);
    },
  );

  test(
    'Sighting frozen command survives full SQLite reopen and retries original timestamp and photo',
    () async {
      final directory = await Directory.systemTemp.createTemp('eh-sighting-');
      final file = File('${directory.path}/draft.sqlite');
      var db = LocalDraftDatabase(NativeDatabase(file));
      var local = LocalDraftRepositoryImpl(db);
      final repo = FakeSightings()..issue = SightingIssue.unavailable;
      var c = editors(local, sightings: repo);
      c.listen(sightingViewModelProvider, (_, _) {});
      await c.read(sightingViewModelProvider.future);
      var m = c.read(sightingViewModelProvider.notifier);
      m.date(DateTime(2026, 1, 1));
      m.time(10, 30);
      m.point(-12, -77);
      m.comment('Junto al puente');
      await m.submit();
      final original = repo.attempts.single;
      expect(c.read(sightingViewModelProvider).requireValue.frozen, isNotNull);
      c.dispose();
      await db.close();
      db = LocalDraftDatabase(NativeDatabase(file));
      local = LocalDraftRepositoryImpl(db);
      c = editors(local, sightings: repo);
      c.listen(sightingViewModelProvider, (_, _) {});
      final restored = await c.read(sightingViewModelProvider.future);
      expect(restored.id, original.id);
      expect(restored.frozen!.observedAt, original.observedAt);
      m = c.read(sightingViewModelProvider.notifier);
      m.comment('Esto no debe cambiar el comando');
      expect(
        c.read(sightingViewModelProvider).requireValue.comment,
        original.comment,
      );
      expect(await m.discardLocalDraft(original.id), isFalse);
      repo.issue = null;
      await m.submit();
      expect(repo.attempts.last.id, original.id);
      expect(repo.attempts.last.comment, original.comment);
      expect(repo.attempts.last.point.latitude, original.point.latitude);
      expect(await local.read('owner', 'sighting:false:${target.id}'), isNull);
      c.dispose();
      await db.close();
      await removeTemporaryDatabaseDirectory(directory);
    },
  );

  test(
    'Disk failure blocks publication, retains text, and explicit save recovers',
    () async {
      final local = FakeLocalDrafts();
      final repo = FakeSightings();
      final c = editors(local, sightings: repo);
      addTearDown(c.dispose);
      c.listen(sightingViewModelProvider, (_, _) {});
      await c.read(sightingViewModelProvider.future);
      final m = c.read(sightingViewModelProvider.notifier);
      m.date(DateTime(2026, 1, 1));
      m.time(10, 30);
      m.point(-12, -77);
      await m.saveForLater();
      local.fail = true;
      m.comment('Conservar aunque falle el disco');
      await m.submit();
      expect(repo.attempts, isEmpty);
      expect(
        c.read(sightingViewModelProvider).requireValue.issue,
        SightingIssue.localStorage,
      );
      expect(
        c.read(sightingViewModelProvider).requireValue.comment,
        'Conservar aunque falle el disco',
      );
      expect(c.read(sightingViewModelProvider).requireValue.busy, isFalse);
      local.fail = false;
      expect(await m.saveForLater(), isTrue);
      expect(c.read(sightingViewModelProvider).requireValue.issue, isNull);
      await m.submit();
      expect(repo.attempts, hasLength(1));
    },
  );

  test(
    'Changing account and signing out hides drafts; returning A restores only A',
    () async {
      final sessions = StreamController<AuthSession?>.broadcast();
      final local = FakeLocalDrafts();
      final c = editors(local, sessions: sessions.stream);
      addTearDown(c.dispose);
      addTearDown(sessions.close);
      c.listen(sightingViewModelProvider, (_, _) {});
      sessions.add(const AuthSession(userId: 'A'));
      await c.read(sightingViewModelProvider.future);
      c.read(sightingViewModelProvider.notifier).comment('Privado de A');
      await c.read(sightingViewModelProvider.notifier).saveForLater();
      sessions.add(const AuthSession(userId: 'B'));
      await Future<void>.delayed(Duration.zero);
      final b = await c.read(sightingViewModelProvider.future);
      expect(b.owner, 'B');
      expect(b.comment, isEmpty);
      sessions.add(null);
      await Future<void>.delayed(Duration.zero);
      await expectLater(
        c.read(sightingViewModelProvider.future),
        throwsA(isA<SightingFailure>()),
      );
      sessions.add(const AuthSession(userId: 'A'));
      await Future<void>.delayed(Duration.zero);
      expect(
        (await c.read(sightingViewModelProvider.future)).comment,
        'Privado de A',
      );
    },
  );

  test(
    'Onboarding fallback is per account, requires confirmed completion, and rejects server errors',
    () async {
      final remote = TestOnboardingSource();
      final cache = MemoryOnboardingCache();
      String? owner = 'A';
      final source = OfflineOnboardingDataSource(
        remote,
        cache,
        currentOwner: () => owner,
      );
      expect((await source.read('A')).completed, isTrue);
      remote.failure = ClientException('offline');
      expect((await source.read('A')).completed, isTrue);
      owner = 'B';
      await expectLater(source.read('B'), throwsA(isA<ClientException>()));
      await expectLater(source.read('A'), throwsA(isA<ClientException>()));
      owner = 'A';
      remote.failure = StateError('server denied');
      await expectLater(source.read('A'), throwsA(isA<StateError>()));
      remote.failure = null;
      remote.completed = false;
      expect((await source.read('A')).completed, isFalse);
      remote.failure = TimeoutException('offline');
      await expectLater(source.read('A'), throwsA(isA<TimeoutException>()));
    },
  );
}
