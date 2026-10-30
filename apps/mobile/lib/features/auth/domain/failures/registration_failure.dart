enum RegistrationFailureKind {
  invalidName,
  invalidEmail,
  weakPassword,
  passwordMismatch,
  alreadyRegistered,
  rateLimited,
  unavailable,
  notConfigured,
  invalidCode,
}

final class RegistrationFailure implements Exception {
  const RegistrationFailure(this.kind);
  final RegistrationFailureKind kind;
}
