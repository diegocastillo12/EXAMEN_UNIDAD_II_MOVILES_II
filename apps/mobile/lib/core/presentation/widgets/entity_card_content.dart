import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EntityCardContent extends StatelessWidget {
  const EntityCardContent({
    required this.title,
    required this.subtitle,
    this.imageUri,
    this.showChevron = true,
    this.foreground = AppColors.ink,
    this.secondary = AppColors.secondary,
    super.key,
  });
  final String title, subtitle;
  final bool showChevron;
  final Uri? imageUri;
  final Color foreground;
  final Color secondary;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(
      children: [
        if (imageUri != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              imageUri.toString(),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              cacheWidth: 128,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.pets_outlined, size: 28, color: secondary),
            ),
          )
        else
          Icon(Icons.pets_outlined, size: 28, color: secondary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 15, height: 1.25, color: secondary),
              ),
            ],
          ),
        ),
        if (showChevron) ...[
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: secondary),
        ],
      ],
    ),
  );
}
