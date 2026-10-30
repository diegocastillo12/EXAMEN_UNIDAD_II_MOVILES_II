import '../models/recovery_access_dto.dart';

enum RecoverySourceFailureKind {
  invalidEmail,
  weakPassword,
  samePassword,
  invalidLink,
  rateLimited,
  unavailable,
  invalidCode,
}

final class RecoverySourceFailure implements Exception {
  const RecoverySourceFailure(this.kind);
  final RecoverySourceFailureKind kind;
}

abstract interface class PasswordRecoveryDataSource {
  Stream<RecoveryAccessDto> watchAccess();
  Future<void> sendCode(String email);
  Future<void> verifyCode(String email, String code);
  Future<void> updatePassword(String password);
  Future<void> endRecovery();
}
