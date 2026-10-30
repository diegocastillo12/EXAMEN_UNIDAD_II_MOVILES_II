import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/data/data_sources/saved_list_cipher.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/data/data_sources/saved_list_file_source.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/data/repositories/saved_list_file_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/domain/entities/saved_case_page.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/domain/failures/saved_case_failure.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/domain/repositories/saved_cases_repository.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/providers/saved_cases_providers.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/presentation/view_models/saved_case_list_view_model.dart';

/// Reemplazo simulado: permite controlar cifrado, fallo y borrado sin Android.
class FakeDamagedCipher implements SavedListCipher {
  FakeDamagedCipher({this.failDecrypt = false});
  bool failDecrypt;
  bool keyDeleted = false;

  @override
  Future<void> deleteKeys() async => keyDeleted = true;

  @override
  Future<Uint8List> encrypt(String owner, Uint8List plaintext) async => plaintext;

  @override
  Future<Uint8List> decrypt(String owner, Uint8List sealed) async {
    if (failDecrypt) throw StateError('Archivo alterado: autenticación inválida');
    return sealed;
  }
}

class OfflineRepository implements SavedCasesRepository {
  @override
  Future<SavedCasePage> list(String owner, {String? cursor}) =>
      throw const SavedCaseFailure(SavedCaseFailureKind.unavailable);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory directory;

  setUp(() async => directory = await Directory.systemTemp.createTemp('exam-damage-'));
  tearDown(() => directory.delete(recursive: true));

  test('(a) archivo alterado devuelve lista vacia y aviso, sin error', () async {
    final cipher = FakeDamagedCipher(failDecrypt: true);
    final local = SavedListFileRepositoryImpl(
      SavedListFileSource(cipher: cipher, directory: () async => directory),
    );
    await local.source.write('cuenta-examen', '{"schema":1,"items":[]}');
    final container = ProviderContainer(
      overrides: [
        savedCasesRepositoryProvider.overrideWithValue(OfflineRepository()),
        savedListFileRepositoryProvider.overrideWithValue(local),
        savedCasesSessionProvider.overrideWith(
          (ref) => Stream.value(const AuthSession(userId: 'cuenta-examen')),
        ),
      ],
    );
    addTearDown(container.dispose);
    final listener = container.listen(savedCaseListViewModelProvider, (_, _) {});
    addTearDown(listener.close);

    final result = await container.read(savedCaseListViewModelProvider.future);

    expect(result.items, isEmpty);
    expect(result.localUnavailable, isTrue);
    expect(result.notice, 'Datos locales no disponibles, conéctese para actualizar');
  });

  test('(b) borrar datos elimina archivo y clave simulada', () async {
    final cipher = FakeDamagedCipher();
    final source = SavedListFileSource(
      cipher: cipher,
      directory: () async => directory,
    );
    await source.write('cuenta-examen', '{"schema":1,"items":[]}');
    final file = File(
      '${directory.path}/offline_saved_cases/cuenta-examen/cases.json',
    );
    expect(await file.exists(), isTrue);

    await source.clearAll();

    expect(await file.exists(), isFalse);
    expect(cipher.keyDeleted, isTrue);
  });
}
