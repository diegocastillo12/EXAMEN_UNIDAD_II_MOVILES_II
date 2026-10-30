import '../../domain/entities/recovery_access.dart';
import '../../domain/failures/recovery_failure.dart';
import '../../domain/repositories/password_recovery_repository.dart';
import '../data_sources/password_recovery_data_source.dart';

final class PasswordRecoveryRepositoryImpl
    implements PasswordRecoveryRepository {
  const PasswordRecoveryRepositoryImpl(this._source);
  final PasswordRecoveryDataSource _source;
  RecoveryFailure _failure(
    RecoverySourceFailure failure,
  ) => RecoveryFailure(switch (failure.kind) {
    RecoverySourceFailureKind.invalidEmail => RecoveryFailureKind.invalidEmail,
    RecoverySourceFailureKind.weakPassword => RecoveryFailureKind.weakPassword,
    RecoverySourceFailureKind.samePassword => RecoveryFailureKind.samePassword,
    RecoverySourceFailureKind.invalidLink => RecoveryFailureKind.invalidLink,
    RecoverySourceFailureKind.rateLimited => RecoveryFailureKind.rateLimited,
    RecoverySourceFailureKind.unavailable => RecoveryFailureKind.unavailable,
    RecoverySourceFailureKind.invalidCode => RecoveryFailureKind.invalidCode,
  });

  Future<void> _execute(Future<void> Function() action) async {
    try {
      await action();
    } on RecoverySourceFailure catch (failure) {
      throw _failure(failure);
    } catch (_) {
      throw const RecoveryFailure(RecoveryFailureKind.unavailable);
    }
  }

  @override
  Stream<RecoveryAccess> watchAccess() => _source
      .watchAccess()
      .map((dto) => dto.toEntity())
      .handleError((Object error) {
        throw error is RecoverySourceFailure
            ? _failure(error)
            : const RecoveryFailure(RecoveryFailureKind.unavailable);
      });
  @override
  Future<void> sendCode(String email) =>
      _execute(() => _source.sendCode(email));
  @override
  Future<void> verifyCode(String email, String code) =>
      _execute(() => _source.verifyCode(email, code));
  @override
  Future<void> updatePassword(String password) =>
      _execute(() => _source.updatePassword(password));
  @override
  Future<void> endRecovery() => _execute(_source.endRecovery);
}
