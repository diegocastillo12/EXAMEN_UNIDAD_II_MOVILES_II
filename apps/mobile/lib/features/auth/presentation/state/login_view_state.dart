enum LoginField { email, password }

enum LoginFieldIssue { email, password, unconfirmedEmail, credentials }

final class LoginViewState {
  const LoginViewState({
    this.isBusy = false,
    this.message,
    this.isError = false,
    this.fieldIssue,
    this.errorId = 0,
  });
  final bool isBusy;
  final String? message;
  final bool isError;
  final LoginFieldIssue? fieldIssue;
  final int errorId;
  bool get emailInvalid =>
      fieldIssue == LoginFieldIssue.email ||
      fieldIssue == LoginFieldIssue.unconfirmedEmail ||
      fieldIssue == LoginFieldIssue.credentials;
  bool get passwordInvalid =>
      fieldIssue == LoginFieldIssue.password ||
      fieldIssue == LoginFieldIssue.credentials;
  String? get emailHint => switch (fieldIssue) {
    LoginFieldIssue.email => 'Correo no válido',
    LoginFieldIssue.unconfirmedEmail => 'Confirma tu correo',
    _ => null,
  };
  String? get passwordHint =>
      fieldIssue == LoginFieldIssue.password ? 'Ingresa tu contraseña' : null;
}
