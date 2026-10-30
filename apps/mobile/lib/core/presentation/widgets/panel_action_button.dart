import 'package:flutter/material.dart';

/// Shared secondary action in an opaque panel, with accessible icon-only mode.
class PanelActionButton extends StatelessWidget {
  const PanelActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.iconOnly = true,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) => iconOnly
      ? IconButton(
          tooltip: label,
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFEEEEF0),
            disabledBackgroundColor: const Color(0xFFEEEEF0),
            foregroundColor: const Color(0xFF111111),
            fixedSize: const Size.square(56),
            shape: const CircleBorder(),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 26),
        )
      : TextButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        );
}
