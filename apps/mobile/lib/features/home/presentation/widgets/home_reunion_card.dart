import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/glass_surface.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';

/// Community message with the original landing illustration.
class HomeReunionCard extends StatelessWidget {
  const HomeReunionCard({super.key});

  @override
  Widget build(BuildContext context) => StaggerRevealItem(
    order: 2,
    preserveBackdrop: true,
    child: GlassSurface(
      radius: 26,
      backdropBlendMode: BlendMode.src,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Image.asset(
                'assets/illustrations/reunion.png',
                fit: BoxFit.contain,
                semanticLabel:
                    'Un perro y un gato de la comunidad Entre Huellas',
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 12, 10, 10),
              child: Text(
                'Una comunidad para conectar mascotas perdidas con quienes pueden ayudar.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Color(0xFF6E6E73),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
