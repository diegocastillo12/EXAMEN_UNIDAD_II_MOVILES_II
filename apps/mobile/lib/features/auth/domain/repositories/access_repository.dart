import '../entities/social_provider.dart';

abstract interface class AccessRepository {
  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

  /// Starts external authentication, without claiming a completed session.
  Future<void> signInWithProvider(SocialProvider provider);
  Future<void> signOut();
}
