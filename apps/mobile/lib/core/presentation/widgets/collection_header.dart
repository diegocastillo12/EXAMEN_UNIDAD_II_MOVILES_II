import '../../theme/app_typography.dart';
import 'package:flutter/material.dart';

class CollectionHeader extends StatelessWidget {
  const CollectionHeader({
    required this.title,
    this.action,
    this.keepActionInline = false,
    super.key,
  });
  final String title;
  final Widget? action;
  final bool keepActionInline;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Text(title, style: AppTypography.primaryTitle);
      if (action == null) return heading;
      if (!keepActionInline &&
          (constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(32) > 42)) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            if (action != null) ...[
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: action!),
            ],
          ],
        );
      }
      // Anchor titles to the content origin, independent of action height.
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: heading),
            const SizedBox(width: 12),
            action!,
          ],
        ),
      );
    },
  );
}
