export '../../../../core/data_sources/photo_gallery_source.dart'
    show
        PhotoGallerySource,
        NativePhotoGallerySource,
        PhotoGalleryFailure,
        PhotoGalleryFailureKind,
        preparePhoto;
import '../../../../core/data_sources/photo_gallery_source.dart';
import 'dart:typed_data';

typedef PetGallerySource = PhotoGallerySource;

class NativePetGallerySource extends NativePhotoGallerySource {
  const NativePetGallerySource(super.picker);
  static const marker = 'pet_photo_pending';
}

typedef PetGalleryFailure = PhotoGalleryFailure;
typedef PetGalleryFailureKind = PhotoGalleryFailureKind;
Uint8List preparePetPhoto(Uint8List bytes) => preparePhoto(bytes);
