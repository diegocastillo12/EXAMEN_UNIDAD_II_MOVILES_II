import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/glass_surface.dart';
import '../../../../core/presentation/widgets/navigation_accent_surface.dart';
import '../state/home_view_state.dart';

class LiquidNavigation extends StatefulWidget {
  const LiquidNavigation({
    required this.selected,
    required this.onSelect,
    required this.onReport,
    super.key,
  });
  final HomeSection selected;
  final ValueChanged<HomeSection> onSelect;
  final ValueChanged<BuildContext> onReport;
  static const labels = ['Inicio', 'Explorar', 'Mis mascotas'];
  static const icons = [
    Icons.home_outlined,
    Icons.travel_explore_outlined,
    Icons.pets_outlined,
  ];

  @override
  State<LiquidNavigation> createState() => _LiquidNavigationState();
}

class _LiquidNavigationState extends State<LiquidNavigation> {
  HomeSection? _hovered;
  HomeSection? _pressed;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: GlassSurface(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final slotWidth =
                    constraints.maxWidth / HomeSection.values.length;
                final rtl = Directionality.of(context) == TextDirection.rtl;
                return TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: widget.selected.index.toDouble(),
                    end: widget.selected.index.toDouble(),
                  ),
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  builder: (context, position, _) => Stack(
                    children: [
                      Positioned(
                        left:
                            (rtl
                                ? HomeSection.values.length - 1 - position
                                : position) *
                            slotWidth,
                        top: 0,
                        width: slotWidth,
                        height: 52,
                        child: IgnorePointer(
                          child: NavigationAccentSurface(
                            key: const ValueKey('navigation-active-indicator'),
                            engaged:
                                _hovered == widget.selected ||
                                _pressed == widget.selected,
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (final section in HomeSection.values)
                            Expanded(
                              child: Semantics(
                                label: LiquidNavigation.labels[section.index],
                                selected: widget.selected == section,
                                button: true,
                                child: Tooltip(
                                  message:
                                      LiquidNavigation.labels[section.index],
                                  excludeFromSemantics: true,
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(28),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(28),
                                      splashFactory: NoSplash.splashFactory,
                                      overlayColor:
                                          const WidgetStatePropertyAll(
                                            Colors.transparent,
                                          ),
                                      onHover: (value) => setState(() {
                                        _hovered = value ? section : null;
                                      }),
                                      onFocusChange: (value) => setState(() {
                                        _hovered = value ? section : null;
                                      }),
                                      onHighlightChanged: (value) =>
                                          setState(() {
                                            _pressed = value ? section : null;
                                          }),
                                      onTap: () => widget.onSelect(section),
                                      child: SizedBox(
                                        height: 52,
                                        child: Icon(
                                          LiquidNavigation.icons[section.index],
                                          size: 24,
                                          color: Color.lerp(
                                            const Color(0xFF6E6E73),
                                            Colors.white,
                                            (1 -
                                                    (position - section.index)
                                                        .abs())
                                                .clamp(0, 1),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Builder(
        builder: (source) => IconButton(
          tooltip: 'Reportar',
          onPressed: () => widget.onReport(source),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF111111),
            foregroundColor: Colors.white,
            minimumSize: const Size(64, 64),
            padding: const EdgeInsets.all(20),
            shape: const CircleBorder(),
          ),
          icon: const CustomPaint(size: Size(24, 24), painter: _NineDots()),
        ),
      ),
    ],
  );
}

class _NineDots extends CustomPainter {
  const _NineDots();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (var row = 0; row < 3; row++) {
      for (var column = 0; column < 3; column++) {
        canvas.drawCircle(Offset(4 + column * 8, 4 + row * 8), 2.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_NineDots oldDelegate) => false;
}
