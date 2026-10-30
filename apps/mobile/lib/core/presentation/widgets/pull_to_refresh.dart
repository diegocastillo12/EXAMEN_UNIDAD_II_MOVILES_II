import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'glass_surface.dart';

/// Edge-only pull gesture with a refresh glyph that follows and retracts.
class PullToRefresh extends StatefulWidget {
  const PullToRefresh({
    required this.child,
    this.onRefresh,
    this.enabled = true,
    this.indicatorTop = 8,
    super.key,
  });
  final Widget child;
  final Future<void> Function()? onRefresh;
  final bool enabled;
  final double indicatorTop;

  @override
  State<PullToRefresh> createState() => _PullToRefreshState();
}

class _PullToRefreshState extends State<PullToRefresh>
    with TickerProviderStateMixin {
  final _binding = _RefreshBinding();
  late final _travel = AnimationController.unbounded(vsync: this);
  late final _rotation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _motion = Listenable.merge([_travel, _rotation]);
  RefreshIndicatorStatus? _status;
  bool _busy = false;
  bool _reduced = false;
  double _distance = 0;
  double _travelTarget = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced) {
      _rotation.stop();
      _travel.stop();
      if (_travelTarget >= 0) _travel.value = _travelTarget;
    } else if (_busy && !_rotation.isAnimating) {
      _rotation.repeat();
    }
  }

  @override
  void dispose() {
    _travel.dispose();
    _rotation.dispose();
    super.dispose();
  }

  void _moveTo(double target) {
    if (_travelTarget == target) return;
    _travelTarget = target;
    if (_reduced) {
      _travel.value = target;
    } else {
      _travel.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _statusChanged(RefreshIndicatorStatus? status) {
    if (!mounted) return;
    setState(() => _status = status);
    if (status == RefreshIndicatorStatus.drag) {
      _distance = _travel.value * 2;
      _travel.stop();
      _travelTarget = -1;
    } else if (status == RefreshIndicatorStatus.snap ||
        status == RefreshIndicatorStatus.refresh) {
      _moveTo(64);
    } else if (status == RefreshIndicatorStatus.done ||
        status == RefreshIndicatorStatus.canceled ||
        status == null) {
      _rotation.stop();
      _moveTo(0);
    }
  }

  bool _trackPull(ScrollNotification notification) {
    if (notification.depth != 0 ||
        notification.metrics.axisDirection != AxisDirection.down ||
        !_enabled ||
        (_status != RefreshIndicatorStatus.drag &&
            _status != RefreshIndicatorStatus.armed)) {
      return false;
    }
    double? delta;
    if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null) {
      delta = notification.scrollDelta;
    } else if (notification is OverscrollNotification &&
        notification.dragDetails != null) {
      delta = notification.overscroll;
    }
    if (delta != null) {
      _distance = (_distance - delta).clamp(0.0, 224.0);
      _travelTarget = -1;
      _travel.value = _distance * .5;
    }
    return false;
  }

  bool get _enabled =>
      widget.enabled &&
      !_busy &&
      (widget.onRefresh != null || _binding.enabled);

  Future<void> _refresh() async {
    if (!_enabled) return;
    final refresh = widget.onRefresh ?? _binding.refresh;
    if (refresh == null) return;
    _busy = true;
    // Flutter 3.35 noSpinner does not notify its transition into refresh.
    _statusChanged(RefreshIndicatorStatus.refresh);
    if (!_reduced) _rotation.repeat();
    try {
      await refresh();
    } catch (_) {
      // The owning ViewModel exposes its failure and retry through shared feedback.
    } finally {
      _busy = false;
      if (mounted) {
        _rotation.stop();
        _statusChanged(RefreshIndicatorStatus.done);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final refreshing = _status == RefreshIndicatorStatus.refresh;
    final armed =
        _status == RefreshIndicatorStatus.armed ||
        _status == RefreshIndicatorStatus.snap ||
        refreshing;
    return _RefreshScope(
      binding: _binding,
      child: Semantics(
        customSemanticsActions: widget.onRefresh != null && _enabled
            ? {
                const CustomSemanticsAction(label: 'Actualizar contenido'):
                    _refresh,
              }
            : null,
        child: Stack(
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: [
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(overscroll: false),
              child: NotificationListener<ScrollNotification>(
                onNotification: _trackPull,
                child: RefreshIndicator.noSpinner(
                  onRefresh: _refresh,
                  notificationPredicate: (notification) =>
                      notification.depth == 0 &&
                      notification.metrics.axis == Axis.vertical &&
                      (_enabled || _busy),
                  onStatusChange: _statusChanged,
                  child: widget.child,
                ),
              ),
            ),
            Positioned(
              top: widget.indicatorTop - 52,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _motion,
                  builder: (context, child) {
                    final offset = _travel.value.clamp(0.0, 112.0);
                    return ExcludeSemantics(
                      excluding: offset < 1,
                      child: Transform.translate(
                        offset: Offset(0, offset),
                        child: Opacity(
                          opacity: (offset / 40).clamp(0.0, 1.0),
                          child: Center(
                            child: Semantics(
                              liveRegion: true,
                              label: refreshing
                                  ? 'Actualizando contenido'
                                  : armed
                                  ? 'Suelta para actualizar'
                                  : 'Jala para actualizar',
                              child: GlassSurface(
                                radius: 26,
                                child: SizedBox.square(
                                  dimension: 52,
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: _reduced
                                          ? 0
                                          : (offset / 64 * .75 +
                                                    _rotation.value) *
                                                2 *
                                                pi,
                                      child: const Icon(
                                        Icons.refresh_rounded,
                                        size: 28,
                                        color: Color(0xFF111111),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lets feature content own its refresh operation inside an enclosing scroll.
/// Registration carries callbacks only; core never imports feature providers.
class PullToRefreshTarget extends StatefulWidget {
  const PullToRefreshTarget({
    required this.onRefresh,
    required this.child,
    this.enabled = true,
    super.key,
  });
  final Future<void> Function() onRefresh;
  final Widget child;
  final bool enabled;
  @override
  State<PullToRefreshTarget> createState() => _PullToRefreshTargetState();
}

class _PullToRefreshTargetState extends State<PullToRefreshTarget> {
  _RefreshBinding? _binding;
  bool _refreshing = false;

  Future<void> _refresh() async {
    if (!mounted || !widget.enabled || _refreshing) return;
    _refreshing = true;
    try {
      await widget.onRefresh();
    } catch (_) {
      // Feature feedback remains responsible for errors and retry.
    } finally {
      _refreshing = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _binding?.remove(this);
    _binding = context
        .dependOnInheritedWidgetOfExactType<_RefreshScope>()
        ?.binding;
    _binding?.register(this, _refresh, () => widget.enabled && !_refreshing);
  }

  @override
  void dispose() {
    _binding?.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    customSemanticsActions: widget.enabled
        ? {const CustomSemanticsAction(label: 'Actualizar contenido'): _refresh}
        : null,
    child: widget.child,
  );
}

class _RefreshBinding {
  Object? _owner;
  Future<void> Function()? refresh;
  bool Function()? _enabled;
  bool get enabled => _enabled?.call() ?? false;
  void register(
    Object owner,
    Future<void> Function() callback,
    bool Function() enabled,
  ) {
    _owner = owner;
    refresh = callback;
    _enabled = enabled;
  }

  void remove(Object owner) {
    if (!identical(_owner, owner)) return;
    _owner = null;
    refresh = null;
    _enabled = null;
  }
}

class _RefreshScope extends InheritedWidget {
  const _RefreshScope({required this.binding, required super.child});
  final _RefreshBinding binding;
  @override
  bool updateShouldNotify(_RefreshScope oldWidget) =>
      binding != oldWidget.binding;
}
