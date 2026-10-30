enum SavedCaseFailureKind { invalid, forbidden, unavailable, conflict, hidden }

class SavedCaseFailure implements Exception {
  const SavedCaseFailure(this.kind);
  final SavedCaseFailureKind kind;
}
