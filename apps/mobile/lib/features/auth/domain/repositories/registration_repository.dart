import '../entities/registration_outcome.dart';

abstract interface class RegistrationRepository {
  Future<RegistrationOutcome> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> resendConfirmation(String email);
  Future<void> verifyCode(String email, String code);
}
