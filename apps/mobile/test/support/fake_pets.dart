import 'dart:async';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/failures/pet_failure.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/repositories/pet_repository.dart';

class FakePets implements PetRepository {
  final pets = <String, Pet>{};
  Completer<void>? pending;
  Completer<void>? pendingList;
  Completer<void>? pendingRead;
  bool fail = false;
  bool ambiguousCreate = false;
  int creates = 0;
  int updates = 0;
  int reads = 0;
  int deletes = 0;
  bool ambiguousDelete = false;
  @override
  Future<void> delete(String ownerId, String petId, int expectedVersion) async {
    deletes++;
    await pending?.future;
    if (fail) throw const PetFailure(PetFailureKind.unavailable);
    final pet = pets[petId];
    if (pet != null && pet.ownerId != ownerId) {
      throw const PetFailure(PetFailureKind.forbidden);
    }
    if (pet != null && pet.version != expectedVersion) {
      throw const PetFailure(PetFailureKind.conflict);
    }
    pets.remove(petId);
    if (ambiguousDelete) {
      ambiguousDelete = false;
      throw const PetFailure(PetFailureKind.unavailable);
    }
  }

  @override
  Future<List<Pet>> list(String ownerId, {bool archived = false}) async {
    await pendingList?.future;
    if (fail) {
      throw const PetFailure(PetFailureKind.unavailable);
    }
    return pets.values
        .where((p) => p.ownerId == ownerId && p.isArchived == archived)
        .toList();
  }

  @override
  Future<Pet> read(String ownerId, String petId) async {
    reads++;
    await pendingRead?.future;
    if (fail) {
      throw const PetFailure(PetFailureKind.unavailable);
    }
    final p = pets[petId];
    if (p == null || p.ownerId != ownerId) {
      throw const PetFailure(PetFailureKind.missing);
    }
    return p;
  }

  @override
  Future<Pet> create(String ownerId, String petId, PetFields fields) async {
    creates++;
    await pending?.future;
    if (fail) {
      throw const PetFailure(PetFailureKind.unavailable);
    }
    final pet =
        pets[petId] ??
        Pet(id: petId, ownerId: ownerId, fields: fields, version: 1);
    pets[petId] = pet;
    if (ambiguousCreate) {
      ambiguousCreate = false;
      throw const PetFailure(PetFailureKind.unavailable);
    }
    return pet;
  }

  @override
  Future<Pet> update(
    String ownerId,
    String petId,
    int expectedVersion,
    PetFields fields,
  ) async {
    updates++;
    await pending?.future;
    if (fail) {
      throw const PetFailure(PetFailureKind.unavailable);
    }
    final old = await read(ownerId, petId);
    if (old.version != expectedVersion) {
      throw const PetFailure(PetFailureKind.conflict);
    }
    return pets[petId] = Pet(
      id: petId,
      ownerId: ownerId,
      fields: fields,
      version: old.version + 1,
      coverUri: old.coverUri,
      archivedAt: old.archivedAt,
      caseHistoryAt: old.caseHistoryAt,
      activeCaseCount: old.activeCaseCount,
    );
  }

  int archives = 0;
  int restores = 0;
  bool ambiguousLifecycle = false;
  @override
  Future<Pet> archive(String ownerId, String petId, int expectedVersion) async {
    archives++;
    return _lifecycle(ownerId, petId, expectedVersion, true);
  }

  @override
  Future<Pet> restore(String ownerId, String petId, int expectedVersion) async {
    restores++;
    return _lifecycle(ownerId, petId, expectedVersion, false);
  }

  Future<Pet> _lifecycle(
    String ownerId,
    String id,
    int version,
    bool archived,
  ) async {
    await pending?.future;
    if (fail) throw const PetFailure(PetFailureKind.unavailable);
    final old = pets[id];
    if (old == null) throw const PetFailure(PetFailureKind.missing);
    if (old.ownerId != ownerId) {
      throw const PetFailure(PetFailureKind.forbidden);
    }
    if (archived && old.activeCaseCount > 0) {
      throw const PetFailure(PetFailureKind.activeCase);
    }
    if (old.isArchived == archived &&
        (version == old.version || version + 1 == old.version)) {
      return old;
    }
    if (version != old.version) throw const PetFailure(PetFailureKind.conflict);
    final saved = pets[id] = Pet(
      id: id,
      ownerId: ownerId,
      fields: old.fields,
      version: old.version + 1,
      coverUri: old.coverUri,
      archivedAt: archived ? DateTime.utc(2026, 10, 9) : null,
      caseHistoryAt: old.caseHistoryAt,
      activeCaseCount: old.activeCaseCount,
    );
    if (ambiguousLifecycle) {
      ambiguousLifecycle = false;
      throw const PetFailure(PetFailureKind.unavailable);
    }
    return saved;
  }
}
