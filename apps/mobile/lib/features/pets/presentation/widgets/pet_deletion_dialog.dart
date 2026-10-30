import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/confirm_action_dialog.dart';

Future<bool> confirmPetDeletion(
  BuildContext context,
  String name, {
  Rect? origin,
  Widget? source,
}) => confirmActionDialog(
  context,
  title: '¿Eliminar mascota?',
  description:
      'Se eliminarán la ficha de $name y sus fotos de forma permanente. Esta acción no se puede deshacer.',
  action: 'Eliminar mascota',
  semanticLabel: 'Confirmar eliminación de mascota',
  origin: origin,
  source: source,
);
