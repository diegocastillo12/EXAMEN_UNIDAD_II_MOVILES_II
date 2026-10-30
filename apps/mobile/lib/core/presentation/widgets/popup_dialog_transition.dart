import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Opens the complete confirmation together, without morphing its surface.
class PopupDialogTransition extends StatelessWidget {
  const PopupDialogTransition({
    required this.animation,
    required this.child,
    super.key,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return SafeArea(
      child: Padding(
        padding: MediaQuery.viewInsetsOf(context) + const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SizedBox(
              width: double.infinity,
              child: AnimatedBuilder(
                animation: animation,
                child: Material(
                  animationDuration: Duration.zero,
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(28),
                  clipBehavior: Clip.antiAlias,
                  child: child,
                ),
                builder: (context, surface) {
                  final progress = reduced
                      ? 1.0
                      : (animation.status == AnimationStatus.reverse
                                ? Curves.easeInCubic
                                : Curves.easeOutCubic)
                            .transform(animation.value);
                  return FadeTransition(
                    opacity: AlwaysStoppedAnimation(progress),
                    child: Transform.scale(
                      scale: .96 + .04 * progress,
                      child: surface,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
