import '../failures/registration_failure.dart';
import '../repositories/registration_repository.dart';

final class ResendRegistrationConfirmation {
  const ResendRegistrationConfirmation(this._repository);
  final RegistrationRepository _repository;

  Future<void> call(String email) async {
    final normalizedEmail = email.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalizedEmail)) {
      throw const RegistrationFailure(RegistrationFailureKind.invalidEmail);
    }
    await _repository.resendConfirmation(normalizedEmail);
  }
}
