import 'dart:typed_data';

class PetPhoto {
  const PetPhoto({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.ready,
    this.uri,
    this.thumbnailUri,
    this.isPrimary = false,
    this.selectionVersion = 0,
  });
  final String id;
  final String petId;
  final String ownerId;
  final bool ready;
  final Uri? uri;
  final Uri? thumbnailUri;
  final bool isPrimary;
  final int selectionVersion;
}

class PetPhotoDraft {
  PetPhotoDraft({required this.id, required Uint8List bytes})
    : bytes = Uint8List.fromList(bytes).asUnmodifiableView();
  final String id;
  final Uint8List bytes;
}

enum PetPhotoFailureKind {
  unavailable,
  galleryUnavailable,
  invalidPhoto,
  limit,
  forbidden,
  cameraUnavailable,
  conflict,
}

enum PetPhotoOrigin { gallery, camera }

class PetPhotoFailure implements Exception {
  const PetPhotoFailure(this.kind);
  final PetPhotoFailureKind kind;
}
