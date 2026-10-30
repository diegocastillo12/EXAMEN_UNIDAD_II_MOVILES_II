import '../../domain/entities/social_provider.dart';
import '../../domain/failures/access_failure.dart';
import '../../domain/repositories/access_repository.dart';
import '../data_sources/auth_access_data_source.dart';

final class AccessRepositoryImpl implements AccessRepository {
  const AccessRepositoryImpl(this._source);
  final AuthAccessDataSource _source;

  Future<void> _execute(Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stack) {
      final kind = error is AccessSourceFailure
          ? switch (error.kind) {
              AccessSourceFailureKind.rejected => AccessFailureKind.rejected,
              AccessSourceFailureKind.emailNotConfirmed =>
                AccessFailureKind.emailNotConfirmed,
              AccessSourceFailureKind.unavailable =>
                AccessFailureKind.unavailable,
            }
          : AccessFailureKind.unavailable;
      Error.throwWithStackTrace(AccessFailure(kind), stack);
    }
  }

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) => _execute(
    () => _source.signInWithPassword(email: email, password: password),
  );
  @override
  Future<void> signInWithProvider(SocialProvider provider) =>
      _execute(() => _source.signInWithProvider(provider));
  @override
  Future<void> signOut() => _execute(_source.signOut);
}
