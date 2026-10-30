import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/registration_repository.dart';
import '../domain/use_cases/register_account.dart';
import '../domain/use_cases/verify_registration_code.dart';
import '../domain/use_cases/resend_registration_confirmation.dart';

final verifyRegistrationCodeProvider = Provider(
  (ref) => VerifyRegistrationCode(ref.watch(registrationRepositoryProvider)),
);

final registrationRepositoryProvider = Provider<RegistrationRepository>(
  (ref) => throw StateError('RegistrationRepository must be injected.'),
);
final registerAccountProvider = Provider<RegisterAccount>(
  (ref) => RegisterAccount(ref.watch(registrationRepositoryProvider)),
);
final resendRegistrationConfirmationProvider =
    Provider<ResendRegistrationConfirmation>(
      (ref) => ResendRegistrationConfirmation(
        ref.watch(registrationRepositoryProvider),
      ),
    );
