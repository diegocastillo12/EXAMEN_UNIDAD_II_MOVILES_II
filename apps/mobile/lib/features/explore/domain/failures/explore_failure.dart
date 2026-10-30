enum ExploreFailureKind {
  invalid,
  forbidden,
  unavailable,
  locationDenied,
  locationDisabled,
}

class ExploreFailure implements Exception {
  const ExploreFailure(this.kind);
  final ExploreFailureKind kind;
}
