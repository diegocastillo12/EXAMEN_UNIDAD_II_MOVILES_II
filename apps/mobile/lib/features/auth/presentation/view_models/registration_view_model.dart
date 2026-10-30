import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/registration_outcome.dart';
import '../../domain/failures/registration_failure.dart';
import '../../providers/registration_providers.dart';
import '../state/registration_view_state.dart';

final registrationViewModelProvider =
    NotifierProvider.autoDispose<RegistrationViewModel, RegistrationViewState>(
      RegistrationViewModel.new,
    );

class RegistrationViewModel extends Notifier<RegistrationViewState> {
  Timer? _timer;
  int _errors = 0;
  @override
  RegistrationViewState build() {
    ref.onDispose(() => _timer?.cancel());
    return const RegistrationViewState();
  }

  Future<void> submit(
    String name,
    String email,
    String password,
    String confirmation,
  ) async {
    if (state.isBusy ||
        state.confirmationEmail != null ||
        state.authenticated) {
      return;
    }
    state = const RegistrationViewState(isBusy: true);
    try {
      final outcome = await ref.read(registerAccountProvider)(
        name: name,
        email: email,
        password: password,
        confirmation: confirmation,
      );
      if (!ref.mounted) return;
      state = outcome == RegistrationOutcome.authenticated
          ? const RegistrationViewState(authenticated: true)
          : RegistrationViewState(
              confirmationEmail: email.trim(),
              resendSeconds: 60,
            );
      if (state.confirmationEmail != null) _countdown();
    } on RegistrationFailure catch (failure) {
      if (ref.mounted) _failure(failure.kind);
    } catch (_) {
      if (ref.mounted) _failure(RegistrationFailureKind.unavailable);
    }
  }

  void _failure(RegistrationFailureKind kind) {
    final field = switch (kind) {
      RegistrationFailureKind.invalidName => RegistrationField.name,
      RegistrationFailureKind.invalidEmail ||
      RegistrationFailureKind.alreadyRegistered => RegistrationField.email,
      RegistrationFailureKind.weakPassword => RegistrationField.password,
      RegistrationFailureKind.passwordMismatch =>
        RegistrationField.confirmation,
      RegistrationFailureKind.invalidCode => RegistrationField.code,
      _ => null,
    };
    final hint = switch (kind) {
      RegistrationFailureKind.invalidName =>
        'Ingresa tu nombre (máximo 120 caracteres)',
      RegistrationFailureKind.invalidEmail => 'Correo no válido',
      RegistrationFailureKind.weakPassword =>
        'Usa una contraseña más segura (mínimo 8 caracteres)',
      RegistrationFailureKind.passwordMismatch =>
        'Las contraseñas no coinciden',
      RegistrationFailureKind.alreadyRegistered => 'Prueba iniciar sesión',
      RegistrationFailureKind.rateLimited =>
        'Espera un momento e inténtalo de nuevo.',
      RegistrationFailureKind.invalidCode =>
        'Código incorrecto o vencido. Revisa el correo o solicita otro.',
      _ => 'Registro no disponible. Reintenta.',
    };
    state = RegistrationViewState(
      confirmationEmail: state.confirmationEmail,
      resendSeconds: kind == RegistrationFailureKind.rateLimited
          ? 60
          : state.resendSeconds,
      errorField: field,
      fieldHint: field == null ? null : hint,
      message: field == null ? hint : null,
      messageIsError: field == null,
      errorId: ++_errors,
    );
    if (state.confirmationEmail != null &&
        state.resendSeconds > 0 &&
        (kind == RegistrationFailureKind.rateLimited ||
            _timer?.isActive != true)) {
      _countdown();
    }
  }

  void edited(RegistrationField field) {
    if (!state.isBusy && (state.errorField == field || state.message != null)) {
      state = state.copyWith(clearError: true);
    }
  }

  Future<void> verify(String code) async {
    final email = state.confirmationEmail;
    if (email == null || state.isBusy || state.authenticated) return;
    state = state.copyWith(isBusy: true, isVerifying: true, clearError: true);
    try {
      await ref.read(verifyRegistrationCodeProvider)(email, code);
      if (!ref.mounted) return;
      _timer?.cancel();
      state = const RegistrationViewState(authenticated: true);
    } on RegistrationFailure catch (failure) {
      if (ref.mounted) _failure(failure.kind);
    } catch (_) {
      if (ref.mounted) _failure(RegistrationFailureKind.unavailable);
    }
  }

  void _countdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!ref.mounted || state.resendSeconds <= 1) {
        timer.cancel();
        if (ref.mounted) state = state.copyWith(resendSeconds: 0);
      } else {
        state = state.copyWith(resendSeconds: state.resendSeconds - 1);
      }
    });
  }

  Future<void> resend() async {
    final email = state.confirmationEmail;
    if (email == null || state.isBusy || state.resendSeconds > 0) return;
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      await ref.read(resendRegistrationConfirmationProvider)(email);
      if (!ref.mounted) return;
      state = state.copyWith(
        isBusy: false,
        resendSeconds: 60,
        message: 'Revisa también la carpeta de spam.',
      );
      _countdown();
    } on RegistrationFailure catch (failure) {
      if (ref.mounted) _failure(failure.kind);
    } catch (_) {
      if (ref.mounted) _failure(RegistrationFailureKind.unavailable);
    }
  }
}
