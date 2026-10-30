import 'package:flutter/material.dart';
import '../state/registration_view_state.dart';
import 'email_code_confirmation.dart';

class RegistrationConfirmation extends StatelessWidget {
  const RegistrationConfirmation({
    required this.state,
    required this.onResend,
    required this.onVerify,
    required this.onCodeEdited,
    super.key,
  });
  final RegistrationViewState state;
  final VoidCallback onResend;
  final void Function(String) onVerify;
  final VoidCallback onCodeEdited;
  @override
  Widget build(BuildContext context) => EmailCodeConfirmation(
    email: state.confirmationEmail!,
    isBusy: state.isBusy,
    isVerifying: state.isVerifying,
    resendSeconds: state.resendSeconds,
    message: state.message,
    onResend: onResend,
    onVerify: onVerify,
    onCodeEdited: onCodeEdited,
    codeHint: state.errorField == RegistrationField.code
        ? state.fieldHint
        : null,
    errorId: state.errorId,
  );
}
