import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/app_input_decoration.dart';

InputDecoration authInputDecoration(
  String hint,
  IconData icon, {
  Widget? suffix,
  bool invalid = false,
  double verticalPadding = 22,
}) => appInputDecoration(
  hint,
  icon,
  suffix: suffix,
  invalid: invalid,
  verticalPadding: verticalPadding,
);
