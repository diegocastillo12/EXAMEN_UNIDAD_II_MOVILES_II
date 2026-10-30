import '../../../../core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import 'email_code_input.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';

class EmailCodeConfirmation extends StatelessWidget {
  const EmailCodeConfirmation({
    required this.email,
    required this.isBusy,
    this.isVerifying = false,
    required this.resendSeconds,
    this.message,
    this.validityMinutes = const int.fromEnvironment(
      'EMAIL_OTP_VALIDITY_MINUTES',
    ),
    required this.onResend,
    required this.onVerify,
    required this.onCodeEdited,
    this.codeHint,
    this.errorId = 0,
    super.key,
  });
  final String email;
  final bool isBusy;
  final bool isVerifying;
  final int resendSeconds;
  final String? message;
  final int validityMinutes;
  final VoidCallback onResend;
  final void Function(String) onVerify;
  final VoidCallback onCodeEdited;
  final String? codeHint;
  final int errorId;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      StaggerRevealItem(
        order: 2,
        child: Image.asset(
          'assets/illustrations/dog_with_envelope.png',
          width: 320,
          height: 320,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ),
      const SizedBox(height: 8),
      const StaggerRevealItem(
        order: 3,
        child: Text(
          'Revisa tu correo',
          textAlign: TextAlign.center,
          style: AppTypography.primaryTitle,
        ),
      ),
      const SizedBox(height: 16),
      StaggerRevealItem(
        order: 4,
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Ingresa el código que llegó a '),
              TextSpan(
                text: email,
                style: const TextStyle(color: Color(0xFF111111)),
              ),
              TextSpan(
                text:
                    '.${validityMinutes > 0 ? '\nVálido por $validityMinutes ${validityMinutes == 1 ? 'minuto' : 'minutos'}.' : ''}',
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
            color: Color(0xFF6E6E73),
          ),
        ),
      ),
      const SizedBox(height: 28),
      StaggerRevealItem(
        order: 5,
        child: EmailCodeInput(
          isBusy: isBusy,
          isVerifying: isVerifying,
          resendSeconds: resendSeconds,
          onVerify: onVerify,
          onEdited: onCodeEdited,
          errorHint: codeHint,
          errorId: errorId,
        ),
      ),
      const SizedBox(height: 16),
      const StaggerRevealItem(
        order: 6,
        child: Text(
          '¿No recibiste el código?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF6E6E73)),
        ),
      ),
      StaggerRevealItem(
        order: 7,
        child: LoadingShimmer(
          isLoading: isBusy && !isVerifying,
          loadingLabel: 'Reenviando código',
          highlight: const Color(0x3324282A),
          child: TextButton(
            onPressed: isBusy || resendSeconds > 0 ? null : onResend,
            style: TextButton.styleFrom(
              textStyle: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 16),
            ),
            child: Text(
              resendSeconds > 0
                  ? 'Reenviar código en ${(resendSeconds ~/ 60).toString().padLeft(2, '0')}:${(resendSeconds % 60).toString().padLeft(2, '0')}'
                  : 'Reenviar código',
            ),
          ),
        ),
      ),
    ],
  );
}
