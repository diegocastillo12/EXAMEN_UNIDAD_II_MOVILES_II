import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  /// Emits the restored session and subsequent authentication changes.
  Stream<AuthSession?> watchSession();
}
