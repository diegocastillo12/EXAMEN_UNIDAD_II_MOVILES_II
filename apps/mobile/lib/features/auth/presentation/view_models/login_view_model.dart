import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/social_provider.dart';
import '../../domain/failures/access_failure.dart';
import '../../providers/auth_providers.dart';
import '../state/login_view_state.dart';

final loginViewModelProvider =
    NotifierProvider.autoDispose<LoginViewModel, LoginViewState>(
      LoginViewModel.new,
    );

class LoginViewModel extends Notifier<LoginViewState> {
  int _errorSequence = 0;
  @override
  LoginViewState build() => const LoginViewState();

  Future<void> _run(
    Future<void> Function() action,
    String success, {
    bool credentials = false,
  }) async {
    if (state.isBusy) return;
    state = const LoginViewState(isBusy: true);
    try {
      await action();
      if (ref.mounted) state = LoginViewState(message: success);
    } on AccessFailure catch (failure) {
      if (ref.mounted) {
        state = LoginViewState(
          errorId: ++_errorSequence,
          fieldIssue: credentials
              ? switch (failure.kind) {
                  AccessFailureKind.invalidEmail => LoginFieldIssue.email,
                  AccessFailureKind.emptyPassword => LoginFieldIssue.password,
                  AccessFailureKind.emailNotConfirmed =>
                    LoginFieldIssue.unconfirmedEmail,
                  AccessFailureKind.rejected => LoginFieldIssue.credentials,
                  _ => null,
                }
              : null,
          message: switch (failure.kind) {
            AccessFailureKind.emailNotConfirmed => 'Confirma tu correo',
            AccessFailureKind.invalidEmail => 'Correo no válido',
            AccessFailureKind.emptyPassword => 'Ingresa tu contraseña.',
            AccessFailureKind.rejected => 'Correo o contraseña incorrectos.',
            AccessFailureKind.unavailable => 'Acceso no disponible. Reintenta.',
            AccessFailureKind.notConfigured => 'Acceso no disponible.',
          },
          isError: true,
        );
      }
    } catch (_) {
      if (ref.mounted) {
        state = const LoginViewState(
          message: 'No se pudo ingresar. Reintenta.',
          isError: true,
        );
      }
    }
  }

  void fieldEdited(LoginField field) {
    final matches =
        state.fieldIssue == LoginFieldIssue.credentials ||
        (field == LoginField.email && state.emailInvalid) ||
        (field == LoginField.password && state.passwordInvalid);
    if (!state.isBusy && matches) {
      state = LoginViewState(errorId: state.errorId);
    }
  }

  Future<void> password(String email, String password) => _run(
    () =>
        ref.read(signInProvider).withPassword(email: email, password: password),
    'Sesión iniciada.',
    credentials: true,
  );
  Future<void> social(SocialProvider provider) => _run(
    () => ref.read(signInProvider).withProvider(provider),
    'Completa el acceso en el navegador. La sesión se confirmará al regresar.',
  );
  Future<void> signOut() =>
      _run(() => ref.read(signOutProvider)(), 'Sesión cerrada.');
}
