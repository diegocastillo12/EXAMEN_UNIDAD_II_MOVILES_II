import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/pill_label.dart';
import '../../../../core/presentation/widgets/surface_card.dart';
import '../../../../core/theme/app_theme.dart';

class UpcomingFeatures extends StatelessWidget {
  const UpcomingFeatures({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Lo que viene', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 6),
      const Text('Estamos preparando nuevas formas de ayudar.'),
      const SizedBox(height: 16),
      LayoutBuilder(
        builder: (context, constraints) {
          const pets = _UpcomingCard(
            icon: Icons.pets_outlined,
            title: 'Tus mascotas',
            description: 'Su historia, sus fotos y un lugar propio.',
            color: AppColors.surface,
          );
          const cases = _UpcomingCard(
            icon: Icons.near_me_outlined,
            title: 'Ayuda cerca de ti',
            description: 'Búsquedas y avistamientos en tu comunidad.',
            color: AppColors.surface,
          );
          final expandedText = MediaQuery.textScalerOf(context).scale(14) > 20;
          if (constraints.maxWidth < 330 || expandedText) {
            return const Column(children: [pets, SizedBox(height: 12), cases]);
          }
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: pets),
              SizedBox(width: 12),
              Expanded(child: cases),
            ],
          );
        },
      ),
    ],
  );
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    color: color,
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 26, color: AppColors.ink),
        const SizedBox(height: 18),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(description, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 18),
        const PillLabel(
          label: 'Próximamente',
          color: AppColors.secondary,
          background: AppColors.background,
        ),
      ],
    ),
  );
}
