import 'dart:ui';
import 'package:flutter/material.dart';

enum GlassSurfaceFinish { polished, frosted }

/// Neutral glass with a bounded backdrop blur and a directional polished rim.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    required this.child,
    this.radius = 36,
    this.backdropBlendMode = BlendMode.srcOver,
    this.finish = GlassSurfaceFinish.polished,
    super.key,
  });
  final Widget child;
  final double radius;
  final GlassSurfaceFinish finish;

  /// Use src when an ancestor opacity layer composites the glass entrance.
  final BlendMode backdropBlendMode;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: finish == GlassSurfaceFinish.frosted
          ? const [
              BoxShadow(
                color: Color(0x101F3147),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ]
          : const [
              BoxShadow(
                color: Color(0x2424282A),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x0F24282A),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        blendMode: backdropBlendMode,
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: CustomPaint(
          foregroundPainter: _GlassRim(radius, finish),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: finish == GlassSurfaceFinish.frosted
                    ? const [
                        Color(0x55C2CCD9),
                        Color(0x4DF7FAFF),
                        Color(0x66BCD4F0),
                        Color(0x70C4CAD4),
                      ]
                    : const [
                        Color(0x99FFFFFF),
                        Color(0x33F5F5F7),
                        Color(0x18FFFFFF),
                        Color(0x42E5E5EA),
                      ],
                stops: const [0, .35, .65, 1],
              ),
            ),
            child: child,
          ),
        ),
      ),
    ),
  );
}

class _GlassRim extends CustomPainter {
  const _GlassRim(this.radius, this.finish);
  final double radius;
  final GlassSurfaceFinish finish;
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    if (finish == GlassSurfaceFinish.frosted) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(bounds.deflate(.6), Radius.circular(radius)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xF2FFFFFF),
              Color(0x99FFFFFF),
              Color(0x40FFFFFF),
              Color(0xCCFFFFFF),
            ],
            stops: [0, .35, .72, 1],
          ).createShader(bounds),
      );
      return;
    }
    final outer = RRect.fromRectAndRadius(
      bounds.deflate(.75),
      Radius.circular(radius),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xCCFFFFFF),
            Color(0x3024282A),
            Color(0xB3FFFFFF),
          ],
          stops: [0, .35, .72, 1],
        ).createShader(bounds),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds.deflate(2.5), Radius.circular(radius - 2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x90FFFFFF), Color(0x00FFFFFF), Color(0x1824282A)],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(_GlassRim oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.finish != finish;
}
