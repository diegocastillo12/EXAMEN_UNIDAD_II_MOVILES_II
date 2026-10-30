import 'dart:typed_data';
import '../entities/pet_photo.dart';
import '../repositories/pet_photo_repository.dart';

class ManagePetPhotos {
  const ManagePetPhotos(this._repository);
  final PetPhotoRepository _repository;
  void _owner(String owner) {
    if (owner.isEmpty) {
      throw const PetPhotoFailure(PetPhotoFailureKind.forbidden);
    }
  }

  Future<Uint8List?> choose(
    String owner,
    String pet,
    bool existing, {
    PetPhotoOrigin origin = PetPhotoOrigin.gallery,
  }) {
    _owner(owner);
    return _repository.choose(owner, pet, existing, origin: origin);
  }

  Future<Uint8List?> recover(String owner, String pet, bool existing) {
    _owner(owner);
    return _repository.recover(owner, pet, existing);
  }

  Future<List<PetPhoto>> list(String owner, String pet) async {
    _owner(owner);
    final photos = await _repository.list(owner, pet);
    if (photos.any((p) => p.ownerId != owner || p.petId != pet)) {
      throw const PetPhotoFailure(PetPhotoFailureKind.forbidden);
    }
    return photos;
  }

  Future<PetPhoto> upload(String owner, String pet, PetPhotoDraft draft) async {
    _owner(owner);
    final b = draft.bytes;
    if (b.length < 4 ||
        b.length > 2097152 ||
        b[0] != 255 ||
        b[1] != 216 ||
        b[2] != 255) {
      throw const PetPhotoFailure(PetPhotoFailureKind.invalidPhoto);
    }
    final photo = await _repository.upload(owner, pet, draft);
    if (photo.ownerId != owner ||
        photo.petId != pet ||
        photo.id != draft.id ||
        !photo.ready ||
        photo.uri == null) {
      throw const PetPhotoFailure(PetPhotoFailureKind.unavailable);
    }
    return photo;
  }

  Future<void> remove(String owner, String pet, String id) {
    _owner(owner);
    return _repository.remove(owner, pet, id);
  }

  Future<List<PetPhoto>> setPrimary(
    String owner,
    String pet,
    String id,
    int version,
  ) async {
    _owner(owner);
    if (id.isEmpty || version < 0) {
      throw const PetPhotoFailure(PetPhotoFailureKind.invalidPhoto);
    }
    final photos = await _repository.setPrimary(owner, pet, id, version);
    if (photos.any((p) => p.ownerId != owner || p.petId != pet) ||
        photos.where((p) => p.isPrimary).length != 1 ||
        !photos.any((p) => p.id == id && p.ready && p.isPrimary)) {
      throw const PetPhotoFailure(PetPhotoFailureKind.unavailable);
    }
    return photos;
  }
}
