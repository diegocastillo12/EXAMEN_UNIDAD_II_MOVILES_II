import 'entity_card_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'loading_shimmer.dart';
import '../../theme/app_theme.dart';

class SwipeActionCard extends StatefulWidget {
  const SwipeActionCard({
    required this.contentBuilder,
    required this.onOpen,
    required this.onDelete,
    this.loadingLabel = 'Eliminando',
    this.busy = false,
    this.disabled = false,
    super.key,
  });
  final Widget Function(Color foreground, Color secondary) contentBuilder;
  final VoidCallback onOpen;
  final Future<void> Function(Rect origin) onDelete;
  final String loadingLabel;
  final bool busy;
  final bool disabled;
  @override
  State<SwipeActionCard> createState() => _SwipeActionCardState();
}

class _SwipeActionCardState extends State<SwipeActionCard>
    with SingleTickerProviderStateMixin {
  late final _slide = AnimationController.unbounded(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  bool _settling = false;
  bool _pointerCanceled = false;
  bool get _enabled => !widget.disabled && !widget.busy && !_settling;

  Future<void> _returnAndConfirm(bool confirm) async {
    if (!_enabled) return;
    if (!confirm && _slide.value == 0) return;
    setState(() => _settling = true);
    try {
      if (MediaQuery.disableAnimationsOf(context)) {
        _slide.value = 0;
      } else if (_slide.value != 0) {
        await _slide.animateTo(0, curve: Curves.easeOutCubic).orCancel;
      }
      // Paint the restored position before a dialog is placed over the row.
      await WidgetsBinding.instance.endOfFrame;
      if (mounted &&
          confirm &&
          !_pointerCanceled &&
          !widget.disabled &&
          !widget.busy) {
        final box = context.findRenderObject();
        final navigator = Navigator.of(
          context,
          rootNavigator: true,
        ).context.findRenderObject();
        if (box is RenderBox && box.hasSize) {
          await widget.onDelete(
            box.localToGlobal(Offset.zero, ancestor: navigator) & box.size,
          );
        }
      }
    } on TickerCanceled {
      // Disposing or disabling the row cancels the pending confirmation.
    } finally {
      if (mounted) setState(() => _settling = false);
    }
  }

  @override
  void didUpdateWidget(SwipeActionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.disabled || widget.busy) {
      _slide.stop(canceled: true);
      _slide.value = 0;
    }
  }

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final triggerDistance = (constraints.maxWidth * .4).clamp(96.0, 180.0);
      return Listener(
        onPointerDown: (_) => _pointerCanceled = false,
        onPointerCancel: (_) => _pointerCanceled = true,
        child: GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          onHorizontalDragUpdate: !_enabled
              ? null
              : (details) {
                  if (!_enabled) return;
                  _slide.value = (_slide.value + details.delta.dx).clamp(
                    -constraints.maxWidth * .7,
                    0.0,
                  );
                },
          onHorizontalDragEnd: !_enabled
              ? null
              : (_) => _returnAndConfirm(
                  !_pointerCanceled && -_slide.value >= triggerDistance,
                ),
          onHorizontalDragCancel: !_enabled
              ? null
              : () => _returnAndConfirm(false),
          child: AnimatedBuilder(
            animation: _slide,
            builder: (context, _) {
              final progress = (-_slide.value / triggerDistance).clamp(
                0.0,
                1.0,
              );
              final colorProgress = Curves.easeOutCubic.transform(progress);
              final background = Color.lerp(
                AppColors.surface,
                const Color(0xFFC12F3D),
                colorProgress,
              )!;
              const lightRed = Color(0xFFFFE3E6);
              final foreground = Color.lerp(
                AppColors.ink,
                lightRed,
                colorProgress,
              )!;
              final secondary = Color.lerp(
                AppColors.secondary,
                lightRed,
                colorProgress,
              )!;
              final content = widget.contentBuilder(foreground, secondary);
              return Transform.translate(
                offset: Offset(_slide.value, 0),
                child: LoadingShimmer(
                  isLoading: widget.busy,
                  loadingLabel: widget.loadingLabel,
                  radius: 22,
                  child: EntityCardSurface(
                    color: background,
                    onTap: !_enabled ? null : widget.onOpen,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        AppColors.error.withValues(alpha: colorProgress * .32),
                        BlendMode.srcATop,
                      ),
                      child: content,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
