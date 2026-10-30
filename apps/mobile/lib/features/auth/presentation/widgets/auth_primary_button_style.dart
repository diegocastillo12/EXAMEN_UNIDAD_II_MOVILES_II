import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';

ButtonStyle authPrimaryButtonStyle(
  BuildContext context, {
  bool isLoading = false,
}) => primaryActionButtonStyle(context, isLoading: isLoading);
