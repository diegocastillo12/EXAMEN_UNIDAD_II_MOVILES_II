import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_entrehuellas/core/domain/entities/public_case_card.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/data/data_sources/saved_list_file_source.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/data/data_sources/saved_list_cipher.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/data/repositories/saved_list_file_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/domain/entities/saved_case_page.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/domain/failures/saved_case_failure.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/domain/repositories/saved_cases_repository.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/domain/use_cases/save_list_offline.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/providers/saved_cases_providers.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/presentation/view_models/saved_case_list_view_model.dart';

PublicCaseCard card(String name) => PublicCaseCard(
  id: name,
  fromPet: true,
  kind: PublicCaseKind.lost,
  status: PublicCaseStatus.active,
  species: 'dog',
  name: name,
  traits: 'Caso de prueba del examen',
  occurredAt: DateTime.utc(2026, 10, 30),
  latitude: -18,
  longitude: -70,
  coverUri: Uri.parse('https://example.test/photo?token=private'),
);

class RemoteCases implements SavedCasesRepository {
  bool offline = false;
  List<PublicCaseCard>? items;
  @override
  Future<SavedCasePage> list(String owner, {String? cursor}) async {
    if (offline) throw const SavedCaseFailure(SavedCaseFailureKind.unavailable);
    return SavedCasePage(
      items: items ?? [card('Luna Prueba'), card('Max Prueba')],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Transport simulation only. Real AES/Keystore is tested on Android separately.
class FakeSavedListCipher implements SavedListCipher {
  final Map<String, Uint8List> _plaintext = {};
  int sequence = 0;
  bool keysDeleted = false;
  bool failDelete = false;
  @override
  Future<void> deleteKeys() async {
    if (failDelete) throw StateError('Simulated key store failure');
    _plaintext.clear();
    keysDeleted = true;
  }

  @override
  Future<Uint8List> encrypt(String owner, Uint8List plaintext) async {
    final sealed = Uint8List.fromList([
      ++sequence,
      ...plaintext.reversed.map((v) => v ^ 255),
    ]);
    _plaintext['$owner:${base64Encode(sealed)}'] = plaintext;
    return sealed;
  }

  @override
  Future<Uint8List> decrypt(String owner, Uint8List sealed) async {
    final plaintext = _plaintext['$owner:${base64Encode(sealed)}'];
    if (plaintext == null) throw StateError('Simulated authentication failure');
    return plaintext;
  }
}

class PausedSavedListCipher extends FakeSavedListCipher {
  final entered = Completer<void>();
  final resume = Completer<void>();
  @override
  Future<Uint8List> encrypt(String owner, Uint8List plaintext) async {
    entered.complete();
    await resume.future;
    return super.encrypt(owner, plaintext);
  }
}

void main() {
  late Directory directory;
  late SavedListFileRepositoryImpl files;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('saved-list-test-');
    files = SavedListFileRepositoryImpl(
      SavedListFileSource(
        cipher: FakeSavedListCipher(),
        directory: () async => directory,
      ),
    );
  });
  tearDown(() async => directory.delete(recursive: true));

  test(
    'Encrypted envelope replaces data, isolates accounts and omits plaintext and signed URLs',
    () async {
      expect(await files.read('owner'), isNull);
      await SaveListOffline(files)('owner', [card('Luna Prueba')]);
      final file = File(
        '${directory.path}/offline_saved_cases/owner/cases.json',
      );
      final contents = await file.readAsString();
      expect(contents, isNot(contains('Luna Prueba')));
      expect(jsonDecode(contents)['algorithm'], 'AES-256-GCM');
      expect(contents, isNot(contains('token=private')));
      expect(await files.read('other'), isNull);
      await SaveListOffline(files)('owner', [card('Max Prueba')]);
      expect((await files.read('owner'))!.single.name, 'Max Prueba');
      expect(await File('${file.path}.tmp').exists(), isFalse);
    },
  );

  test(
    'Plaintext leftovers are rejected, never silently used as encrypted data',
    () async {
      final file = File(
        '${directory.path}/offline_saved_cases/owner/cases.json',
      );
      await file.parent.create(recursive: true);
      await file.writeAsString('{"schema":1,"owner":"owner","items":[]}');
      await expectLater(files.read('owner'), throwsA(isA<SavedCaseFailure>()));
    },
  );

  test(
    'Real view model saves visible list and falls back after network failure and recreation',
    () async {
      final remote = RemoteCases();
      final container = ProviderContainer(
        overrides: [
          savedCasesRepositoryProvider.overrideWithValue(remote),
          savedListFileRepositoryProvider.overrideWithValue(files),
          savedCasesSessionProvider.overrideWith(
            (ref) => Stream.value(const AuthSession(userId: 'owner')),
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        savedCaseListViewModelProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      final initial = await container.read(
        savedCaseListViewModelProvider.future,
      );
      expect(initial.items.length, 2);
      await container
          .read(savedCaseListViewModelProvider.notifier)
          .saveOffline();
      expect(
        container
            .read(savedCaseListViewModelProvider)
            .requireValue
            .noticeIsError,
        isFalse,
      );
      remote.offline = true;
      await container.read(savedCaseListViewModelProvider.notifier).refresh();
      final local = container.read(savedCaseListViewModelProvider).requireValue;
      expect(local.offline, isTrue);
      expect(local.items.map((v) => v.name), ['Luna Prueba', 'Max Prueba']);
      container.invalidate(savedCaseListViewModelProvider);
      expect(
        (await container.read(
          savedCaseListViewModelProvider.future,
        )).items.length,
        2,
      );
      remote.offline = false;
      await container.read(savedCaseListViewModelProvider.notifier).refresh();
      expect(
        container.read(savedCaseListViewModelProvider).requireValue.offline,
        isFalse,
      );
    },
  );

  test(
    'Device clear removes every list file and simulated key, and can be repeated',
    () async {
      await files.save('owner', [card('Cliente Prueba')]);
      await files.save('other', [card('Otro Caso')]);
      final cipher = files.source.cipher as FakeSavedListCipher;
      await ClearOfflineLists(files)('owner');
      expect(cipher.keysDeleted, isTrue);
      expect(
        await Directory('${directory.path}/offline_saved_cases').exists(),
        isFalse,
      );
      expect(await files.read('owner'), isNull);
      expect(await files.read('other'), isNull);
      await ClearOfflineLists(files)('owner');
    },
  );

  test(
    'No snapshot does not turn backend failure into confirmed empty data',
    () async {
      final remote = RemoteCases()..offline = true;
      final container = ProviderContainer(
        overrides: [
          savedCasesRepositoryProvider.overrideWithValue(remote),
          savedListFileRepositoryProvider.overrideWithValue(files),
          savedCasesSessionProvider.overrideWith(
            (ref) => Stream.value(const AuthSession(userId: 'owner')),
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        savedCaseListViewModelProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      await expectLater(
        container.read(savedCaseListViewModelProvider.future),
        throwsA(isA<SavedCaseFailure>()),
      );
    },
  );

  test(
    'Clear waits for an in-flight save and cannot leave a resurrected file',
    () async {
      final cipher = PausedSavedListCipher();
      final repository = SavedListFileRepositoryImpl(
        SavedListFileSource(cipher: cipher, directory: () async => directory),
      );
      final save = repository.save('owner', [card('Cliente Prueba')]);
      await cipher.entered.future;
      final clear = repository.clearAll();
      cipher.resume.complete();
      await save;
      await clear;
      expect(await repository.read('owner'), isNull);
      expect(cipher.keysDeleted, isTrue);
      expect(
        await Directory('${directory.path}/offline_saved_cases').exists(),
        isFalse,
      );
    },
  );

  test('Key deletion failure is reported and can be retried', () async {
    await files.save('owner', [card('Cliente Prueba')]);
    final cipher = files.source.cipher as FakeSavedListCipher;
    cipher.failDelete = true;
    await expectLater(files.clearAll(), throwsA(isA<SavedCaseFailure>()));
    expect(await files.read('owner'), isNotNull);
    cipher.failDelete = false;
    await files.clearAll();
    expect(await files.read('owner'), isNull);
  });
}
