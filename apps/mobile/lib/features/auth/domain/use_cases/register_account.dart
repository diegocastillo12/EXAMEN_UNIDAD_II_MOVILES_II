import '../entities/registration_outcome.dart';
import '../failures/registration_failure.dart';
import '../repositories/registration_repository.dart';

final class RegisterAccount {
  const RegisterAccount(this._repository);
  final RegistrationRepository _repository;

  Future<RegistrationOutcome> call({
    required String name,
    required String email,
    required String password,
    required String confirmation,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty || normalizedName.length > 120) {
      throw const RegistrationFailure(RegistrationFailureKind.invalidName);
    }
    final normalizedEmail = email.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalizedEmail)) {
      throw const RegistrationFailure(RegistrationFailureKind.invalidEmail);
    }
    if (password.length < 8) {
      throw const RegistrationFailure(RegistrationFailureKind.weakPassword);
    }
    if (password != confirmation) {
      throw const RegistrationFailure(RegistrationFailureKind.passwordMismatch);
    }
    return _repository.register(
      name: normalizedName,
      email: normalizedEmail,
      password: password,
    );
  }
}
