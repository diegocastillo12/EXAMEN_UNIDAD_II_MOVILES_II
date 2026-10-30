import 'package:flutter/material.dart';
import 'password_recovery_screen.dart';

/// Entry for recovery callbacks received outside the local request flow.
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const PasswordRecoveryScreen(resetMode: true);
}
