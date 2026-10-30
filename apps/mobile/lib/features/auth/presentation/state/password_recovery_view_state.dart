enum RecoveryField { email, password, confirmation, code }

final class PasswordRecoveryViewState {
  const PasswordRecoveryViewState({
    this.isBusy = false,
    this.isVerifying = false,
    this.email,
    this.resendSeconds = 0,
    this.updated = false,
    this.errorField,
    this.fieldHint,
    this.message,
    this.errorId = 0,
    this.invalidLink = false,
  });
  final bool isBusy;
  final bool isVerifying;
  final String? email;
  final int resendSeconds;
  final bool updated;
  final RecoveryField? errorField;
  final String? fieldHint;
  final String? message;
  final int errorId;
  final bool invalidLink;

  PasswordRecoveryViewState copyWith({
    bool? isBusy,
    bool? isVerifying,
    int? resendSeconds,
    bool clearError = false,
    String? message,
  }) => PasswordRecoveryViewState(
    isBusy: isBusy ?? this.isBusy,
    isVerifying: isVerifying ?? this.isVerifying,
    email: email,
    resendSeconds: resendSeconds ?? this.resendSeconds,
    updated: updated,
    errorField: clearError ? null : errorField,
    fieldHint: clearError ? null : fieldHint,
    message: clearError ? message : message ?? this.message,
    errorId: errorId,
    invalidLink: invalidLink,
  );
}
