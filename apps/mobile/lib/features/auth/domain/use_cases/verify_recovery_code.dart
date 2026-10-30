import '../failures/recovery_failure.dart';
import '../repositories/password_recovery_repository.dart';

final class VerifyRecoveryCode {
  const VerifyRecoveryCode(this._repository);
  final PasswordRecoveryRepository _repository;
  Future<void> call(String email, String code) {
    if (!RegExp(r'^[0-9]{6}$').hasMatch(code)) {
      throw const RecoveryFailure(RecoveryFailureKind.invalidCode);
    }
    final normalized = email.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalized)) {
      throw const RecoveryFailure(RecoveryFailureKind.invalidEmail);
    }
    return _repository.verifyCode(normalized, code);
  }
}
