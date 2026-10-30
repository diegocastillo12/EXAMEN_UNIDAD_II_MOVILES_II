import '../entities/social_provider.dart';
import '../failures/access_failure.dart';
import '../repositories/access_repository.dart';

final class SignIn {
  const SignIn(this._repository);
  final AccessRepository _repository;

  Future<void> withPassword({required String email, required String password}) {
    final normalizedEmail = email.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalizedEmail)) {
      return Future.error(const AccessFailure(AccessFailureKind.invalidEmail));
    }
    if (password.isEmpty) {
      return Future.error(const AccessFailure(AccessFailureKind.emptyPassword));
    }
    return _repository.signInWithPassword(
      email: normalizedEmail,
      password: password,
    );
  }

  Future<void> withProvider(SocialProvider provider) =>
      _repository.signInWithProvider(provider);
}
