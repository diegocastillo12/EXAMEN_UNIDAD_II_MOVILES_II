import '../entities/account_profile.dart';
import '../failures/profile_failure.dart';
import '../repositories/profile_repository.dart';

final class UpdateProfile {
  const UpdateProfile(this._repository);
  final ProfileRepository _repository;
  Future<AccountProfile> call(
    String userId, {
    required String displayName,
    required String city,
    required bool citySelected,
    String contactPhone = '',
  }) async {
    if (userId.isEmpty) {
      throw const ProfileFailure(ProfileFailureKind.signedOut);
    }
    final name = displayName.trim();
    final place = city.trim();
    final phone = contactPhone.trim().replaceAll(RegExp(r'[ ()-]'), '');
    if (phone.isNotEmpty && !RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(phone)) {
      throw const ProfileFailure(ProfileFailureKind.invalidPhone);
    }
    if (name.runes.length > 120) {
      throw const ProfileFailure(ProfileFailureKind.invalidName);
    }
    if (place.runes.length > 120 || (place.isNotEmpty && !citySelected)) {
      throw const ProfileFailure(ProfileFailureKind.invalidCity);
    }
    final saved = await _repository.update(
      userId,
      displayName: name.isEmpty ? null : name,
      city: place.isEmpty ? null : place,
      contactPhone: phone.isEmpty ? null : phone,
    );
    if (saved.userId != userId) {
      throw const ProfileFailure(ProfileFailureKind.forbidden);
    }
    return saved;
  }
}
