import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/password_recovery_repository.dart';
import '../domain/use_cases/request_password_recovery.dart';
import '../domain/use_cases/reset_password.dart';
import '../domain/use_cases/verify_recovery_code.dart';
import '../domain/use_cases/watch_recovery_access.dart';
import '../domain/use_cases/end_password_recovery.dart';

final verifyRecoveryCodeProvider = Provider(
  (ref) => VerifyRecoveryCode(ref.watch(passwordRecoveryRepositoryProvider)),
);

final passwordRecoveryRepositoryProvider = Provider<PasswordRecoveryRepository>(
  (ref) => throw StateError('PasswordRecoveryRepository must be injected.'),
);
final requestPasswordRecoveryProvider = Provider(
  (ref) =>
      RequestPasswordRecovery(ref.watch(passwordRecoveryRepositoryProvider)),
);
final resetPasswordProvider = Provider(
  (ref) => ResetPassword(ref.watch(passwordRecoveryRepositoryProvider)),
);
final watchRecoveryAccessProvider = Provider(
  (ref) => WatchRecoveryAccess(ref.watch(passwordRecoveryRepositoryProvider)),
);
final endPasswordRecoveryProvider = Provider(
  (ref) => EndPasswordRecovery(ref.watch(passwordRecoveryRepositoryProvider)),
);
