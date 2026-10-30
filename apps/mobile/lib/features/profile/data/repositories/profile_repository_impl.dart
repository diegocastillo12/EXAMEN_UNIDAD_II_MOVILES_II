import '../../domain/entities/account_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/failures/profile_failure.dart';
import '../data_sources/profile_data_source.dart';
import '../models/profile_dto.dart';

final class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._source);
  final ProfileDataSource _source;
  Future<AccountProfile> _run(Future<ProfileDto> Function() action) async {
    try {
      return (await action()).toEntity();
    } on ProfileSourceFailure catch (failure) {
      throw ProfileFailure(switch (failure.kind) {
        ProfileSourceFailureKind.signedOut => ProfileFailureKind.signedOut,
        ProfileSourceFailureKind.missing => ProfileFailureKind.missing,
        ProfileSourceFailureKind.forbidden => ProfileFailureKind.forbidden,
        ProfileSourceFailureKind.unavailable => ProfileFailureKind.unavailable,
      });
    } catch (_) {
      throw const ProfileFailure(ProfileFailureKind.unavailable);
    }
  }

  @override
  Future<AccountProfile> read(String userId) =>
      _run(() => _source.read(userId));
  @override
  Future<AccountProfile> update(
    String userId, {
    required String? displayName,
    required String? city,
    required String? contactPhone,
  }) => _run(
    () => _source.update(
      userId,
      displayName: displayName,
      city: city,
      contactPhone: contactPhone,
    ),
  );
}
