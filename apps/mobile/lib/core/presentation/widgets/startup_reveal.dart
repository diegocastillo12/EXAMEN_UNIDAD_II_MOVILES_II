import 'app_scaffold.dart';
import 'package:flutter/material.dart';

import 'brand_mark.dart';
import 'brand_name.dart';

/// Runs once per app mount, before mounting the router's destination animations.
class StartupReveal extends StatefulWidget {
  const StartupReveal({required this.child, super.key});
  final Widget child;

  @override
  State<StartupReveal> createState() => _StartupRevealState();
}

class _StartupRevealState extends State<StartupReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..addStatusListener(_complete);
  }

  void _complete(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _finished = true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _finished = true;
    } else if (!_finished && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return widget.child;
    return AppScaffold(
      body: Semantics(
        label: 'Entre Huellas. Iniciando aplicación',
        child: ExcludeSemantics(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final progress = const Interval(
                      .18,
                      .85,
                    ).transform(_controller.value);
                    final slide = Curves.easeOutBack.transform(progress);
                    // Initially center the icon, then center the complete lockup.
                    final iconLeft = 86 * (1 - slide);
                    final textLeft = 108 * slide;
                    return SizedBox(
                      width: 268,
                      height: 96,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: ClipRect(
                              clipper: _BrandTextClipper(iconLeft + 96),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    left: textLeft,
                                    top: 0,
                                    width: 160,
                                    height: 96,
                                    child: ClipRect(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Opacity(
                                          opacity: Curves.easeOut.transform(
                                            progress,
                                          ),
                                          child: const BrandName(textSize: 36),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: iconLeft,
                            top: 0,
                            child: const BrandMark(size: 96),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandTextClipper extends CustomClipper<Rect> {
  const _BrandTextClipper(this.left);
  final double left;
  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(left, 0, size.width + 20, size.height);
  @override
  bool shouldReclip(_BrandTextClipper old) => old.left != left;
}
