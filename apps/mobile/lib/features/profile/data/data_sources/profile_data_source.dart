import '../models/profile_dto.dart';
import 'dart:typed_data';

enum ProfileSourceFailureKind { unavailable, signedOut, missing, forbidden }

final class ProfileSourceFailure implements Exception {
  const ProfileSourceFailure(this.kind);
  final ProfileSourceFailureKind kind;
}

abstract interface class ProfileDataSource {
  Future<ProfileDto> uploadAvatar(String userId, Uint8List jpeg);
  Future<ProfileDto> read(String userId);
  Future<ProfileDto> update(
    String userId, {
    required String? displayName,
    required String? city,
    required String? contactPhone,
  });
}
