import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/pill_label.dart';
import '../../../../core/presentation/widgets/surface_card.dart';
import '../../../../core/theme/app_theme.dart';

class CommunityHero extends StatelessWidget {
  const CommunityHero({super.key});

  @override
  Widget build(BuildContext context) => SurfaceCard(
    color: AppColors.surface,
    padding: const EdgeInsets.all(22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PillLabel(
          label: 'Una red de apoyo',
          icon: Icons.favorite_outline_rounded,
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 1.48,
          child: Image.asset(
            'assets/illustrations/community_pets.png',
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Pequeñas acciones.\nGrandes reencuentros.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        const Text(
          'Una foto, un aviso o una mirada atenta pueden marcar la diferencia.',
        ),
      ],
    ),
  );
}
