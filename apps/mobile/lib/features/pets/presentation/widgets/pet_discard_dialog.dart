import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/confirm_action_dialog.dart';

Future<bool> confirmPetDiscard(BuildContext context) => confirmActionDialog(
  context,
  title: '¿Salir sin guardar?',
  description: 'Los cambios que no guardaste se perderán.',
  action: 'Salir sin guardar',
  cancelLabel: 'Seguir editando',
  semanticLabel: 'Confirmar salida sin guardar',
);
