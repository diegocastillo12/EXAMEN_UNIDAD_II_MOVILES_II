import '../../domain/entities/social_provider.dart';

enum AccessSourceFailureKind { rejected, emailNotConfirmed, unavailable }

final class AccessSourceFailure implements Exception {
  const AccessSourceFailure(this.kind);
  final AccessSourceFailureKind kind;
}

abstract interface class AuthAccessDataSource {
  Future<void> signInWithPassword({
    required String email,
    required String password,
  });
  Future<void> signInWithProvider(SocialProvider provider);
  Future<void> signOut();
}
