import 'dart:typed_data';
import '../models/pet_photo_dto.dart';

enum PetPhotoSourceFailureKind {
  unavailable,
  forbidden,
  limit,
  invalidPhoto,
  conflict,
}

class PetPhotoSourceFailure implements Exception {
  const PetPhotoSourceFailure(this.kind);
  final PetPhotoSourceFailureKind kind;
}

abstract interface class PetPhotoDataSource {
  Future<List<PetPhotoDto>> list(String owner, String pet);
  Future<PetPhotoDto> upload(
    String owner,
    String pet,
    String id,
    Uint8List bytes,
  );
  Future<void> remove(String owner, String pet, String id);
  Future<List<PetPhotoDto>> setPrimary(
    String owner,
    String pet,
    String id,
    int expectedVersion,
  );
}
