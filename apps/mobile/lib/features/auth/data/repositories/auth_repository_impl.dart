import '../../domain/entities/auth_session.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Stream<AuthSession?> watchSession() {
    try {
      return _remote.watchSession().map((dto) => dto?.toEntity()).handleError((
        Object error,
        StackTrace stack,
      ) {
        Error.throwWithStackTrace(
          const AuthFailure.sessionObservation(),
          stack,
        );
      });
    } catch (_, stack) {
      return Stream.error(const AuthFailure.sessionObservation(), stack);
    }
  }
}
