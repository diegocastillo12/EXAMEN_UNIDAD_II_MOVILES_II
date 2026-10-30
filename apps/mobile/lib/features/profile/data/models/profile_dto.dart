import '../../domain/entities/account_profile.dart';

final class ProfileDto {
  const ProfileDto({
    required this.id,
    this.displayName,
    this.city,
    this.avatarUri,
    this.email,
    this.contactPhone,
  });
  factory ProfileDto.fromMap(
    Map<String, dynamic> row, {
    Uri? avatarUri,
    String? email,
  }) => ProfileDto(
    id: row['id'] as String,
    displayName: row['display_name'] as String?,
    city: row['city'] as String?,
    contactPhone: row['contact_phone'] as String?,
    avatarUri: avatarUri,
    email: email,
  );
  final String id;
  final String? displayName;
  final String? city;
  final Uri? avatarUri;
  final String? email;
  final String? contactPhone;
  AccountProfile toEntity() => AccountProfile(
    userId: id,
    displayName: displayName,
    city: city,
    avatarUri: avatarUri,
    email: email,
    contactPhone: contactPhone,
  );
}
