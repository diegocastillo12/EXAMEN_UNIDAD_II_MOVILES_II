enum ProfileFailureKind {
  unavailable,
  signedOut,
  missing,
  forbidden,
  invalidName,
  invalidCity,
  invalidPhone,
  invalidPhoto,
}

final class ProfileFailure implements Exception {
  const ProfileFailure(this.kind);
  final ProfileFailureKind kind;
}
