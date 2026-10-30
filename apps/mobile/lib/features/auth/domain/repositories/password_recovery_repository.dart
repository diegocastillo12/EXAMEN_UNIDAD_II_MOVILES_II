import '../entities/recovery_access.dart';

abstract interface class PasswordRecoveryRepository {
  Stream<RecoveryAccess> watchAccess();
  Future<void> sendCode(String email);
  Future<void> verifyCode(String email, String code);
  Future<void> updatePassword(String password);
  Future<void> endRecovery();
}
