enum PreferenceFailureKind {
  signedOut,
  invalidTypes,
  invalidChannels,
  conflict,
  unavailable,
}

class PreferenceFailure implements Exception {
  const PreferenceFailure(this.kind);
  final PreferenceFailureKind kind;
}
