import 'dart:typed_data';
import '../../domain/entities/account_profile.dart';
import '../../domain/failures/profile_failure.dart';
import '../../domain/repositories/profile_photo_repository.dart';
import '../data_sources/profile_photo_source.dart';
import '../data_sources/profile_data_source.dart';

final class ProfilePhotoRepositoryImpl implements ProfilePhotoRepository {
  const ProfilePhotoRepositoryImpl(this._gallery, this._remote);
  final ProfilePhotoSource _gallery;
  final ProfileDataSource _remote;
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ProfileFailure {
      rethrow;
    } on ProfilePhotoSourceFailure catch (failure) {
      throw ProfileFailure(
        failure.kind == ProfilePhotoSourceFailureKind.invalidPhoto
            ? ProfileFailureKind.invalidPhoto
            : ProfileFailureKind.unavailable,
      );
    } catch (_) {
      throw const ProfileFailure(ProfileFailureKind.unavailable);
    }
  }

  @override
  Future<Uint8List?> choose(String userId) =>
      _run(() => _gallery.choose(userId));
  @override
  Future<Uint8List?> recover(String userId) =>
      _run(() => _gallery.recover(userId));
  @override
  Future<AccountProfile> upload(String userId, Uint8List jpeg) =>
      _run(() async => (await _remote.uploadAvatar(userId, jpeg)).toEntity());
}
