import 'dart:typed_data';

enum ProfilePhotoSourceFailureKind { invalidPhoto, unavailable }

final class ProfilePhotoSourceFailure implements Exception {
  const ProfilePhotoSourceFailure(this.kind);
  final ProfilePhotoSourceFailureKind kind;
}

abstract interface class ProfilePhotoSource {
  Future<Uint8List?> choose(String userId);
  Future<Uint8List?> recover(String userId);
}
