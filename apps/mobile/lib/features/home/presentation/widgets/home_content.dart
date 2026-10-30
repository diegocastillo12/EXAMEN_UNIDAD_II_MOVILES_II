import '../../../../core/theme/app_typography.dart';
import '../../../../core/presentation/widgets/origin_page_transition.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../../core/presentation/widgets/glass_surface.dart';
import 'home_reunion_card.dart';
import '../state/home_view_state.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({
    required this.onSelect,
    required this.onReport,
    super.key,
  });
  final ValueChanged<HomeSection> onSelect;
  final ValueChanged<BuildContext> onReport;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      StaggerRevealItem(
        order: 0,
        child: Semantics(
          label: 'Su regreso empieza contigo',
          excludeSemantics: true,
          child: DefaultTextStyle.merge(
            style: AppTypography.primaryTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Su regreso'),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF459FF6), Color(0xFF75C9EF)],
                  ).createShader(bounds),
                  child: const Text(
                    'empieza contigo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 22),
      StaggerRevealItem(
        order: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final vertical =
                constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(14) > 20;
            final cards = [
              HomeQuickAction(
                icon: Icons.search_rounded,
                label: 'Reportar',
                onTap: onReport,
              ),
              HomeQuickAction(
                icon: Icons.assignment_outlined,
                label: 'Mis reportes',
                onTap: (source) => source.push('/home/my-reports'),
              ),
              HomeQuickAction(
                icon: Icons.pets_outlined,
                label: 'Mis mascotas',
                onTap: (_) => onSelect(HomeSection.pets),
              ),
            ];
            return vertical
                ? Column(
                    children: [
                      for (final card in cards)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: card,
                        ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(child: cards[i]),
                      ],
                    ],
                  );
          },
        ),
      ),
      const SizedBox(height: 16),
      HomeQuickAction(
        icon: Icons.manage_search_rounded,
        label: 'Buscar coincidencias',
        onTap: (source) => openHomeAction(
          source,
          '/home/coincidencias',
          Icons.manage_search_rounded,
        ),
      ),
      const SizedBox(height: 12),
      HomeQuickAction(
        icon: Icons.pets_outlined,
        label: 'Encontré una mascota y no sé de quién es',
        onTap: (source) => openHomeAction(
          source,
          '/home/found-cases/new?independent=true',
          Icons.pets_outlined,
        ),
      ),
      const SizedBox(height: 28),
      const HomeReunionCard(),
      const SizedBox(height: 28),
      StaggerRevealItem(
        order: 3,
        preserveBackdrop: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Cerca de ti',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 14),
            const HomeNotice(
              icon: Icons.location_on_outlined,
              title: 'Explora cerca de ti',
              description:
                  'Consulta casos cercanos con tu ubicación actual y un radio inicial de 15 km, o elige otra ubicación manualmente.',
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => onSelect(HomeSection.explore),
                child: const Text('Conoce Explorar'),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class HomeQuickAction extends StatelessWidget {
  const HomeQuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });
  final IconData icon;
  final String label;
  final ValueChanged<BuildContext> onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFF111111),
    borderRadius: BorderRadius.circular(22),
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => onTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Icon(icon, size: 25, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class HomeNotice extends StatelessWidget {
  const HomeNotice({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });
  final IconData icon;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => GlassSurface(
    radius: 26,
    backdropBlendMode: BlendMode.src,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF6E6E73), size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Color(0xFF6E6E73),
            ),
          ),
        ],
      ),
    ),
  );
}

void showHomeInfo(
  BuildContext context, {
  required String title,
  required String description,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
      ? AnimationStyle.noAnimation
      : null,
  useSafeArea: true,
  showDragHandle: true,
  backgroundColor: Colors.white,
  builder: (context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTypography.primaryTitle),
        const SizedBox(height: 16),
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
            color: Color(0xFF6E6E73),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    ),
  ),
);

void openLostReport(
  BuildContext context, {
  VoidCallback? onReturn,
  Color color = const Color(0xFF111111),
  double radius = 32,
}) {
  final box = context.findRenderObject();
  final navigator = Navigator.of(context).context.findRenderObject();
  final origin = box is RenderBox && box.hasSize
      ? box.localToGlobal(Offset.zero, ancestor: navigator) & box.size
      : null;
  context
      .push(
        '/home/lost-cases/new',
        extra: origin == null
            ? null
            : OriginPageSource(
                bounds: origin,
                color: color,
                radius: radius,
                child: Icon(
                  Icons.search_rounded,
                  color: color == const Color(0xFF111111)
                      ? Colors.white
                      : const Color(0xFF111111),
                ),
              ),
      )
      .then((_) => onReturn?.call());
}

void openHomeAction(BuildContext context, String path, IconData icon) {
  final box = context.findRenderObject(),
      navigator = Navigator.of(context).context.findRenderObject();
  final bounds = box is RenderBox && box.hasSize
      ? box.localToGlobal(Offset.zero, ancestor: navigator) & box.size
      : null;
  context.push(
    path,
    extra: bounds == null
        ? null
        : OriginPageSource(
            bounds: bounds,
            color: const Color(0xFF111111),
            radius: 22,
            child: Icon(icon, color: Colors.white),
          ),
  );
}
