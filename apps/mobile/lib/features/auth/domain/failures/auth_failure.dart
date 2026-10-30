/// Domain failure independent of SDK exceptions and sensitive error messages.
final class AuthFailure implements Exception {
  const AuthFailure.sessionObservation();

  @override
  String toString() => 'AuthFailure.sessionObservation';
}
