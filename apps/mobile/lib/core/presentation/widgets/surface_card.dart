import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.child,
    this.color = AppColors.surface,
    this.padding = const EdgeInsets.all(24),
    super.key,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: AppColors.divider.withValues(alpha: 0.55)),
    ),
    child: child,
  );
}
