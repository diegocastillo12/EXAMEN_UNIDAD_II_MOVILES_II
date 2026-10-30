import 'package:flutter/material.dart';
import 'confirmation_toast.dart';

class FailureFeedback extends StatelessWidget {
  const FailureFeedback({
    required this.message,
    required this.onRetry,
    this.noticeId,
    super.key,
  });
  final String message;
  final VoidCallback onRetry;
  final Object? noticeId;
  @override
  Widget build(BuildContext context) => ConfirmationToastHost(
    confirmed: true,
    message: message,
    noticeId: noticeId,
    isError: true,
    child: OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
  );
}
