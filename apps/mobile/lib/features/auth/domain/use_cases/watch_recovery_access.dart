import '../entities/recovery_access.dart';
import '../repositories/password_recovery_repository.dart';

final class WatchRecoveryAccess {
  const WatchRecoveryAccess(this._repository);
  final PasswordRecoveryRepository _repository;
  Stream<RecoveryAccess> call() => _repository.watchAccess();
}
