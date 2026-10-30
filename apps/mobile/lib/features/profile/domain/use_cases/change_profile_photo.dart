import 'dart:typed_data';
import '../entities/account_profile.dart';
import '../repositories/profile_photo_repository.dart';
import '../failures/profile_failure.dart';

final class ChangeProfilePhoto {
  const ChangeProfilePhoto(this._repository);
  final ProfilePhotoRepository _repository;
  Future<Uint8List?> choose(String userId) {
    if (userId.isEmpty) {
      throw const ProfileFailure(ProfileFailureKind.signedOut);
    }
    return _repository.choose(userId);
  }

  Future<Uint8List?> recover(String userId) {
    if (userId.isEmpty) {
      throw const ProfileFailure(ProfileFailureKind.signedOut);
    }
    return _repository.recover(userId);
  }

  Future<AccountProfile> upload(String userId, Uint8List jpeg) {
    if (userId.isEmpty) {
      throw const ProfileFailure(ProfileFailureKind.signedOut);
    }
    if (jpeg.length < 3 ||
        jpeg.length > 2097152 ||
        jpeg[0] != 255 ||
        jpeg[1] != 216 ||
        jpeg[2] != 255) {
      throw const ProfileFailure(ProfileFailureKind.invalidPhoto);
    }
    return _repository.upload(userId, jpeg).then((saved) {
      if (saved.userId != userId) {
        throw const ProfileFailure(ProfileFailureKind.forbidden);
      }
      return saved;
    });
  }
}
