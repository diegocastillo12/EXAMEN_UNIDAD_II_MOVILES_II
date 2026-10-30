enum RegistrationField { name, email, password, confirmation, code }

class RegistrationViewState {
  const RegistrationViewState({
    this.isBusy = false,
    this.isVerifying = false,
    this.confirmationEmail,
    this.authenticated = false,
    this.errorField,
    this.fieldHint,
    this.message,
    this.messageIsError = false,
    this.errorId = 0,
    this.resendSeconds = 0,
  });
  final bool isBusy;
  final bool isVerifying;
  final String? confirmationEmail;
  final bool authenticated;
  final RegistrationField? errorField;
  final String? fieldHint;
  final String? message;
  final bool messageIsError;
  final int errorId;
  final int resendSeconds;

  RegistrationViewState copyWith({
    bool? isBusy,
    bool? isVerifying,
    int? resendSeconds,
    bool clearError = false,
    String? message,
  }) => RegistrationViewState(
    isBusy: isBusy ?? this.isBusy,
    isVerifying: isVerifying ?? this.isVerifying,
    confirmationEmail: confirmationEmail,
    authenticated: authenticated,
    errorField: clearError ? null : errorField,
    fieldHint: clearError ? null : fieldHint,
    message: clearError ? message : message ?? this.message,
    messageIsError: clearError ? false : messageIsError,
    errorId: errorId,
    resendSeconds: resendSeconds ?? this.resendSeconds,
  );
}
