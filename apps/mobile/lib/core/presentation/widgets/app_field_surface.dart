import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'app_input_decoration.dart';

/// Shared frame with a persistent label inside the border.
class AppFieldSurface extends StatelessWidget {
  const AppFieldSurface({
    required this.label,
    required this.child,
    this.icon,
    this.suffix,
    this.invalid = false,
    this.footer,
    this.enabled = true,
    this.focused = false,
    super.key,
  });

  final String label;
  final Widget child;
  final IconData? icon;
  final Widget? suffix;
  final bool invalid;
  final Widget? footer;
  final bool enabled;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final hasError = invalid;
    final color = hasError ? AppColors.error : AppColors.secondary;
    return InputDecorator(
      isFocused: focused,
      decoration: appInputDecoration(
        null,
        null,
        suffix: suffix,
        invalid: hasError,
        verticalPadding: 16,
      ).copyWith(enabled: enabled),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ExcludeSemantics(
                child: Icon(icon, size: 22, color: color),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ExcludeSemantics(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      height: 1.3,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                child,
                if (footer != null) ...[const SizedBox(height: 8), footer!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
