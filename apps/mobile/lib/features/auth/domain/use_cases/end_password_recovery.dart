import '../repositories/password_recovery_repository.dart';

final class EndPasswordRecovery {
  const EndPasswordRecovery(this._repository);
  final PasswordRecoveryRepository _repository;
  Future<void> call() => _repository.endRecovery();
}
