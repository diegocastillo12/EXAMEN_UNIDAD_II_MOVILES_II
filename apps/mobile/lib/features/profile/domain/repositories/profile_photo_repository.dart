import 'dart:typed_data';
import '../entities/account_profile.dart';

abstract interface class ProfilePhotoRepository {
  /// Null is cancellation. Returns a re-encoded JPEG without source metadata.
  Future<Uint8List?> choose(String userId);
  Future<Uint8List?> recover(String userId);

  /// Uses one stable private object per account; same payload can be retried.
  Future<AccountProfile> upload(String userId, Uint8List jpeg);
}
