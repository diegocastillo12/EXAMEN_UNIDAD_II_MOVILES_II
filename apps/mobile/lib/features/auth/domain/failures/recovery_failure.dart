enum RecoveryFailureKind {
  invalidEmail,
  weakPassword,
  passwordMismatch,
  samePassword,
  invalidLink,
  rateLimited,
  unavailable,
  invalidCode,
}

final class RecoveryFailure implements Exception {
  const RecoveryFailure(this.kind);
  final RecoveryFailureKind kind;
}
