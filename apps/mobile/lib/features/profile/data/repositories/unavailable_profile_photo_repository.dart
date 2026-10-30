import 'dart:typed_data';
import '../../domain/entities/account_profile.dart';
import '../../domain/failures/profile_failure.dart';
import '../../domain/repositories/profile_photo_repository.dart';

final class UnavailableProfilePhotoRepository
    implements ProfilePhotoRepository {
  const UnavailableProfilePhotoRepository();
  @override
  Future<Uint8List?> choose(String userId) async =>
      throw const ProfileFailure(ProfileFailureKind.unavailable);
  @override
  Future<Uint8List?> recover(String userId) async => null;
  @override
  Future<AccountProfile> upload(String userId, Uint8List jpeg) async =>
      throw const ProfileFailure(ProfileFailureKind.unavailable);
}
