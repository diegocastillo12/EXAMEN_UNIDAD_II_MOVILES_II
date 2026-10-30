enum PlaceSearchFailureKind { invalid, forbidden, unavailable, cancelled }

class PlaceSearchFailure implements Exception {
  const PlaceSearchFailure(this.kind);
  final PlaceSearchFailureKind kind;
}
