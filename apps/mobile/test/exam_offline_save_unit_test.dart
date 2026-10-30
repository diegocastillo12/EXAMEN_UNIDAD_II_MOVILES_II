import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/domain/entities/public_case_card.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/data/data_sources/saved_list_cipher.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/data/data_sources/saved_list_file_source.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/data/repositories/saved_list_file_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/domain/use_cases/save_list_offline.dart';

/// Sustituye Android Keystore durante la prueba: no necesita emulador.
/// No es criptografia real; solo permite verificar guardar y leer aislados.
class FakeCipher implements SavedListCipher {
  @override
  Future<void> deleteKeys() async {}

  @override
  Future<Uint8List> encrypt(String owner, Uint8List plaintext) async =>
      Uint8List.fromList(plaintext.reversed.toList());

  @override
  Future<Uint8List> decrypt(String owner, Uint8List sealed) async =>
      Uint8List.fromList(sealed.reversed.toList());
}

PublicCaseCard examCard(String name) => PublicCaseCard(
  id: name.toLowerCase().replaceAll(' ', '-'),
  fromPet: true,
  kind: PublicCaseKind.lost,
  status: PublicCaseStatus.active,
  species: 'dog',
  name: name,
  traits: 'Registro del examen',
  occurredAt: DateTime.utc(2026, 10, 30),
  latitude: -18.015,
  longitude: -70.255,
);

void main() {
  late Directory tempDirectory;
  late SavedListFileRepositoryImpl repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('exam-offline-');
    repository = SavedListFileRepositoryImpl(
      SavedListFileSource(
        cipher: FakeCipher(),
        directory: () async => tempDirectory,
      ),
    );
  });

  tearDown(() => tempDirectory.delete(recursive: true));

  test('(a) guardar Cliente Prueba no deja su texto en el archivo', () async {
    await SaveListOffline(repository)('cuenta-examen', [examCard('Cliente Prueba')]);

    final encryptedFile = File(
      '${tempDirectory.path}/offline_saved_cases/cuenta-examen/cases.json',
    );
    final contents = await encryptedFile.readAsString();

    expect(contents, isNot(contains('Cliente Prueba')));
    expect(jsonDecode(contents)['algorithm'], 'AES-256-GCM');
  });

  test('(b) guardar y leer tres registros devuelve la misma lista', () async {
    final original = [
      examCard('Cliente Uno'),
      examCard('Cliente Dos'),
      examCard('Cliente Tres'),
    ];

    await SaveListOffline(repository)('cuenta-examen', original);
    final restored = await repository.read('cuenta-examen');

    expect(restored!.map((item) => item.id), original.map((item) => item.id));
    expect(restored.map((item) => item.name), original.map((item) => item.name));
  });

  test('(c) sin archivo, leer devuelve una lista vacia sin error', () async {
    final restored = await repository.read('cuenta-sin-archivo') ?? const [];

    expect(restored, isEmpty);
  });
}
