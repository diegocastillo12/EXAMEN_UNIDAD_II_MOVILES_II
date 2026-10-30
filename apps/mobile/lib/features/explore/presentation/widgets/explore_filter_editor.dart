import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/filter_choice_group.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/zone_map_picker.dart';
import '../../../../core/presentation/widgets/shake_field.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../domain/entities/explore_query.dart';
import '../../../places/domain/entities/search_place.dart';
import '../state/explore_filter_selection.dart';

typedef LocationSearchBuilder =
    Widget Function(String label, ValueChanged<SearchPlace> onSelect);

class ExploreFilterEditor extends StatefulWidget {
  const ExploreFilterEditor({
    required this.initial,
    required this.onConfirm,
    this.zoneOnly = false,
    this.locationSearchBuilder,
    this.onUseCurrentLocation,
    this.allFilters = false,
    this.showMap = true,
    this.busy = false,
    this.applying = false,
    this.scrollController,
    this.headerSliver,
    this.onUseMapCenter,
    this.trailing = const [],
    super.key,
  });
  final bool zoneOnly;
  final LocationSearchBuilder? locationSearchBuilder;
  final Future<SearchPlace?> Function()? onUseCurrentLocation;
  final SearchPlace Function()? onUseMapCenter;
  final FutureOr<void> Function(ExploreFilterSelection) onConfirm;
  final bool allFilters, showMap, busy, applying;
  final ScrollController? scrollController;
  final Widget? headerSliver;
  final List<Widget> trailing;
  final ExploreFilterSelection initial;
  @override
  State<ExploreFilterEditor> createState() => _ExploreFilterEditorState();
}

class _ExploreFilterEditorState extends State<ExploreFilterEditor> {
  late ExploreKind _kind = widget.initial.kind;
  late ExploreSpecies _species = widget.initial.species;
  late ExploreStatus _status = widget.initial.status;
  late int _days = widget.initial.days, _radius = widget.initial.radius;
  int _shake = 0;
  late String _label = widget.initial.label;
  late String _centerName = widget.initial.centerName;
  late double? _lat = widget.initial.lat, _lon = widget.initial.lon;
  bool _invalid = false, _submitted = false;
  bool _locating = false;
  bool get _locked => _submitted || _locating || widget.busy;
  Future<void> _useCurrentLocation() async {
    if (_locked) return;
    setState(() => _locating = true);
    try {
      final place = await widget.onUseCurrentLocation!();
      if (mounted && place != null) {
        setState(() {
          _lat = place.latitude;
          _lon = place.longitude;
          _label = '';
          _centerName = 'Ubicación actual';
          _invalid = false;
        });
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  FilterChoice<T> option<T>(T value, String label) =>
      FilterChoice(value, label);
  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[..._fields(context), ...widget.trailing];
    final action = LoadingShimmer(
      isLoading: _submitted || widget.applying,
      loadingLabel: 'Aplicando filtros',
      child: FilledButton(
        style: primaryActionButtonStyle(context),
        onPressed: _locked ? null : _confirm,
        child: Text(
          widget.zoneOnly && !widget.allFilters
              ? 'Aplicar ubicación'
              : 'Aplicar filtros',
        ),
      ),
    );
    return ConfirmationToastHost(
      confirmed: _invalid,
      isError: true,
      noticeId: _shake,
      message: widget.showMap
          ? 'Selecciona una ubicación en el mapa para filtrar por distancia.'
          : 'Elige una ciudad o una ubicación antes de aplicar filtros.',
      child: widget.scrollController == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [...fields, const SizedBox(height: 16), action],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final sticky =
                    constraints.maxHeight >
                    MediaQuery.textScalerOf(context).scale(18) * 1.5 +
                        36 +
                        MediaQuery.paddingOf(context).bottom +
                        12 +
                        96;
                return Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        controller: widget.scrollController,
                        slivers: [
                          if (widget.headerSliver != null) widget.headerSliver!,
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ...fields,
                                  if (!sticky) ...[
                                    const SizedBox(height: 16),
                                    action,
                                    SizedBox(
                                      height:
                                          MediaQuery.paddingOf(context).bottom +
                                          12,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (sticky)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          MediaQuery.paddingOf(context).bottom + 12,
                        ),
                        child: SizedBox(width: double.infinity, child: action),
                      ),
                  ],
                );
              },
            ),
    );
  }

  List<Widget> _fields(BuildContext context) => [
    if (!widget.zoneOnly) ...[
      FilterChoiceGroup<ExploreKind>(
        label: 'Tipo',
        value: _kind,
        options: [
          option(ExploreKind.all, 'Todos'),
          option(ExploreKind.lost, 'Perdidas'),
          option(ExploreKind.found, 'Encontradas'),
          option(ExploreKind.sighting, 'Avistamientos'),
        ],
        onChanged: !_locked ? (v) => setState(() => _kind = v) : null,
      ),
      const SizedBox(height: 12),
      FilterChoiceGroup<ExploreSpecies>(
        label: 'Especie',
        value: _species,
        options: [
          option(ExploreSpecies.all, 'Todas'),
          option(ExploreSpecies.dog, 'Perro'),
          option(ExploreSpecies.cat, 'Gato'),
          option(ExploreSpecies.other, 'Otra especie'),
        ],
        onChanged: !_locked ? (v) => setState(() => _species = v) : null,
      ),
      const SizedBox(height: 12),
      FilterChoiceGroup<ExploreStatus>(
        label: 'Estado',
        value: _status,
        options: [
          option(ExploreStatus.active, 'Abiertos'),
          option(ExploreStatus.resolved, 'Resueltos'),
          option(ExploreStatus.all, 'Todos'),
        ],
        onChanged: !_locked ? (v) => setState(() => _status = v) : null,
      ),
      const SizedBox(height: 8),
      const Text(
        'Solo ves los casos resueltos de tu cuenta.',
        style: TextStyle(fontSize: 14, color: Color(0xFF6E6E73)),
      ),
      const SizedBox(height: 20),
      FilterChoiceGroup<int>(
        label: 'Fecha del suceso',
        value: _days,
        options: [
          option(0, 'Cualquier fecha'),
          option(1, 'Últimas 24 horas'),
          option(7, 'Últimos 7 días'),
          option(30, 'Últimos 30 días'),
          option(90, 'Últimos 90 días'),
        ],
        onChanged: !_locked ? (v) => setState(() => _days = v) : null,
      ),
    ],
    if (widget.zoneOnly || widget.allFilters) ...[
      if (widget.allFilters) const SizedBox(height: 20),
      const Text(
        'Ubicación de búsqueda',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      if (widget.onUseCurrentLocation != null)
        LoadingShimmer(
          isLoading: _locating,
          loadingLabel: 'Obteniendo ubicación actual',
          child: TextButton.icon(
            onPressed: _locked ? null : _useCurrentLocation,
            icon: const Icon(Icons.my_location_rounded),
            label: const Text('Usar mi ubicación actual'),
          ),
        ),
      if (widget.onUseMapCenter != null)
        TextButton.icon(
          onPressed: _locked
              ? null
              : () {
                  final place = widget.onUseMapCenter!();
                  setState(() {
                    _lat = place.latitude;
                    _lon = place.longitude;
                    _label = '';
                    _centerName = 'Punto del mapa';
                    _invalid = false;
                  });
                },
          icon: const Icon(Icons.center_focus_strong_rounded),
          label: const Text('Usar centro del mapa'),
        ),
      const SizedBox(height: 16),
      if (widget.locationSearchBuilder != null)
        IgnorePointer(
          ignoring: _locked,
          child: widget.locationSearchBuilder!(
            _label,
            (place) => setState(() {
              _lat = place.latitude;
              _lon = place.longitude;
              _label = place.label;
              _centerName = place.label;
              _invalid = false;
            }),
          ),
        ),
      const SizedBox(height: 12),
      Text(
        'Radio: ${(_radius / 1000).round()} km',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      Slider(
        value: (_radius / 1000).clamp(1, 50).toDouble(),
        min: 1,
        max: 50,
        divisions: 49,
        label: '${(_radius / 1000).round()} km',
        semanticFormatterCallback: (value) =>
            'Radio de búsqueda de ${value.round()} kilómetros',
        onChanged: _locked
            ? null
            : (value) => setState(() => _radius = value.round() * 1000),
      ),
      const SizedBox(height: 12),
      if (widget.showMap)
        ShakeField(
          errorId: _shake,
          hasError: _invalid,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: _invalid ? const Color(0xFFB53F48) : Colors.transparent,
                width: 3.5,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: IgnorePointer(
              ignoring: _locked,
              child: ZoneMapPicker(
                latitude: _lat,
                longitude: _lon,
                radiusMeters: _radius,
                fitRadius: true,
                onSelect: (lat, lon) => setState(() {
                  _lat = lat;
                  _lon = lon;
                  _label = '';
                  _centerName = 'Punto del mapa';
                  _invalid = false;
                }),
              ),
            ),
          ),
        ),
    ],
  ];

  Future<void> _confirm() async {
    if (_locked) return;
    if (_lat == null || _lon == null) {
      setState(() {
        _invalid = true;
        _shake++;
      });
      return;
    }
    setState(() => _submitted = true);
    try {
      await widget.onConfirm(
        ExploreFilterSelection(
          kind: _kind,
          species: _species,
          status: _status,
          days: _days,
          radius: _radius,
          lat: _lat,
          lon: _lon,
          label: _label,
          centerName: _centerName,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitted = false);
    }
  }
}
