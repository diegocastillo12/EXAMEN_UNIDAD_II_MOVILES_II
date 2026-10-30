import 'package:flutter/material.dart';
import 'shake_field.dart';

class ValidationSurface extends StatelessWidget {
  const ValidationSurface({
    required this.invalid,
    required this.errorId,
    required this.child,
    super.key,
  });
  final bool invalid;
  final int errorId;
  final Widget child;
  @override
  Widget build(BuildContext context) => ShakeField(
    hasError: invalid,
    errorId: errorId,
    child: Semantics(
      hint: invalid ? 'Revisa este campo' : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: invalid
              ? Border.all(color: const Color(0xFFB53F48), width: 3.5)
              : null,
        ),
        child: child,
      ),
    ),
  );
}
