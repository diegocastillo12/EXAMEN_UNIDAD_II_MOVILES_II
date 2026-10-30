import '../failures/recovery_failure.dart';
import '../repositories/password_recovery_repository.dart';

final class RequestPasswordRecovery {
  const RequestPasswordRecovery(this._repository);
  final PasswordRecoveryRepository _repository;

  Future<void> call(String email) {
    final normalized = email.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalized)) {
      throw const RecoveryFailure(RecoveryFailureKind.invalidEmail);
    }
    return _repository.sendCode(normalized);
  }
}
