import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/explore_page.dart';
import 'explore_map_pin.dart';

/// Separates touch targets in screen pixels without altering public locations.
class ExploreMapPins extends StatelessWidget {
  const ExploreMapPins({
    required this.items,
    required this.selectedKey,
    required this.onSelect,
    super.key,
  });

  final List<ExploreCase> items;
  final String? selectedKey;
  final ValueChanged<ExploreCase> onSelect;

  static const _pinSize = 48.0;
  static const _spacing = 56.0;

  // Closest positions first, preferring a slight horizontal separation.
  Iterable<Offset> _offsets() sync* {
    yield Offset.zero;
    for (var ring = 1; ; ring++) {
      final distance = ring * _spacing;
      yield Offset(distance, 0);
      yield Offset(-distance, 0);
      yield Offset(0, distance);
      yield Offset(0, -distance);
      for (var x = -ring; x <= ring; x++) {
        for (var y = -ring; y <= ring; y++) {
          if (x == 0 || y == 0) continue;
          if (x.abs() == ring || y.abs() == ring) {
            yield Offset(x * _spacing, y * _spacing);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final occupied = <Offset>[];
    final pins = <Widget>[];
    // Stable identity order avoids changing placement on selection or reorder.
    final ordered = [...items]..sort((a, b) => a.key.compareTo(b.key));
    for (final item in ordered) {
      final anchor = camera.latLngToScreenOffset(
        LatLng(item.latitude, item.longitude),
      );
      final center = _offsets()
          .map((offset) => anchor + offset)
          .firstWhere(
            (candidate) => occupied.every(
              (other) =>
                  (candidate.dx - other.dx).abs() >= _spacing ||
                  (candidate.dy - other.dy).abs() >= _spacing,
            ),
          );
      occupied.add(center);
      final name = item.name.isEmpty ? 'Sin nombre' : item.name;
      pins.add(
        Positioned(
          key: ValueKey(('map-pin', item.key)),
          left: center.dx - _pinSize / 2,
          top: center.dy - _pinSize / 2,
          width: _pinSize,
          height: _pinSize,
          child: Semantics(
            button: true,
            selected: item.key == selectedKey,
            label: '$name. Seleccionar caso en ubicación aproximada',
            child: Tooltip(
              message: 'Seleccionar caso: $name',
              child: ExploreMapPin(
                selected: item.key == selectedKey,
                onTap: () => onSelect(item),
              ),
            ),
          ),
        ),
      );
    }
    return Stack(children: pins);
  }
}
