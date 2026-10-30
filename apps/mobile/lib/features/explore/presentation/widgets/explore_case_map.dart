import 'dart:math' as math;
import 'explore_map_pins.dart';
import 'explore_map_case_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/config/map_config.dart';
import '../../../../core/presentation/widgets/map_attribution.dart';
import '../../../../core/presentation/widgets/zone_map_picker.dart';
import '../../../../core/presentation/widgets/collection_empty_state.dart';
import '../../domain/entities/explore_page.dart';
import '../../domain/entities/explore_query.dart';

/// Full viewport map with the selected public case in its bottom sheet.
class ExploreCaseMap extends StatefulWidget {
  const ExploreCaseMap({
    required this.items,
    required this.query,
    required this.onOpen,
    this.trailing = const [],
    this.emptyMessage,
    this.createTileProvider,
    this.previewBuilder,
    super.key,
  });
  final List<ExploreCase> items;
  final ExploreQuery query;
  final void Function(ExploreCase, BuildContext)? onOpen;
  final List<Widget> trailing;
  final String? emptyMessage;
  final TileProvider Function()? createTileProvider;
  final Widget Function(ExploreCase, ValueChanged<double>)? previewBuilder;
  @override
  State<ExploreCaseMap> createState() => _ExploreCaseMapState();
}

class _ExploreCaseMapState extends State<ExploreCaseMap>
    with TickerProviderStateMixin {
  double _minimumExtent = .22;
  double _summaryHeight = 172;

  void _recordSummaryHeight(double height) {
    if (!mounted || (_summaryHeight - height).abs() < .5) return;
    setState(() => _summaryHeight = height);
  }

  late final _pullOffset = AnimationController.unbounded(vsync: this);
  late final _sheetMotion = AnimationController.unbounded(vsync: this)
    ..addListener(_applySheetMotion);

  void _applySheetMotion() {
    if (_sheet.isAttached) {
      _sheet.jumpTo(_sheetMotion.value.clamp(_minimumExtent, .9));
    }
  }

  int? _sheetPointer;
  VelocityTracker? _dragVelocity;
  double? _dragStartExtent;
  Offset? _dragOrigin;
  bool _dragMoved = false;
  int _settleRequest = 0;

  void _beginSheetDrag(PointerDownEvent event) {
    if (_sheetPointer != null) return;
    _settleRequest++;
    // Hold the exact position on contact, even before the drag recognizer wins.
    _sheetMotion.stop();
    _sheetPointer = event.pointer;
    _dragStartExtent = _sheet.isAttached ? _sheet.size : null;
    _dragOrigin = event.position;
    _dragMoved = false;
    _dragVelocity = VelocityTracker.withKind(event.kind)
      ..addPosition(event.timeStamp, event.position);
    _pullOffset.stop();
  }

  void _trackSheetDrag(PointerMoveEvent event) {
    if (event.pointer == _sheetPointer) {
      _dragVelocity?.addPosition(event.timeStamp, event.position);
      if (_dragOrigin != null && (event.position - _dragOrigin!).distance > 8) {
        _dragMoved = true;
      }
    }
  }

  void _endSheetDrag(PointerEvent event, {bool cancelled = false}) {
    if (event.pointer != _sheetPointer) return;
    _dragVelocity?.addPosition(event.timeStamp, event.position);
    final velocity = cancelled
        ? 0.0
        : _dragVelocity?.getVelocity().pixelsPerSecond.dy ?? 0.0;
    final start = _dragStartExtent;
    final moved = _dragMoved;
    _sheetPointer = null;
    _dragVelocity = null;
    _dragStartExtent = null;
    _dragOrigin = null;
    _dragMoved = false;
    final request = ++_settleRequest;
    // Release the pointer before replacing the native linear settlement.
    // A new touch or programmatic movement invalidates this request.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || request != _settleRequest || !_sheet.isAttached) return;
      _releasePull();
      if (!moved || start == null || (_sheet.size - start).abs() < .002) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _sheet.jumpTo(_sheet.size);
        return;
      }
      if ((_summaryScroll?.hasClients ?? false) && _summaryScroll!.offset > 1) {
        return;
      }
      final current = _sheet.size;
      final stops = [_minimumExtent, if (_minimumExtent < .5) .5, .9];
      final double target;
      if (velocity < -350) {
        target =
            stops.where((size) => size > current + .005).firstOrNull ??
            stops.last;
      } else if (velocity > 350) {
        target =
            stops.reversed.where((size) => size < current - .005).firstOrNull ??
            stops.first;
      } else {
        target = stops.reduce(
          (a, b) => (a - current).abs() <= (b - current).abs() ? a : b,
        );
      }
      _moveSheet(target, velocity: -velocity / _sheet.sizeToPixels(1));
    });
  }

  void _releasePull() {
    if (_pullOffset.value <= 0) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _pullOffset.value = 0;
      return;
    }
    _pullOffset.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 190, damping: 28),
        _pullOffset.value,
        0,
        0,
        tolerance: const Tolerance(distance: .01, velocity: .01),
      ),
    );
  }

  bool _handleScroll(ScrollNotification notification) {
    if (MediaQuery.disableAnimationsOf(context)) return false;
    if (notification is OverscrollNotification &&
        notification.dragDetails != null &&
        notification.overscroll < 0 &&
        _sheet.isAttached &&
        _sheet.size <= _minimumExtent + .0001) {
      _pullOffset.stop();
      _pullOffset.value = (_pullOffset.value - notification.overscroll * .2)
          .clamp(0.0, 18.0);
    } else if (notification is ScrollEndNotification && _pullOffset.value > 0) {
      _releasePull();
    }
    return false;
  }

  final _sheet = DraggableScrollableController();
  final _map = MapController();
  String? _selectedCaseKey;
  ScrollController? _summaryScroll;

  void _resetSummaryScroll() {
    final scroll = _summaryScroll;
    if (scroll != null && scroll.hasClients) scroll.jumpTo(0);
  }

  void _moveSheet(double size, {double velocity = 0}) {
    if (!_sheet.isAttached) return;
    _settleRequest++;
    _sheetMotion.stop();
    size = size.clamp(_minimumExtent, .9);
    if (MediaQuery.disableAnimationsOf(context)) {
      _sheet.jumpTo(size);
    } else {
      final current = _sheet.size;
      // Stop native ballistic motion once, then keep the release velocity.
      // A damped spring avoids restarting slowly after a moving finger.
      _sheet.jumpTo(current);
      _sheetMotion.value = current;
      _sheetMotion.animateWith(
        SpringSimulation(
          const SpringDescription(mass: 1, stiffness: 260, damping: 34),
          current,
          size,
          velocity.clamp(-3.0, 3.0),
          tolerance: const Tolerance(distance: .0001, velocity: .0001),
          snapToEnd: true,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant ExploreCaseMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.query, widget.query)) {
      _selectedCaseKey = null;
      final query = widget.query;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && identical(widget.query, query)) _moveSheet(.5);
      });
    }
  }

  @override
  void dispose() {
    _settleRequest++;
    _sheetMotion.dispose();
    _pullOffset.dispose();
    _sheet.dispose();
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items
        .where((item) => item.key == _selectedCaseKey)
        .firstOrNull;
    final media = MediaQuery.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final minimum = item == null
            ? .22
            : ((32 + _summaryHeight + media.padding.bottom + 12) /
                      constraints.maxHeight)
                  .clamp(.18, .85);
        _minimumExtent = minimum;
        void select(ExploreCase selected) {
          final selectedExtent = math.max(
            .5,
            ((32 + _summaryHeight + media.padding.bottom + 12) /
                    constraints.maxHeight)
                .clamp(.18, .85),
          );
          setState(() => _selectedCaseKey = selected.key);
          _resetSummaryScroll();
          _moveSheet(.5);
          _map.fitCamera(
            CameraFit.coordinates(
              coordinates: [LatLng(selected.latitude, selected.longitude)],
              padding: EdgeInsets.fromLTRB(
                24,
                media.padding.top + 24,
                24,
                math.min(
                  constraints.maxHeight - media.padding.top - 24,
                  constraints.maxHeight * selectedExtent + 72,
                ),
              ),
              maxZoom: math.max(_map.camera.zoom, 15),
            ),
          );
        }

        return Stack(
          children: [
            if (widget.query.latitude != null && widget.query.longitude != null)
              Positioned.fill(
                child: ZoneMapPicker(
                  controller: _map,
                  latitude: widget.query.latitude,
                  longitude: widget.query.longitude,
                  radiusMeters: widget.query.radiusMeters ?? 15000,
                  onSelect: null,
                  onMapTap: () => setState(() => _selectedCaseKey = null),
                  readOnly: true,
                  readOnlyNavigation: true,
                  fitRadius: true,
                  showCenterMarker: false,
                  showRadius: false,
                  showAttribution: false,
                  createTileProvider: widget.createTileProvider,
                  height: constraints.maxHeight,
                  borderRadius: 0,
                  cameraPadding: EdgeInsets.fromLTRB(
                    24,
                    media.padding.top + 76,
                    24,
                    constraints.maxHeight * .5 + 16,
                  ),
                  markerLayer: ExploreMapPins(
                    items: widget.items,
                    selectedKey: _selectedCaseKey,
                    onSelect: select,
                  ),
                ),
              )
            else
              const Positioned.fill(
                child: ColoredBox(color: Color(0xFFF5F5F7)),
              ),
            DraggableScrollableSheet(
              controller: _sheet,
              initialChildSize: math.max(.5, minimum),
              minChildSize: minimum,
              maxChildSize: .9,
              snap: false,
              shouldCloseOnMinExtent: false,
              builder: (context, scroll) {
                _summaryScroll = scroll;
                return AnimatedBuilder(
                  animation: _pullOffset,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _pullOffset.value),
                    child: child,
                  ),
                  child: Listener(
                    onPointerDown: _beginSheetDrag,
                    onPointerMove: _trackSheetDrag,
                    onPointerUp: _endSheetDrag,
                    onPointerCancel: (event) =>
                        _endSheetDrag(event, cancelled: true),
                    child: Material(
                      key: const ValueKey('map-case-surface'),
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _handleScroll,
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: media.padding.bottom + 12,
                          ),
                          child: CustomScrollView(
                            controller: scroll,
                            slivers: [
                              SliverPersistentHeader(
                                pinned: true,
                                delegate: _MapSheetHandle(
                                  onExpand: () => _moveSheet(.9),
                                  onCollapse: () {
                                    _resetSummaryScroll();
                                    _moveSheet(minimum);
                                  },
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (item == null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                        ),
                                        child: CollectionEmptyState(
                                          title: widget.items.isNotEmpty
                                              ? 'Selecciona un pin'
                                              : widget.emptyMessage != null
                                              ? 'Explora los casos cercanos'
                                              : 'No encontramos casos',
                                          description: widget.items.isNotEmpty
                                              ? 'Selecciona un pin para ver el resumen del caso.'
                                              : widget.emptyMessage ??
                                                    'Prueba con otra ubicación o ajusta los filtros de búsqueda.',
                                        ),
                                      )
                                    else
                                      widget.previewBuilder?.call(
                                            item,
                                            _recordSummaryHeight,
                                          ) ??
                                          ExploreMapPreviewContent(
                                            item: item,
                                            scrollable: false,
                                            onSummaryHeight:
                                                _recordSummaryHeight,
                                            onOpen: widget.onOpen == null
                                                ? null
                                                : (source) => widget.onOpen!(
                                                    item,
                                                    source,
                                                  ),
                                          ),
                                    ...widget.trailing,
                                    SizedBox(height: media.padding.bottom + 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (MapConfig.usesCarto &&
                widget.query.latitude != null &&
                widget.query.longitude != null)
              AnimatedBuilder(
                animation: Listenable.merge([_sheet, _pullOffset]),
                builder: (context, _) {
                  final extent = _sheet.isAttached
                      ? _sheet.size
                      : math.max(.5, minimum);
                  final panelTop =
                      constraints.maxHeight * (1 - extent) + _pullOffset.value;
                  if (panelTop < media.padding.top + 28) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    left: 84,
                    right: 8,
                    bottom:
                        constraints.maxHeight * extent - _pullOffset.value - 8,
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: MapAttribution(compact: true),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _MapSheetHandle extends SliverPersistentHeaderDelegate {
  _MapSheetHandle({required this.onExpand, required this.onCollapse});
  final VoidCallback onExpand, onCollapse;
  @override
  double get minExtent => 32;
  @override
  double get maxExtent => 32;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Material(
    color: Colors.white,
    child: Semantics(
      label: 'Desliza para ampliar o reducir el resumen',
      onIncrease: onExpand,
      onDecrease: onCollapse,
      child: Center(
        child: Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5EA),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    ),
  );
  @override
  bool shouldRebuild(covariant _MapSheetHandle oldDelegate) => true;
}
