import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_application_entrehuellas/features/profile/domain/entities/account_profile.dart';
import 'package:flutter_application_entrehuellas/features/profile/domain/repositories/profile_photo_repository.dart';
import 'package:flutter_application_entrehuellas/features/profile/domain/failures/profile_failure.dart';
import 'fake_profile.dart';

class FakeProfilePhoto implements ProfilePhotoRepository {
  FakeProfilePhoto(this.profiles);
  final FakeProfile profiles;
  Uint8List? selection;
  Uint8List? recovered;
  Completer<void>? pending;
  bool fail = false;
  int uploads = 0;
  int choices = 0;
  @override
  Future<Uint8List?> choose(String userId) async {
    choices++;
    return selection;
  }

  @override
  Future<Uint8List?> recover(String userId) async => recovered;
  @override
  Future<AccountProfile> upload(String userId, Uint8List jpeg) async {
    uploads++;
    await pending?.future;
    if (fail) throw const ProfileFailure(ProfileFailureKind.unavailable);
    final old = await profiles.read(userId);
    return profiles.profiles[userId] = AccountProfile(
      userId: userId,
      displayName: old.displayName,
      city: old.city,
      email: old.email,
      avatarUri: Uri.parse('https://photos.example.invalid/$userId/avatar.jpg'),
    );
  }
}
