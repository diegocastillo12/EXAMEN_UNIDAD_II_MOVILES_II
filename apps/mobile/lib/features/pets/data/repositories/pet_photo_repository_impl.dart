import 'dart:typed_data';
import '../../domain/entities/pet_photo.dart';
import '../../domain/repositories/pet_photo_repository.dart';
import '../data_sources/pet_gallery_source.dart';
import '../data_sources/pet_photo_data_source.dart';

class PetPhotoRepositoryImpl implements PetPhotoRepository {
  const PetPhotoRepositoryImpl(this._gallery, this._remote);
  final PetGallerySource _gallery;
  final PetPhotoDataSource _remote;
  Future<T> _run<T>(Future<T> Function() action, {bool gallery = false}) async {
    try {
      return await action();
    } on PetGalleryFailure catch (e) {
      throw PetPhotoFailure(switch (e.kind) {
        PetGalleryFailureKind.invalidPhoto => PetPhotoFailureKind.invalidPhoto,
        PetGalleryFailureKind.cameraUnavailable =>
          PetPhotoFailureKind.cameraUnavailable,
        _ => PetPhotoFailureKind.galleryUnavailable,
      });
    } on PetPhotoSourceFailure catch (e) {
      throw PetPhotoFailure(switch (e.kind) {
        PetPhotoSourceFailureKind.forbidden => PetPhotoFailureKind.forbidden,
        PetPhotoSourceFailureKind.limit => PetPhotoFailureKind.limit,
        PetPhotoSourceFailureKind.invalidPhoto =>
          PetPhotoFailureKind.invalidPhoto,
        PetPhotoSourceFailureKind.conflict => PetPhotoFailureKind.conflict,
        _ => PetPhotoFailureKind.unavailable,
      });
    } catch (_) {
      throw PetPhotoFailure(
        gallery
            ? PetPhotoFailureKind.galleryUnavailable
            : PetPhotoFailureKind.unavailable,
      );
    }
  }

  @override
  Future<Uint8List?> choose(
    String ownerId,
    String petId,
    bool existing, {
    PetPhotoOrigin origin = PetPhotoOrigin.gallery,
  }) => _run(
    () => _gallery.choose(
      ownerId,
      petId,
      existing,
      camera: origin == PetPhotoOrigin.camera,
    ),
    gallery: true,
  );
  @override
  Future<Uint8List?> recover(String ownerId, String petId, bool existing) =>
      _run(() => _gallery.recover(ownerId, petId, existing), gallery: true);
  @override
  Future<List<PetPhoto>> list(String ownerId, String petId) => _run(
    () async =>
        (await _remote.list(ownerId, petId)).map((d) => d.toEntity()).toList(),
  );
  @override
  Future<PetPhoto> upload(String ownerId, String petId, PetPhotoDraft draft) =>
      _run(
        () async => (await _remote.upload(
          ownerId,
          petId,
          draft.id,
          draft.bytes,
        )).toEntity(),
      );
  @override
  Future<void> remove(String ownerId, String petId, String photoId) =>
      _run(() => _remote.remove(ownerId, petId, photoId));
  @override
  Future<List<PetPhoto>> setPrimary(
    String owner,
    String pet,
    String id,
    int expectedVersion,
  ) => _run(
    () async => (await _remote.setPrimary(
      owner,
      pet,
      id,
      expectedVersion,
    )).map((dto) => dto.toEntity()).toList(),
  );
}
