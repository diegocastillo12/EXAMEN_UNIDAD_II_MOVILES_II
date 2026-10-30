import '../failures/recovery_failure.dart';
import '../repositories/password_recovery_repository.dart';

final class ResetPassword {
  const ResetPassword(this._repository);
  final PasswordRecoveryRepository _repository;

  Future<void> call(String password, String confirmation) {
    if (password.length < 8) {
      throw const RecoveryFailure(RecoveryFailureKind.weakPassword);
    }
    if (password != confirmation) {
      throw const RecoveryFailure(RecoveryFailureKind.passwordMismatch);
    }
    return _repository.updatePassword(password);
  }
}
