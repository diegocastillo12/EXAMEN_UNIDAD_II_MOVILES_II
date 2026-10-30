/// Session identity only; SDK objects and tokens stay in the data layer.
final class AuthSession {
  const AuthSession({required this.userId});

  final String userId;

  @override
  bool operator ==(Object other) =>
      other is AuthSession && other.userId == userId;

  @override
  int get hashCode => userId.hashCode;
}
