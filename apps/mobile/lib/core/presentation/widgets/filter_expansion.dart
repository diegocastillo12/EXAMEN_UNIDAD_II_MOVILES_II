import 'dart:math' show pi;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'selection_pill_surface.dart';
import 'loading_shimmer.dart';

enum FilterPanelPlacement { below, atOrigin }

/// Anchored filter disclosure that preserves the surrounding content layout.
class FilterExpansion<T> extends StatefulWidget {
  const FilterExpansion({
    required this.label,
    this.subtitle,
    required this.editorBuilder,
    required this.onApply,
    this.enabled = true,
    this.applying = false,
    this.icon = Icons.tune_rounded,
    this.panelWidth,
    this.alignPanelToEnd = false,
    this.compact = false,
    this.iconOnly = false,
    this.showLeadingIcon = true,
    this.placement = FilterPanelPlacement.below,
    super.key,
  });
  final String label;
  final String? subtitle;
  final Widget Function(BuildContext, ValueChanged<T>) editorBuilder;
  final ValueChanged<T> onApply;
  final bool enabled, applying;
  final IconData icon;
  final double? panelWidth;
  final bool alignPanelToEnd;
  final bool compact, showLeadingIcon, iconOnly;
  final FilterPanelPlacement placement;
  @override
  State<FilterExpansion<T>> createState() => _FilterExpansionState<T>();
}

class _FilterExpansionState<T> extends State<FilterExpansion<T>>
    with SingleTickerProviderStateMixin {
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  final _anchor = GlobalKey();
  late final _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    reverseDuration: const Duration(milliseconds: 320),
  );
  late final _progress = CurvedAnimation(
    parent: _motion,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInOutCubic,
  );
  bool _open = false;
  bool _closing = false;
  double _closeStart = 1, _closeMotionStart = 1;

  double get _exitFraction => !_closing || _closeMotionStart == 0
      ? 0
      : (1 - _motion.value / _closeMotionStart).clamp(0.0, 1.0);

  double get _surfaceProgress => _closing
      ? _closeStart * (1 - Curves.easeInOutCubic.transform(_exitFraction))
      : _progress.value;

  Future<void> _close() async {
    if (!_open || _closing) return;
    _closeStart = _progress.value;
    _closeMotionStart = _motion.value;
    setState(() => _closing = true);
    FocusScope.of(context).unfocus();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.value = 0;
    } else {
      try {
        await _motion.reverse().orCancel;
      } on TickerCanceled {
        return;
      }
    }
    if (!mounted) return;
    _portal.hide();
    setState(() {
      _open = false;
      _closing = false;
    });
  }

  void _toggle() {
    if (_open) {
      _close();
    } else {
      setState(() => _open = true);
      _portal.show();
      if (MediaQuery.disableAnimationsOf(context)) {
        _motion.value = 1;
      } else {
        _motion.forward(from: 0);
      }
    }
  }

  @override
  void didUpdateWidget(covariant FilterExpansion<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) _close();
  }

  void _apply(T value) {
    if (!_open || _closing || !widget.enabled) return;
    _close();
    widget.onApply(value);
  }

  @override
  void dispose() {
    _progress.dispose();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_open,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _close();
    },
    child: OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _overlay,
      child: CompositedTransformTarget(
        key: _anchor,
        link: _link,
        child: LoadingShimmer(
          isLoading: widget.applying,
          loadingLabel: 'Aplicando filtros',
          radius: 32,
          child: AnimatedBuilder(
            animation: _progress,
            builder: (context, child) {
              final progress = _surfaceProgress;
              final foreground = Color.lerp(
                SelectionPillSurface.selected,
                Colors.white,
                progress,
              )!;
              final title = Text(
                widget.label,
                maxLines: widget.subtitle == null ? null : 1,
                overflow: widget.subtitle == null
                    ? null
                    : TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              );
              final label = widget.subtitle == null
                  ? title
                  : Tooltip(
                      message: '${widget.label} · ${widget.subtitle}',
                      child: Flex(
                        direction: widget.compact
                            ? Axis.horizontal
                            : Axis.vertical,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.compact) Flexible(child: title) else title,
                          if (widget.compact) const SizedBox(width: 8),
                          Text(
                            widget.subtitle!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: foreground),
                          ),
                        ],
                      ),
                    );
              final arrow = Transform.rotate(
                angle: -pi * progress,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: widget.compact ? 18 : 24,
                  color: foreground,
                ),
              );
              final trigger = SelectionPillSurface(
                padding: widget.compact
                    ? EdgeInsets.zero
                    : const EdgeInsets.all(6),
                child: Material(
                  // Follow the shared timeline without a second implicit animation.
                  animationDuration: Duration.zero,
                  color: Color.lerp(
                    SelectionPillSurface.background,
                    SelectionPillSurface.selected,
                    progress,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    onTap: widget.enabled ? _toggle : null,
                    borderRadius: BorderRadius.circular(26),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.compact ? 8 : 16,
                          vertical: widget.compact ? 6 : 12,
                        ),
                        child: widget.iconOnly
                            ? Center(
                                child: Icon(
                                  widget.icon,
                                  size: 20,
                                  color: foreground,
                                ),
                              )
                            : !widget.showLeadingIcon && !widget.compact
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  label,
                                  const SizedBox(height: 4),
                                  arrow,
                                ],
                              )
                            : Row(
                                children: [
                                  if (widget.showLeadingIcon) ...[
                                    SizedBox(
                                      width: widget.compact ? 18 : 24,
                                      child: Icon(
                                        widget.icon,
                                        size: widget.compact ? 18 : 20,
                                        color: foreground,
                                      ),
                                    ),
                                    SizedBox(width: widget.compact ? 6 : 10),
                                  ],
                                  Expanded(child: label),
                                  SizedBox(width: widget.compact ? 6 : 10),
                                  arrow,
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              );
              return widget.iconOnly
                  ? Tooltip(
                      message: widget.label,
                      excludeFromSemantics: true,
                      child: Semantics(
                        label: widget.label,
                        button: true,
                        enabled: widget.enabled,
                        expanded: _open,
                        child: trigger,
                      ),
                    )
                  : trigger;
            },
          ),
        ),
      ),
    ),
  );

  Widget _overlay(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final box = _anchor.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return const SizedBox.shrink();
      final overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      final origin = box.localToGlobal(Offset.zero, ancestor: overlay);
      final sourceRect = origin & box.size;
      final atOrigin = widget.placement == FilterPanelPlacement.atOrigin;
      final media = MediaQuery.of(context);
      final panelTop = atOrigin
          ? sourceRect.top.clamp(media.padding.top + 8, constraints.maxHeight)
          : sourceRect.bottom + 8;
      final inset = media.viewInsets.bottom > media.padding.bottom
          ? media.viewInsets.bottom
          : media.padding.bottom;
      final height = (constraints.maxHeight - panelTop - inset - 12).clamp(
        0.0,
        constraints.maxHeight,
      );
      return AnimatedBuilder(
        animation: _progress,
        child: SizedBox(
          width: widget.panelWidth ?? box.size.width,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height),
            child: Material(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(28),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                primary: false,
                padding: const EdgeInsets.all(16),
                child: widget.editorBuilder(context, _apply),
              ),
            ),
          ),
        ),
        builder: (context, panel) {
          final progress = _surfaceProgress;
          // Let the contraction read before fading the panel away. Capture the
          // opening position so reversing midway never jumps to a fully open panel.
          final contraction = _closing
              ? _closeStart * (1 - Curves.easeInCubic.transform(_exitFraction))
              : progress;
          final opacity = _closing
              ? _closeStart *
                    (1 -
                        const Interval(
                          .22,
                          1,
                          curve: Curves.easeInCubic,
                        ).transform(_exitFraction))
              : progress;
          return Stack(
            children: [
              Positioned.fill(
                child: ClipPath(
                  clipper: _FilterBackdropClipper(
                    atOrigin ? Rect.zero : sourceRect,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 16 * progress,
                      sigmaY: 16 * progress,
                    ),
                    child: Semantics(
                      label: 'Cerrar filtros',
                      button: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _close,
                        child: ColoredBox(
                          color: Colors.black.withValues(alpha: .28 * progress),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: CompositedTransformFollower(
                  link: _link,
                  showWhenUnlinked: false,
                  targetAnchor: atOrigin
                      ? (widget.alignPanelToEnd
                            ? Alignment.topRight
                            : Alignment.topLeft)
                      : (widget.alignPanelToEnd
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft),
                  followerAnchor: widget.alignPanelToEnd
                      ? Alignment.topRight
                      : Alignment.topLeft,
                  offset: Offset(0, atOrigin ? panelTop - sourceRect.top : 8),
                  child: IgnorePointer(
                    ignoring: _closing,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          _closing
                              ? -8 *
                                    (1 -
                                        contraction /
                                            (_closeStart == 0
                                                ? 1
                                                : _closeStart))
                              : 0,
                        ),
                        child: Transform.scale(
                          alignment: Alignment.topCenter,
                          scaleX: .94 + .06 * contraction,
                          scaleY: .86 + .14 * contraction,
                          child: panel,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Leaves the actual trigger visible and interactive through the backdrop.
class _FilterBackdropClipper extends CustomClipper<Path> {
  const _FilterBackdropClipper(this.source);
  final Rect source;

  @override
  Path getClip(Size size) => Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(Offset.zero & size)
    ..addRRect(RRect.fromRectAndRadius(source, const Radius.circular(32)));

  @override
  bool shouldReclip(_FilterBackdropClipper oldClipper) =>
      source != oldClipper.source;
}
