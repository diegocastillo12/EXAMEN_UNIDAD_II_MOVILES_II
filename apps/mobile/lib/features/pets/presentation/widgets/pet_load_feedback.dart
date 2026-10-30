import '../../../../core/presentation/widgets/failure_feedback.dart';
import 'package:flutter/material.dart';
import '../../domain/failures/pet_failure.dart';

class PetLoadFeedback extends StatelessWidget {
  const PetLoadFeedback({required this.onRetry, this.error, super.key});
  final Object? error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => FailureFeedback(
    noticeId: error,
    onRetry: onRetry,
    message:
        error is PetFailure &&
            (error as PetFailure).kind == PetFailureKind.missing
        ? 'No encontramos esta mascota.'
        : 'No se pudo cargar la información.',
  );
}
