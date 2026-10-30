final class AccountProfile {
  const AccountProfile({
    required this.userId,
    this.displayName,
    this.city,
    this.avatarUri,
    this.email,
    this.contactPhone,
  });
  final String userId;
  final String? displayName;
  final String? city;
  final Uri? avatarUri;
  final String? email;
  final String? contactPhone;
}
