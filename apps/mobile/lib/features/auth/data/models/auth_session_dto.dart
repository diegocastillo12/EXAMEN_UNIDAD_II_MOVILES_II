import '../../domain/entities/auth_session.dart';

/// Safe projection of external auth data. Tokens never leave the SDK adapter.
final class AuthSessionDto {
  const AuthSessionDto({required this.userId});

  final String userId;

  AuthSession toEntity() => AuthSession(userId: userId);
}
