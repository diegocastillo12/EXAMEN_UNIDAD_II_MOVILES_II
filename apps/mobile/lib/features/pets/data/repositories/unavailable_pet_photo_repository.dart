import 'dart:typed_data';
import '../../domain/entities/pet_photo.dart';
import '../../domain/repositories/pet_photo_repository.dart';

class UnavailablePetPhotoRepository implements PetPhotoRepository {
  const UnavailablePetPhotoRepository();
  Never _fail() => throw const PetPhotoFailure(PetPhotoFailureKind.unavailable);
  @override
  Future<Uint8List?> choose(
    String a,
    String b,
    bool c, {
    PetPhotoOrigin origin = PetPhotoOrigin.gallery,
  }) async => _fail();
  @override
  Future<Uint8List?> recover(String a, String b, bool c) async => null;
  @override
  Future<List<PetPhoto>> list(String a, String b) async => _fail();
  @override
  Future<PetPhoto> upload(String a, String b, PetPhotoDraft c) async => _fail();
  @override
  Future<void> remove(String a, String b, String c) async => _fail();
  @override
  Future<List<PetPhoto>> setPrimary(
    String a,
    String b,
    String c,
    int d,
  ) async => _fail();
}
