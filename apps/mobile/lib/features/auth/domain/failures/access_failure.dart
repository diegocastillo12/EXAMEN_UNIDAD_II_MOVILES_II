enum AccessFailureKind {
  invalidEmail,
  emptyPassword,
  rejected,
  emailNotConfirmed,
  unavailable,
  notConfigured,
}

final class AccessFailure implements Exception {
  const AccessFailure(this.kind);
  final AccessFailureKind kind;

  @override
  String toString() => 'AccessFailure.${kind.name}';
}
