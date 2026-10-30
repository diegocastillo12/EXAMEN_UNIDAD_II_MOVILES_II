import '../../domain/entities/registration_outcome.dart';
import '../../domain/failures/registration_failure.dart';
import '../../domain/repositories/registration_repository.dart';
import '../data_sources/registration_data_source.dart';

final class RegistrationRepositoryImpl implements RegistrationRepository {
  const RegistrationRepositoryImpl(this._source);
  final RegistrationDataSource _source;

  Future<T> _execute<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on RegistrationSourceFailure catch (failure) {
      throw RegistrationFailure(switch (failure.kind) {
        RegistrationSourceFailureKind.invalidEmail =>
          RegistrationFailureKind.invalidEmail,
        RegistrationSourceFailureKind.weakPassword =>
          RegistrationFailureKind.weakPassword,
        RegistrationSourceFailureKind.alreadyRegistered =>
          RegistrationFailureKind.alreadyRegistered,
        RegistrationSourceFailureKind.rateLimited =>
          RegistrationFailureKind.rateLimited,
        RegistrationSourceFailureKind.unavailable =>
          RegistrationFailureKind.unavailable,
        RegistrationSourceFailureKind.invalidCode =>
          RegistrationFailureKind.invalidCode,
      });
    } catch (_) {
      throw const RegistrationFailure(RegistrationFailureKind.unavailable);
    }
  }

  @override
  Future<RegistrationOutcome> register({
    required String name,
    required String email,
    required String password,
  }) => _execute(() async {
    final result = await _source.register(
      name: name,
      email: email,
      password: password,
    );
    return result.hasSession
        ? RegistrationOutcome.authenticated
        : RegistrationOutcome.confirmationRequired;
  });

  @override
  Future<void> resendConfirmation(String email) =>
      _execute(() => _source.resendConfirmation(email));
  @override
  Future<void> verifyCode(String email, String code) =>
      _execute(() => _source.verifyCode(email, code));
}
