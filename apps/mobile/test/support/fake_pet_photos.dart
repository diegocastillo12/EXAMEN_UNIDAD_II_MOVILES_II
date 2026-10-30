import 'dart:typed_data';
import 'dart:async';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet_photo.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/repositories/pet_photo_repository.dart';

class FakePetPhotos implements PetPhotoRepository {
  Completer<void>? pendingList;
  int lists = 0;
  bool failList = false;
  Uint8List? selection;
  Uint8List? recovered;
  bool loseAcknowledgement = false;
  bool loseRemovalAcknowledgement = false;
  bool failRemoval = false;
  Completer<void>? pendingRemoval;
  final removals = <String>[];
  final operations = <String>[];
  final photos = <String, PetPhoto>{};
  final attempts = <String>[];
  PetPhotoOrigin? lastOrigin;
  bool failPrimary = false;
  int primaryWrites = 0;
  @override
  Future<Uint8List?> choose(
    String owner,
    String pet,
    bool existing, {
    PetPhotoOrigin origin = PetPhotoOrigin.gallery,
  }) async {
    lastOrigin = origin;
    return selection;
  }

  @override
  Future<Uint8List?> recover(String owner, String pet, bool existing) async {
    final bytes = recovered;
    recovered = null;
    return bytes;
  }

  @override
  Future<List<PetPhoto>> list(String owner, String pet) async {
    lists++;
    await pendingList?.future;
    if (failList) {
      throw const PetPhotoFailure(PetPhotoFailureKind.unavailable);
    }
    return photos.values
        .where((p) => p.ownerId == owner && p.petId == pet)
        .toList();
  }

  @override
  Future<PetPhoto> upload(String owner, String pet, PetPhotoDraft draft) async {
    attempts.add(draft.id);
    operations.add('upload:${draft.id}');
    if (!photos.containsKey(draft.id) &&
        photos.values
                .where((p) => p.ownerId == owner && p.petId == pet)
                .length >=
            3) {
      throw const PetPhotoFailure(PetPhotoFailureKind.limit);
    }
    final photo = photos.putIfAbsent(
      draft.id,
      () => PetPhoto(
        id: draft.id,
        petId: pet,
        ownerId: owner,
        ready: true,
        uri: Uri.parse('https://example.invalid/${draft.id}.jpg'),
      ),
    );
    if (loseAcknowledgement) {
      loseAcknowledgement = false;
      throw const PetPhotoFailure(PetPhotoFailureKind.unavailable);
    }
    return photo;
  }

  @override
  Future<void> remove(String owner, String pet, String id) async {
    removals.add(id);
    operations.add('remove:$id');
    await pendingRemoval?.future;
    if (failRemoval) {
      throw const PetPhotoFailure(PetPhotoFailureKind.unavailable);
    }
    photos.remove(id);
    if (loseRemovalAcknowledgement) {
      loseRemovalAcknowledgement = false;
      throw const PetPhotoFailure(PetPhotoFailureKind.unavailable);
    }
  }

  @override
  Future<List<PetPhoto>> setPrimary(
    String owner,
    String pet,
    String id,
    int expectedVersion,
  ) async {
    primaryWrites++;
    if (failPrimary) {
      throw const PetPhotoFailure(PetPhotoFailureKind.unavailable);
    }
    for (final p in List<PetPhoto>.of(photos.values)) {
      if (p.petId != pet || p.ownerId != owner) continue;
      photos[p.id] = PetPhoto(
        id: p.id,
        petId: pet,
        ownerId: owner,
        ready: p.ready,
        uri: p.uri,
        isPrimary: p.id == id,
        selectionVersion: expectedVersion + 1,
      );
    }
    return list(owner, pet);
  }
}
