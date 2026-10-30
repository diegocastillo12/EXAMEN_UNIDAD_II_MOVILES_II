import '../../domain/entities/registration_outcome.dart';
import '../../domain/failures/registration_failure.dart';
import '../../domain/repositories/registration_repository.dart';

final class UnavailableRegistrationRepository
    implements RegistrationRepository {
  const UnavailableRegistrationRepository();
  @override
  Future<void> verifyCode(String email, String code) async =>
      throw const RegistrationFailure(RegistrationFailureKind.notConfigured);
  @override
  Future<RegistrationOutcome> register({
    required String name,
    required String email,
    required String password,
  }) async =>
      throw const RegistrationFailure(RegistrationFailureKind.notConfigured);
  @override
  Future<void> resendConfirmation(String email) async =>
      throw const RegistrationFailure(RegistrationFailureKind.notConfigured);
}
