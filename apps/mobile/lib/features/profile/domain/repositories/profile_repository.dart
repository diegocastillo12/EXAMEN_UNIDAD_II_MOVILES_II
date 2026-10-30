import '../entities/account_profile.dart';

abstract interface class ProfileRepository {
  Future<AccountProfile> read(String userId);

  /// Replaces only editable values; returning means the server acknowledged it.
  /// A retry of the same values is safe. No identity or server fields are writable.
  Future<AccountProfile> update(
    String userId, {
    required String? displayName,
    required String? city,
    required String? contactPhone,
  });
}
