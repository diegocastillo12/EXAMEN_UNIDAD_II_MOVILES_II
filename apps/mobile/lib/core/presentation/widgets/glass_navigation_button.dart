import 'package:flutter/material.dart';
import 'glass_surface.dart';

/// Shared glass control for returning from or closing a screen.
class GlassNavigationButton extends StatelessWidget {
  const GlassNavigationButton({
    required this.tooltip,
    required this.onPressed,
    this.icon = Icons.chevron_left_rounded,
    this.foregroundColor = const Color(0xFF111111),
    this.finish = GlassSurfaceFinish.polished,
    this.iconSize = 28,
    super.key,
  });
  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;
  final Color foregroundColor;
  final GlassSurfaceFinish finish;
  final double iconSize;

  @override
  Widget build(BuildContext context) => GlassSurface(
    radius: 26,
    finish: finish,
    child: IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size(52, 52),
        shape: const CircleBorder(),
        foregroundColor: foregroundColor,
      ),
      icon: Icon(icon, size: iconSize),
    ),
  );
}
