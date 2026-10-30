import '../../domain/entities/recovery_access.dart';
import '../../domain/failures/recovery_failure.dart';
import '../../domain/repositories/password_recovery_repository.dart';

final class UnavailablePasswordRecoveryRepository
    implements PasswordRecoveryRepository {
  const UnavailablePasswordRecoveryRepository();
  @override
  Future<void> verifyCode(String email, String code) async =>
      throw const RecoveryFailure(RecoveryFailureKind.unavailable);
  @override
  Stream<RecoveryAccess> watchAccess() => Stream.value(RecoveryAccess.idle);
  @override
  Future<void> sendCode(String email) async =>
      throw const RecoveryFailure(RecoveryFailureKind.unavailable);
  @override
  Future<void> updatePassword(String password) async =>
      throw const RecoveryFailure(RecoveryFailureKind.unavailable);
  @override
  Future<void> endRecovery() async {}
}
