import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Observes identity changes; token refreshes for the same user do not produce
/// a new identity. Profile and credential state are separate concerns.
final class WatchAuthSession {
  const WatchAuthSession(this._repository);

  final AuthRepository _repository;

  Stream<AuthSession?> call() => Stream.multi((output) {
    var hasPrevious = false;
    AuthSession? previous;
    final subscription = _repository.watchSession().listen(
      (session) {
        if (!hasPrevious || session != previous) {
          hasPrevious = true;
          previous = session;
          output.add(session);
        }
      },
      onError: (Object error, StackTrace stack) {
        // A fresh value must recover the UI even if identity is unchanged.
        hasPrevious = false;
        output.addError(error, stack);
      },
      onDone: output.close,
    );
    output.onCancel = subscription.cancel;
    output.onPause = subscription.pause;
    output.onResume = subscription.resume;
  });
}
