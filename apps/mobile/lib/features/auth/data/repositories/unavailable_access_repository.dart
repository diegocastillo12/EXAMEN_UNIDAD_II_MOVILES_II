import '../../domain/entities/social_provider.dart';
import '../../domain/failures/access_failure.dart';
import '../../domain/repositories/access_repository.dart';

final class UnavailableAccessRepository implements AccessRepository {
  const UnavailableAccessRepository();
  Future<void> _unavailable() =>
      Future.error(const AccessFailure(AccessFailureKind.notConfigured));
  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) => _unavailable();
  @override
  Future<void> signInWithProvider(SocialProvider provider) => _unavailable();
  @override
  Future<void> signOut() => _unavailable();
}
