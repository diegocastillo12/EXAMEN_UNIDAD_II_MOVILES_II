import '../models/registration_result_dto.dart';

enum RegistrationSourceFailureKind {
  invalidEmail,
  weakPassword,
  alreadyRegistered,
  rateLimited,
  unavailable,
  invalidCode,
}

final class RegistrationSourceFailure implements Exception {
  const RegistrationSourceFailure(this.kind);
  final RegistrationSourceFailureKind kind;
}

abstract interface class RegistrationDataSource {
  Future<RegistrationResultDto> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> resendConfirmation(String email);
  Future<void> verifyCode(String email, String code);
}
