import 'dart:math' as math;
import 'package:flutter/material.dart';

class ShakeField extends StatefulWidget {
  const ShakeField({
    required this.errorId,
    required this.hasError,
    required this.child,
    super.key,
  });
  final int errorId;
  final bool hasError;
  final Widget child;
  @override
  State<ShakeField> createState() => _ShakeFieldState();
}

class _ShakeFieldState extends State<ShakeField>
    with SingleTickerProviderStateMixin {
  late final _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );
  @override
  void didUpdateWidget(covariant ShakeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.hasError || MediaQuery.disableAnimationsOf(context)) {
      _animation.stop();
      _animation.value = 0;
    } else if (widget.errorId != oldWidget.errorId) {
      _animation.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    child: widget.child,
    builder: (context, child) => Transform.translate(
      offset: Offset(
        math.sin(_animation.value * math.pi * 6) * 4 * (1 - _animation.value),
        0,
      ),
      child: child,
    ),
  );
}
