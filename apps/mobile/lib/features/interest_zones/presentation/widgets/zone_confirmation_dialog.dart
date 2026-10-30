import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/confirm_discard_action.dart';

Future<bool> confirmZoneAction(
  BuildContext context,
  String title,
  String description,
  String action,
) => confirmDiscardAction(context, title, description, action);
