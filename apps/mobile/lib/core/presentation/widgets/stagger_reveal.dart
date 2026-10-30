import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// Same entrance parameters as Sader's root/login.
const _elementDurationMs = 850;
const _gapMs = 90;

/// One entrance timeline shared by staggered elements, without changing layout.
class StaggerReveal extends StatefulWidget {
  const StaggerReveal({
    required this.child,
    this.play = true,
    this.count = 2,
    this.enabled = true,
    super.key,
  }) : assert(count > 0);

  final Widget child;
  final bool play;
  final int count;
  final bool enabled;

  @override
  State<StaggerReveal> createState() => _StaggerRevealState();
}

class _StaggerRevealState extends State<StaggerReveal>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: _elementDurationMs + (widget.count - 1) * _gapMs,
    ),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _start();
  }

  @override
  void didUpdateWidget(StaggerReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = Duration(
      milliseconds: _elementDurationMs + (widget.count - 1) * _gapMs,
    );
    _start();
  }

  void _start() {
    if (!widget.enabled) {
      _controller.value = 1;
      return;
    }
    if (!widget.play) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _RevealTimeline(
    animation: _controller,
    count: widget.count,
    child: widget.child,
  );
}

/// Loading is part of the current entrance, rather than a new screen stage.
/// Once a skeleton resolves, the result is immediately visible and interactive.
class ContentReveal extends StatefulWidget {
  const ContentReveal({
    required this.loading,
    required this.child,
    this.play = true,
    this.count = 2,
    super.key,
  });
  final bool loading;
  final Widget child;
  final bool play;
  final int count;

  @override
  State<ContentReveal> createState() => _ContentRevealState();
}

class _ContentRevealState extends State<ContentReveal> {
  bool _sawSkeleton = false;

  @override
  Widget build(BuildContext context) {
    _sawSkeleton |= widget.loading;
    return StaggerReveal(
      count: widget.count,
      play: widget.play,
      enabled: !_sawSkeleton,
      child: widget.child,
    );
  }
}

class _RevealTimeline extends InheritedWidget {
  const _RevealTimeline({
    required this.animation,
    required this.count,
    required super.child,
  });

  final Animation<double> animation;
  final int count;

  @override
  bool updateShouldNotify(_RevealTimeline oldWidget) =>
      animation != oldWidget.animation || count != oldWidget.count;
}

/// A blurred sweep, adapted from Sader's use-stagger-reveal hook.
/// Each element takes 850 ms and starts 90 ms after its predecessor.
class StaggerRevealItem extends StatelessWidget {
  const StaggerRevealItem({
    required this.order,
    required this.child,
    this.enabled = true,
    this.preserveBackdrop = false,
    super.key,
  }) : assert(order >= 0);

  final int order;
  final Widget child;
  final bool enabled;

  /// Reveals glass and its content together without filtering their backdrop.
  final bool preserveBackdrop;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    final timeline = context
        .dependOnInheritedWidgetOfExactType<_RevealTimeline>();
    assert(timeline != null, 'StaggerRevealItem requires StaggerReveal');
    if (timeline == null) return child;
    assert(order < timeline.count, 'Reveal order exceeds element count');
    final totalDurationMs = _elementDurationMs + (timeline.count - 1) * _gapMs;
    final curve = Interval(
      order * _gapMs / totalDurationMs,
      (order * _gapMs + _elementDurationMs) / totalDurationMs,
      curve: const Cubic(0.22, 1, 0.36, 1),
    );
    return AnimatedBuilder(
      animation: timeline.animation,
      child: child,
      builder: (context, child) {
        final progress = curve.transform(timeline.animation.value);
        return IgnorePointer(
          ignoring: progress == 0,
          child: Opacity(
            opacity: progress,
            child: Transform.translate(
              offset: Offset(0, -28 * (1 - progress)),
              child: ImageFiltered(
                enabled: !preserveBackdrop && progress > 0 && progress < 1,
                imageFilter: ui.ImageFilter.blur(
                  sigmaX: 18 * (1 - progress),
                  sigmaY: 18 * (1 - progress),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
