enum ZoneFailureKind {
  signedOut,
  invalidName,
  invalidPoint,
  invalidRadius,
  conflict,
  unavailable,
  network,
}

class ZoneFailure implements Exception {
  const ZoneFailure(this.kind);
  final ZoneFailureKind kind;
}
