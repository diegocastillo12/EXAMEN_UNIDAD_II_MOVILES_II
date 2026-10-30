import 'package:flutter/material.dart';
import 'confirmation_toast.dart';

/// A failed image keeps its space; its explanation belongs to the top notice.
class CasePhotoFailure extends StatelessWidget {
  const CasePhotoFailure({super.key});

  @override
  Widget build(BuildContext context) => const ConfirmationToastHost(
    confirmed: true,
    isError: true,
    message: 'Foto no disponible. Vuelve a consultar para reintentar.',
    child: SizedBox(
      height: 120,
      child: Center(child: Icon(Icons.broken_image_outlined)),
    ),
  );
}
