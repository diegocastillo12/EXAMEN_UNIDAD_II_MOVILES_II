import '../entities/account_profile.dart';
import '../failures/profile_failure.dart';
import '../repositories/profile_repository.dart';

final class ReadProfile {
  const ReadProfile(this._repository);
  final ProfileRepository _repository;
  Future<AccountProfile> call(String userId) async {
    if (userId.isEmpty) {
      throw const ProfileFailure(ProfileFailureKind.signedOut);
    }
    final profile = await _repository.read(userId);
    if (profile.userId != userId) {
      throw const ProfileFailure(ProfileFailureKind.forbidden);
    }
    return profile;
  }
}
