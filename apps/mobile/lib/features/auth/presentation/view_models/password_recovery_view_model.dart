import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/failures/recovery_failure.dart';
import '../../providers/password_recovery_providers.dart';
import '../state/password_recovery_view_state.dart';
import '../../domain/entities/recovery_access.dart';
import 'recovery_access_view_model.dart';

final passwordRecoveryViewModelProvider =
    NotifierProvider.autoDispose<
      PasswordRecoveryViewModel,
      PasswordRecoveryViewState
    >(PasswordRecoveryViewModel.new);

class PasswordRecoveryViewModel extends Notifier<PasswordRecoveryViewState> {
  Timer? _timer;
  int _errors = 0;
  int _operation = 0;
  @override
  PasswordRecoveryViewState build() {
    ref.onDispose(() => _timer?.cancel());
    ref.listen(recoveryAccessViewModelProvider, (previous, next) {
      if (next.asData?.value == RecoveryAccess.ready &&
          previous?.asData?.value != RecoveryAccess.ready) {
        _timer?.cancel();
        _operation++;
        state = const PasswordRecoveryViewState();
      }
    });
    return const PasswordRecoveryViewState();
  }

  Future<void> request(String email, {bool resend = false}) async {
    if (state.isBusy ||
        (state.email != null && !resend) ||
        state.resendSeconds > 0) {
      return;
    }
    state = state.copyWith(isBusy: true, clearError: true);
    final operation = ++_operation;
    try {
      await ref.read(requestPasswordRecoveryProvider)(email);
      if (!ref.mounted || operation != _operation) return;
      state = PasswordRecoveryViewState(email: email.trim(), resendSeconds: 60);
      _countdown();
    } on RecoveryFailure catch (failure) {
      if (ref.mounted && operation == _operation) _failure(failure.kind);
    } catch (_) {
      if (ref.mounted && operation == _operation) {
        _failure(RecoveryFailureKind.unavailable);
      }
    }
  }

  Future<void> resend() async {
    if (state.email != null) await request(state.email!, resend: true);
  }

  Future<void> verify(String code) async {
    final email = state.email;
    if (email == null || state.isBusy) return;
    state = state.copyWith(isBusy: true, isVerifying: true, clearError: true);
    final operation = ++_operation;
    try {
      await ref.read(verifyRecoveryCodeProvider)(email, code);
      if (ref.mounted && operation == _operation) {
        _timer?.cancel();
        state = state.copyWith(isBusy: false, isVerifying: false);
      }
    } on RecoveryFailure catch (failure) {
      if (ref.mounted && operation == _operation) _failure(failure.kind);
    } catch (_) {
      if (ref.mounted && operation == _operation) {
        _failure(RecoveryFailureKind.unavailable);
      }
    }
  }

  Future<void> reset(String password, String confirmation) async {
    if (state.isBusy || state.updated || state.invalidLink) return;
    _timer?.cancel();
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      await ref.read(resetPasswordProvider)(password, confirmation);
      if (ref.mounted) state = const PasswordRecoveryViewState(updated: true);
    } on RecoveryFailure catch (failure) {
      if (ref.mounted) _failure(failure.kind);
    } catch (_) {
      if (ref.mounted) _failure(RecoveryFailureKind.unavailable);
    }
  }

  Future<void> end() async {
    if (state.isBusy) return;
    _timer?.cancel();
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      await ref.read(endPasswordRecoveryProvider)();
      if (ref.mounted) state = state.copyWith(isBusy: false);
    } on RecoveryFailure catch (failure) {
      if (ref.mounted) _failure(failure.kind);
    } catch (_) {
      if (ref.mounted) _failure(RecoveryFailureKind.unavailable);
    }
  }

  void edited(RecoveryField field) {
    if (!state.isBusy && (state.errorField == field || state.message != null)) {
      state = state.copyWith(clearError: true);
    }
  }

  void _countdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!ref.mounted) {
        timer.cancel();
        return;
      }
      final remaining = state.resendSeconds - 1;
      if (remaining <= 0) timer.cancel();
      state = state.copyWith(resendSeconds: remaining < 0 ? 0 : remaining);
    });
  }

  void _failure(RecoveryFailureKind kind) {
    final field = switch (kind) {
      RecoveryFailureKind.invalidEmail => RecoveryField.email,
      RecoveryFailureKind.weakPassword ||
      RecoveryFailureKind.samePassword => RecoveryField.password,
      RecoveryFailureKind.passwordMismatch => RecoveryField.confirmation,
      RecoveryFailureKind.invalidCode => RecoveryField.code,
      _ => null,
    };
    final hint = switch (kind) {
      RecoveryFailureKind.invalidEmail => 'Correo no válido',
      RecoveryFailureKind.invalidCode =>
        'Código incorrecto o vencido. Revisa el correo o solicita otro.',
      RecoveryFailureKind.weakPassword =>
        'Usa una contraseña más segura (mínimo 8 caracteres)',
      RecoveryFailureKind.passwordMismatch => 'Las contraseñas no coinciden',
      RecoveryFailureKind.samePassword =>
        'Elige una contraseña distinta a la anterior',
      RecoveryFailureKind.invalidLink =>
        'El enlace venció o ya no es válido. Solicita uno nuevo.',
      RecoveryFailureKind.rateLimited =>
        'Espera un momento e inténtalo de nuevo.',
      RecoveryFailureKind.unavailable =>
        'No pudimos completar la solicitud. Reintenta.',
    };
    state = PasswordRecoveryViewState(
      email: state.email,
      resendSeconds: kind == RecoveryFailureKind.rateLimited
          ? 60
          : state.resendSeconds,
      updated: state.updated,
      invalidLink: state.invalidLink || kind == RecoveryFailureKind.invalidLink,
      errorField: field,
      fieldHint: field == null ? null : hint,
      message: field == null ? hint : null,
      errorId: ++_errors,
    );
    if (state.resendSeconds > 0 &&
        (kind == RecoveryFailureKind.rateLimited || _timer?.isActive != true)) {
      _countdown();
    }
  }
}
