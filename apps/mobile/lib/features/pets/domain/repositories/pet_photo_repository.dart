import 'dart:typed_data';
import '../entities/pet_photo.dart';

abstract interface class PetPhotoRepository {
  Future<Uint8List?> choose(
    String ownerId,
    String petId,
    bool existing, {
    PetPhotoOrigin origin = PetPhotoOrigin.gallery,
  });
  Future<Uint8List?> recover(String ownerId, String petId, bool existing);
  Future<List<PetPhoto>> list(String ownerId, String petId);
  Future<PetPhoto> upload(String ownerId, String petId, PetPhotoDraft draft);
  Future<void> remove(String ownerId, String petId, String photoId);
  Future<List<PetPhoto>> setPrimary(
    String ownerId,
    String petId,
    String photoId,
    int expectedVersion,
  );
}
