import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../models/profile_dto.dart';
import 'profile_data_source.dart';

final class SupabaseProfileDataSource implements ProfileDataSource {
  const SupabaseProfileDataSource(this._client);
  final SupabaseClient _client;
  void _checkIdentity(String userId) {
    if (_client.auth.currentUser?.id != userId) {
      throw const ProfileSourceFailure(ProfileSourceFailureKind.signedOut);
    }
  }

  Future<ProfileDto> _run(
    String userId,
    Future<Map<String, dynamic>> Function() action, {
    bool requireStoredPhoto = false,
  }) async {
    _checkIdentity(userId);
    try {
      final row = await action();
      _checkIdentity(userId);
      final metadata = _client.auth.currentUser?.userMetadata;
      final photo = metadata?['avatar_url'] ?? metadata?['picture'];
      final uri = photo is String ? Uri.tryParse(photo) : null;
      var avatar =
          uri != null &&
              uri.scheme == 'https' &&
              uri.host.isNotEmpty &&
              uri.userInfo.isEmpty
          ? uri
          : null;
      try {
        final signed = await _client.storage
            .from('profile-avatars')
            .createSignedUrl('$userId/avatar.jpg', 3600);
        final stored = Uri.parse(signed);
        avatar = stored.replace(
          queryParameters: {
            ...stored.queryParameters,
            'v': DateTime.now().millisecondsSinceEpoch.toString(),
          },
        );
      } on StorageException {
        if (requireStoredPhoto) rethrow;
        // Missing optional photo or storage configuration does not hide the profile.
      }
      _checkIdentity(userId);
      final dto = ProfileDto.fromMap(
        row,
        avatarUri: avatar,
        email: _client.auth.currentUser?.email,
      );
      if (dto.id != userId) {
        throw const ProfileSourceFailure(ProfileSourceFailureKind.forbidden);
      }
      return dto;
    } on ProfileSourceFailure {
      rethrow;
    } on PostgrestException catch (error) {
      throw ProfileSourceFailure(switch (error.code) {
        '42501' => ProfileSourceFailureKind.forbidden,
        'PGRST116' => ProfileSourceFailureKind.missing,
        'PGRST301' || 'PGRST303' => ProfileSourceFailureKind.signedOut,
        _ => ProfileSourceFailureKind.unavailable,
      });
    } catch (_) {
      throw const ProfileSourceFailure(ProfileSourceFailureKind.unavailable);
    }
  }

  @override
  Future<ProfileDto> uploadAvatar(String userId, Uint8List jpeg) async {
    _checkIdentity(userId);
    try {
      await _client.storage
          .from('profile-avatars')
          .uploadBinary(
            '$userId/avatar.jpg',
            jpeg,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
              cacheControl: '0',
            ),
          );
      _checkIdentity(userId);
      return await read(userId, requireStoredPhoto: true);
    } on ProfileSourceFailure {
      rethrow;
    } catch (_) {
      throw const ProfileSourceFailure(ProfileSourceFailureKind.unavailable);
    }
  }

  @override
  Future<ProfileDto> read(String userId, {bool requireStoredPhoto = false}) =>
      _run(
        userId,
        () => _client
            .from('profiles')
            .select('id,display_name,city,contact_phone')
            .eq('id', userId)
            .single(),
        requireStoredPhoto: requireStoredPhoto,
      );
  @override
  Future<ProfileDto> update(
    String userId, {
    required String? displayName,
    required String? city,
    required String? contactPhone,
  }) => _run(
    userId,
    () => _client
        .from('profiles')
        .update({
          'display_name': displayName,
          'city': city,
          'contact_phone': contactPhone,
        })
        .eq('id', userId)
        .select('id,display_name,city,contact_phone')
        .single(),
  );
}
