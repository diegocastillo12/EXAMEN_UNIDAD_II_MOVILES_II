import '../failures/registration_failure.dart';
import '../repositories/registration_repository.dart';

final class VerifyRegistrationCode {
  const VerifyRegistrationCode(this._repository);
  final RegistrationRepository _repository;
  Future<void> call(String email, String code) {
    if (!RegExp(r'^[0-9]{6}$').hasMatch(code)) {
      throw const RegistrationFailure(RegistrationFailureKind.invalidCode);
    }
    final normalized = email.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalized)) {
      throw const RegistrationFailure(RegistrationFailureKind.invalidEmail);
    }
    return _repository.verifyCode(normalized, code);
  }
}
