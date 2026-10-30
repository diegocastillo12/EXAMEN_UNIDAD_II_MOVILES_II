import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'glass_navigation_button.dart';

/// Place directly in the screen Stack, outside its scrolling content.
/// Owns the safe top inset and symmetric margins for floating navigation.
class GlassNavigationBar extends StatelessWidget {
  const GlassNavigationBar({
    this.onBack,
    this.tooltip = 'Volver',
    this.enabled = true,
    this.trailing,
    super.key,
  });

  final VoidCallback? onBack;
  final String tooltip;
  final bool enabled;
  final Widget? trailing;

  static double topOf(BuildContext context) =>
      MediaQuery.paddingOf(context).top + 4;

  @override
  Widget build(BuildContext context) => Positioned(
    top: topOf(context),
    left: 24,
    right: 24,
    child: Row(
      children: [
        GlassNavigationButton(
          tooltip: tooltip,
          onPressed: !enabled
              ? null
              : onBack ??
                    () =>
                        context.canPop() ? context.pop() : context.go('/home'),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    ),
  );
}
