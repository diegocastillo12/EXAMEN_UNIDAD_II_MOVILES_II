import 'dart:async';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/recovery_access.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/failures/recovery_failure.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/repositories/password_recovery_repository.dart';

class FakePasswordRecovery implements PasswordRecoveryRepository {
  int verifications = 0;
  String? verifiedCode;
  @override
  Future<void> verifyCode(String email, String code) async {
    verifications++;
    verifiedCode = code;
    await _result();
    emit(RecoveryAccess.ready);
  }

  RecoveryAccess current = RecoveryAccess.idle;
  final events = StreamController<RecoveryAccess>.broadcast();
  RecoveryFailureKind? failure;
  Completer<void>? pending;
  String? sentEmail;
  String? savedPassword;
  int sends = 0;
  int updates = 0;
  int ends = 0;
  void Function()? onEnd;
  void emit(RecoveryAccess access) {
    current = access;
    events.add(access);
  }

  @override
  Stream<RecoveryAccess> watchAccess() => Stream.multi((output) {
    final subscription = events.stream.listen(
      output.add,
      onError: output.addError,
      onDone: output.close,
    );
    output.add(current);
    output.onCancel = subscription.cancel;
  });
  Future<void> _result() async {
    if (pending != null) await pending!.future;
    if (failure != null) throw RecoveryFailure(failure!);
  }

  @override
  Future<void> sendCode(String email) async {
    sends++;
    sentEmail = email;
    await _result();
  }

  @override
  Future<void> updatePassword(String password) async {
    if (current != RecoveryAccess.ready) {
      throw const RecoveryFailure(RecoveryFailureKind.invalidLink);
    }
    updates++;
    savedPassword = password;
    await _result();
  }

  @override
  Future<void> endRecovery() async {
    ends++;
    await _result();
    onEnd?.call();
    emit(RecoveryAccess.idle);
  }
}
