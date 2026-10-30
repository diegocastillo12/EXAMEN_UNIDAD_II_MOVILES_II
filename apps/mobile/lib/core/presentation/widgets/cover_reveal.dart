import 'package:flutter/material.dart';
import 'app_page_background.dart';

/// A curtain with the shared background covers content without scaling it.
class CoverReveal extends StatelessWidget {
  const CoverReveal({required this.animation, super.key});
  final Animation<double> animation;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, _) => ClipRect(
      clipper: _CoverClipper(Curves.easeInOutCubic.transform(animation.value)),
      child: const AppPageBackground(child: SizedBox.expand()),
    ),
  );
}

class _CoverClipper extends CustomClipper<Rect> {
  const _CoverClipper(this.progress);
  final double progress;
  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, size.height * (1 - progress), size.width, size.height);
  @override
  bool shouldReclip(_CoverClipper oldClipper) =>
      oldClipper.progress != progress;
}

/// Keeps the header outside the transition. A completed cover starts the next
/// stagger timeline; edits/countdowns/errors do not change the stage.
class AuthStageTransition extends StatefulWidget {
  const AuthStageTransition({
    required this.stage,
    required this.builder,
    this.startCovered = false,
    this.enabled = true,
    super.key,
  });
  final Object stage;
  final Widget Function(bool play) builder;
  final bool startCovered;
  final bool enabled;
  @override
  State<AuthStageTransition> createState() => _AuthStageTransitionState();
}

class _AuthStageTransitionState extends State<AuthStageTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Widget? _previous;
  GlobalKey _stageKey = GlobalKey();
  GlobalKey? _previousKey;
  bool _covering = false;
  @override
  void initState() {
    super.initState();
    _covering = widget.startCovered && widget.enabled;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: _covering ? 0 : 1,
    )..addStatusListener(_completed);
  }

  void _completed(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted && _covering) {
      setState(() {
        _covering = false;
        _previous = null;
        _previousKey = null;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.enabled || MediaQuery.disableAnimationsOf(context)) {
      _covering = false;
      _previous = null;
      _previousKey = null;
      _controller.value = 1;
    } else if (_covering && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AuthStageTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) {
      _covering = false;
      _previous = null;
      _previousKey = null;
      _controller.value = 1;
      return;
    }
    // Completing loading is the same entrance, including its skeleton history.
    if (!oldWidget.enabled || oldWidget.stage == widget.stage) return;
    _previous = oldWidget.builder(true);
    _previousKey = _stageKey;
    _stageKey = GlobalKey();
    if (MediaQuery.disableAnimationsOf(context)) {
      _covering = false;
      _previous = null;
      _previousKey = null;
      _controller.value = 1;
    } else {
      _covering = true;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_completed);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: _covering,
    child: Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        KeyedSubtree(key: _stageKey, child: widget.builder(!_covering)),
        if (_previous != null)
          ExcludeSemantics(
            child: KeyedSubtree(key: _previousKey, child: _previous!),
          ),
        if (_covering)
          Positioned.fill(
            child: ExcludeSemantics(child: CoverReveal(animation: _controller)),
          ),
      ],
    ),
  );
}
