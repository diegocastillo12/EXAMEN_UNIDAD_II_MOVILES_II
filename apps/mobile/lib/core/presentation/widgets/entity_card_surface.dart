import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EntityCardSurface extends StatelessWidget {
  const EntityCardSurface({
    required this.child,
    this.onTap,
    this.color = AppColors.surface,
    super.key,
  });
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    borderRadius: BorderRadius.circular(22),
    clipBehavior: Clip.antiAlias,
    child: InkWell(onTap: onTap, child: child),
  );
}
