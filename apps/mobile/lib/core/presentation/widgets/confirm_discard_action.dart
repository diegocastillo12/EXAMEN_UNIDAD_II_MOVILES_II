import 'package:flutter/material.dart';
import 'confirm_action_dialog.dart';

Future<bool> confirmDiscardAction(
  BuildContext context,
  String title,
  String description,
  String action,
) => confirmActionDialog(
  context,
  title: title,
  description: description,
  action: action,
);
