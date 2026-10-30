import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/filter_expansion.dart';
import '../../domain/entities/explore_query.dart';
import '../../../places/domain/entities/search_place.dart';
import '../state/explore_filter_selection.dart';
import 'explore_filter_editor.dart';
export 'explore_filter_editor.dart' show LocationSearchBuilder;

class ExploreFilters extends StatefulWidget {
  const ExploreFilters({
    required this.enabled,
    this.applying = false,
    this.query = const ExploreQuery(radiusMeters: 15000),
    this.onUseCurrentLocation,
    this.locationSearchBuilder,
    this.locationLabel = '',
    this.centerName = '',
    required this.onApply,
    super.key,
  });
  final bool enabled, applying;
  final ExploreQuery query;
  final Future<SearchPlace?> Function()? onUseCurrentLocation;
  final String locationLabel, centerName;
  final LocationSearchBuilder? locationSearchBuilder;
  final ValueChanged<ExploreFilterSelection> onApply;
  @override
  State<ExploreFilters> createState() => _ExploreFiltersState();
}

class _ExploreFiltersState extends State<ExploreFilters> {
  late ExploreFilterSelection _selection = ExploreFilterSelection.fromQuery(
    widget.query,
    label: widget.locationLabel,
    centerName: widget.centerName,
  );

  @override
  void didUpdateWidget(covariant ExploreFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.query, oldWidget.query) ||
        widget.locationLabel != oldWidget.locationLabel ||
        widget.centerName != oldWidget.centerName) {
      _selection = ExploreFilterSelection.fromQuery(
        widget.query,
        label: widget.locationLabel,
        centerName: widget.centerName,
      );
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final showLeadingIcons =
          constraints.maxWidth >= 330 &&
          MediaQuery.textScalerOf(context).scale(14) <= 16;
      final filters = FilterExpansion<ExploreFilterSelection>(
        label: 'Filtrar casos',
        enabled: widget.enabled,
        applying: widget.applying,
        panelWidth: constraints.maxWidth,
        compact: true,
        iconOnly: true,
        alignPanelToEnd: true,
        editorBuilder: (context, confirm) =>
            ExploreFilterEditor(initial: _selection, onConfirm: confirm),
        onApply: _apply,
      );
      final zone = FilterExpansion<ExploreFilterSelection>(
        key: const ValueKey('explore-location-filter'),
        label: _selection.lat == null
            ? 'Ubicación'
            : _selection.centerName.isEmpty
            ? 'Ubicación actual'
            : _selection.centerName,
        subtitle: _selection.lat == null
            ? null
            : '${_selection.radius ~/ 1000} km',
        placement: FilterPanelPlacement.atOrigin,
        icon: Icons.location_on_outlined,
        enabled: widget.enabled,
        applying: widget.applying,
        panelWidth: constraints.maxWidth,
        compact: true,
        showLeadingIcon: showLeadingIcons,
        editorBuilder: (context, confirm) => ExploreFilterEditor(
          initial: _selection,
          zoneOnly: true,
          onUseCurrentLocation: widget.onUseCurrentLocation,
          locationSearchBuilder: widget.locationSearchBuilder,
          onConfirm: confirm,
        ),
        onApply: _apply,
      );
      return Row(
        children: [
          Expanded(child: zone),
          const SizedBox(width: 8),
          SizedBox.square(dimension: 48, child: filters),
        ],
      );
    },
  );

  void _apply(ExploreFilterSelection value) {
    setState(() => _selection = value);
    widget.onApply(value);
  }
}
