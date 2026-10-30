import '../../domain/entities/account_profile.dart';
import '../../domain/failures/profile_failure.dart';
import '../../domain/repositories/profile_repository.dart';

final class UnavailableProfileRepository implements ProfileRepository {
  const UnavailableProfileRepository();
  @override
  Future<AccountProfile> read(String userId) async =>
      throw const ProfileFailure(ProfileFailureKind.unavailable);
  @override
  Future<AccountProfile> update(
    String userId, {
    required String? displayName,
    required String? city,
    required String? contactPhone,
  }) async => throw const ProfileFailure(ProfileFailureKind.unavailable);
}
