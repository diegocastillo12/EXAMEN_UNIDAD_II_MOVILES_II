import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_session.dart';

/// Allows the shell to run without contacting an unconfigured backend.
class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  @override
  Stream<AuthSession?> watchSession() => Stream.value(null);
}
