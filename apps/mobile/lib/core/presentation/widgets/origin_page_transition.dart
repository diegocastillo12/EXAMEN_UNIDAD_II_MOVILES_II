import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'app_page_background.dart';

/// Visual identity of a navigation trigger, captured in Navigator coordinates.
class OriginPageSource {
  const OriginPageSource({
    required this.bounds,
    required this.color,
    required this.radius,
    required this.child,
  });

  final Rect bounds;
  final Color color;
  final double radius;
  final Widget child;
}

/// Expands a rounded surface from the triggering control and reverses on pop.
class OriginPageTransition extends StatelessWidget {
  const OriginPageTransition({
    required this.animation,
    required this.child,
    this.origin,
    this.source,
    super.key,
  });

  final Animation<double> animation;
  final Widget child;
  final Rect? origin;
  final OriginPageSource? source;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    if (origin == null) {
      return FadeTransition(opacity: animation, child: child);
    }
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) {
          final progress = Curves.easeInOutCubic.transform(animation.value);
          final bounds = Offset.zero & constraints.biggest;
          final visibleOrigin = origin!.intersect(bounds);
          final start = visibleOrigin.isEmpty
              ? Rect.fromCenter(center: bounds.center, width: 48, height: 48)
              : visibleOrigin;
          final surface = Rect.lerp(start, bounds, progress)!;
          final radius = ui.lerpDouble(source?.radius ?? 24, 0, progress)!;
          final contentOpacity = originContentOpacity(animation.value);
          final sourceOpacity =
              1 -
              const Interval(
                0,
                .45,
                curve: Curves.easeInOutCubic,
              ).transform(animation.value);
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fromRect(
                rect: surface,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: source?.color ?? Colors.white,
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: progress > 0 && progress < 1
                        ? const [
                            BoxShadow(color: Color(0x20000000), blurRadius: 24),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    key: const ValueKey('origin-surface'),
                    borderRadius: BorderRadius.circular(radius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: progress,
                            child: const AppPageBackground(
                              child: SizedBox.expand(),
                            ),
                          ),
                        ),
                        OverflowBox(
                          alignment: Alignment.topLeft,
                          minWidth: bounds.width,
                          maxWidth: bounds.width,
                          minHeight: bounds.height,
                          maxHeight: bounds.height,
                          child: ExcludeSemantics(
                            excluding:
                                animation.status != AnimationStatus.completed,
                            child: IgnorePointer(
                              ignoring:
                                  animation.status != AnimationStatus.completed,
                              child: Transform.scale(
                                alignment: Alignment.topLeft,
                                scale: surface.width / bounds.width,
                                child: Opacity(
                                  opacity: contentOpacity,
                                  child: child,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (source != null && sourceOpacity > 0)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: ExcludeSemantics(
                                child: Opacity(
                                  key: const ValueKey('origin-page-source'),
                                  opacity: sourceOpacity,
                                  child: Center(
                                    child: OverflowBox(
                                      minWidth: source!.bounds.width,
                                      maxWidth: source!.bounds.width,
                                      minHeight: source!.bounds.height,
                                      maxHeight: source!.bounds.height,
                                      child: source!.child,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Let the source surface change shape before revealing destination content.
double originContentOpacity(double value) =>
    const Interval(.65, 1, curve: Curves.easeOutCubic).transform(value);
