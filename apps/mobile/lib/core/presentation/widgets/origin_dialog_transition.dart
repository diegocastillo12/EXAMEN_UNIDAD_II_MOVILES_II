import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'origin_page_transition.dart';

/// A single, stable dialog layout whose surface morphs from the triggering row.
class OriginDialogTransition extends StatefulWidget {
  const OriginDialogTransition({
    required this.animation,
    required this.child,
    this.origin,
    this.source,
    super.key,
  });
  final Animation<double> animation;
  final Widget child;
  final Rect? origin;
  final Widget? source;
  @override
  State<OriginDialogTransition> createState() => _OriginDialogTransitionState();
}

class _OriginDialogTransitionState extends State<OriginDialogTransition> {
  final _targetKey = GlobalKey();
  Rect? _target;
  bool _measurementQueued = false;
  bool _closing = false;

  void _measure() {
    if (_measurementQueued) return;
    _measurementQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measurementQueued = false;
      if (!mounted) return;
      final box = _targetKey.currentContext?.findRenderObject();
      final root = context.findRenderObject();
      if (box is RenderBox && box.hasSize && root is RenderBox) {
        final rect = box.localToGlobal(Offset.zero, ancestor: root) & box.size;
        if (rect != _target) setState(() => _target = rect);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _measure();
    final reduced = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) => SafeArea(
        child: Padding(
          padding: MediaQuery.viewInsetsOf(context) + const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SizedBox(
                width: double.infinity,
                child: RepaintBoundary(
                  key: _targetKey,
                  child: AnimatedBuilder(
                    animation: widget.animation,
                    child: widget.child,
                    builder: (context, child) {
                      if (widget.animation.status == AnimationStatus.reverse) {
                        _closing = true;
                      } else if (widget.animation.status ==
                          AnimationStatus.forward) {
                        _closing = false;
                      }
                      final target = _target;
                      final progress = reduced
                          ? 1.0
                          : Curves.easeInOutCubic.transform(
                              widget.animation.value,
                            );
                      final bounds = Offset.zero & constraints.biggest;
                      final origin = widget.origin?.intersect(bounds);
                      final start = origin == null || origin.isEmpty
                          ? Rect.fromCenter(
                              center: target?.center ?? bounds.center,
                              width: 48,
                              height: 48,
                            )
                          : origin;
                      final surface = target == null
                          ? start
                          : Rect.lerp(start, target, progress)!;
                      final scaleX = target == null
                          ? 1.0
                          : surface.width / target.width;
                      final scaleY = target == null
                          ? 1.0
                          : surface.height / target.height;
                      final radius = lerpDouble(22, 28, progress)!;
                      return Opacity(
                        key: const ValueKey('origin-dialog-overlay'),
                        opacity: target == null && !reduced
                            ? 0
                            : !reduced && _closing
                            ? const Interval(
                                0,
                                .18,
                                curve: Curves.easeOutCubic,
                              ).transform(widget.animation.value)
                            : 1,
                        child: Transform.translate(
                          offset: target == null
                              ? Offset.zero
                              : surface.topLeft - target.topLeft,
                          child: Transform.scale(
                            alignment: Alignment.topLeft,
                            scaleX: scaleX,
                            scaleY: scaleY,
                            child: Material(
                              animationDuration: Duration.zero,
                              key: const ValueKey('origin-dialog-surface'),
                              color: Color.lerp(
                                AppColors.surface,
                                AppColors.background,
                                progress,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.elliptical(
                                    radius / scaleX,
                                    radius / scaleY,
                                  ),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  IgnorePointer(
                                    ignoring:
                                        !reduced &&
                                        widget.animation.status !=
                                            AnimationStatus.completed,
                                    child: ExcludeSemantics(
                                      excluding:
                                          !reduced &&
                                          widget.animation.status !=
                                              AnimationStatus.completed,
                                      child: Opacity(
                                        key: const ValueKey(
                                          'origin-dialog-content',
                                        ),
                                        opacity: reduced
                                            ? 1
                                            : originContentOpacity(
                                                widget.animation.value,
                                              ),
                                        child: child,
                                      ),
                                    ),
                                  ),
                                  if (!reduced &&
                                      !_closing &&
                                      widget.source != null &&
                                      widget.origin != null &&
                                      widget.animation.value < .45)
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: ExcludeSemantics(
                                          child: Opacity(
                                            key: const ValueKey(
                                              'origin-dialog-source',
                                            ),
                                            opacity:
                                                1 -
                                                Curves.easeOutCubic.transform(
                                                  (widget.animation.value / .45)
                                                      .clamp(0.0, 1.0),
                                                ),
                                            child: FittedBox(
                                              fit: BoxFit.fill,
                                              child: SizedBox(
                                                width: widget.origin!.width,
                                                height: widget.origin!.height,
                                                child: widget.source,
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
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
