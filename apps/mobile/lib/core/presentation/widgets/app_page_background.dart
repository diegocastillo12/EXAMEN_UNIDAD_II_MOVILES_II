import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Drifting blue clouds on white, fading towards the bottom of the viewport.
class AppPageBackground extends StatefulWidget {
  const AppPageBackground({
    required this.child,
    this.animate = const bool.fromEnvironment(
      'AMBIENT_BACKGROUND_MOTION',
      defaultValue: true,
    ),
    super.key,
  });

  final Widget child;
  final bool animate;

  @override
  State<AppPageBackground> createState() => _AppPageBackgroundState();
}

class _AppPageBackgroundState extends State<AppPageBackground>
    with SingleTickerProviderStateMixin {
  late final _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  void _syncMotion() {
    if (widget.animate &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.of(context)) {
      if (!_motion.isAnimating) _motion.repeat();
    } else {
      _motion.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(AppPageBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMotion();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.passthrough,
    children: [
      Positioned.fill(
        child: IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(painter: _CloudBackgroundPainter(_motion)),
          ),
        ),
      ),
      widget.child,
    ],
  );
}

class _CloudBackgroundPainter extends CustomPainter {
  _CloudBackgroundPainter(this.motion) : super(repaint: motion);
  final Animation<double> motion;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = Colors.white);

    final phase = motion.value * math.pi * 2;
    void cloud(Rect area, Color color, double offset) {
      area = area.shift(
        Offset(
          math.sin(phase + offset) * size.width * .13,
          math.cos(phase + offset) * size.height * .055,
        ),
      );
      canvas.save();
      canvas.translate(area.center.dx, area.center.dy);
      canvas.scale(area.width / 2, area.height / 2);
      canvas.drawRect(
        const Rect.fromLTRB(-1, -1, 1, 1),
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0, 1],
          ).createShader(const Rect.fromLTRB(-1, -1, 1, 1)),
      );
      canvas.restore();
    }

    canvas.save();
    canvas.clipRect(bounds);
    // Broad, overlapping clouds occupy every vertical section, with white
    // openings between them. Their paths close smoothly at the end of a cycle.
    cloud(
      Rect.fromLTWH(
        -size.width * .28,
        -size.height * .18,
        size.width * 1.55,
        size.height * .57,
      ),
      const Color(0xD9BAD5FA),
      0,
    );
    cloud(
      Rect.fromLTWH(
        size.width * .17,
        -size.height * .04,
        size.width * 1.12,
        size.height * .42,
      ),
      const Color(0x99B1CFF7),
      1.8,
    );
    cloud(
      Rect.fromLTWH(
        -size.width * .60,
        size.height * .24,
        size.width * 1.65,
        size.height * .57,
      ),
      const Color(0x9EC5DAF7),
      3.2,
    );
    cloud(
      Rect.fromLTWH(
        size.width * .10,
        size.height * .48,
        size.width * 1.50,
        size.height * .62,
      ),
      const Color(0x9EBAD5FA),
      4.5,
    );
    cloud(
      Rect.fromLTWH(
        -size.width * .65,
        size.height * .73,
        size.width * 1.65,
        size.height * .52,
      ),
      const Color(0x99CDDDF0),
      5.6,
    );
    // Keep the upper clouds intact and soften the background behind navigation.
    // Paint before the child so content and glass retain their own colors.
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00FFFFFF), Color(0x00FFFFFF), Color(0xF5FFFFFF)],
          stops: [0, .3, 1],
        ).createShader(bounds),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CloudBackgroundPainter oldDelegate) =>
      oldDelegate.motion != motion;
}
