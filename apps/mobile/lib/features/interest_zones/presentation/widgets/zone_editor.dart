import '../../../../core/presentation/widgets/app_input_decoration.dart';
import '../../../../core/presentation/widgets/validation_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/shake_field.dart';
import '../../domain/failures/zone_failure.dart';
import '../state/zone_view_state.dart';
import '../view_models/interest_zones_view_model.dart';
import 'zone_map_picker.dart';

class ZoneEditor extends ConsumerWidget {
  const ZoneEditor({required this.state, super.key});
  final ZoneViewState state;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = state.draft!;
    final vm = ref.read(interestZonesViewModelProvider.notifier);
    final invalidName = state.issue == ZoneFailureKind.invalidName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Nombra tu ubicación y toca el mapa para elegir su centro. Puedes moverlo y ampliar la vista.',
          style: TextStyle(fontSize: 16, color: Color(0xFF6E6E73), height: 1.4),
        ),
        const SizedBox(height: 20),
        ShakeField(
          errorId: state.errorId,
          hasError: invalidName,
          child: TextFormField(
            key: ValueKey('name-${draft.id}'),
            initialValue: draft.name,
            style: const TextStyle(fontSize: 16, color: Color(0xFF111111)),
            enabled: !state.busy,
            decoration: _decoration('Nombre de la ubicación', invalidName),
            onChanged: (name) => vm.edit(name: name),
          ),
        ),
        const SizedBox(height: 20),
        ValidationSurface(
          invalid: state.issue == ZoneFailureKind.invalidPoint,
          errorId: state.errorId,
          child: ZoneMapPicker(
            latitude: draft.latitude,
            longitude: draft.longitude,
            radiusMeters: draft.radiusMeters,
            onSelect: state.busy
                ? null
                : (lat, lng) => vm.edit(latitude: lat, longitude: lng),
          ),
        ),
        if (draft.latitude == null)
          const Text(
            'Aún no seleccionaste un punto.',
            style: TextStyle(color: Color(0xFF6E6E73)),
          ),

        const SizedBox(height: 12),
        Text(
          'Radio: ${(draft.radiusMeters / 1000).toStringAsFixed(1)} km',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
        ),
        Slider(
          value: draft.radiusMeters.toDouble(),
          min: 100,
          max: 50000,
          divisions: 499,
          semanticFormatterCallback: (value) =>
              '${(value / 1000).toStringAsFixed(1)} kilómetros',
          onChanged: state.busy
              ? null
              : (value) => vm.edit(radiusMeters: value.round()),
        ),
        ExpansionTile(
          title: const Text('Indicar coordenadas'),
          tilePadding: EdgeInsets.zero,
          children: [
            _CoordinateFields(
              key: ValueKey(
                'coordinates-${draft.id}-${draft.latitude}-${draft.longitude}',
              ),
              latitude: draft.latitude,
              longitude: draft.longitude,
              enabled: !state.busy,
              onSelect: vm.chooseCoordinates,
            ),
          ],
        ),
        const SizedBox(height: 20),
        LoadingShimmer(
          isLoading: state.busy,
          loadingLabel: 'Guardando ubicación',
          child: FilledButton(
            style: primaryActionButtonStyle(context, isLoading: state.busy),
            onPressed: state.busy ? null : vm.save,
            child: Text(
              draft.version == 0 ? 'Guardar ubicación' : 'Guardar cambios',
            ),
          ),
        ),
      ],
    );
  }
}

InputDecoration _decoration(String label, [bool invalid = false]) =>
    appInputDecoration(label, null, invalid: invalid);

class _CoordinateFields extends StatefulWidget {
  const _CoordinateFields({
    required this.latitude,
    required this.longitude,
    required this.enabled,
    required this.onSelect,
    super.key,
  });
  final double? latitude;
  final double? longitude;
  final bool enabled;
  final void Function(String, String) onSelect;
  @override
  State<_CoordinateFields> createState() => _CoordinateFieldsState();
}

class _CoordinateFieldsState extends State<_CoordinateFields> {
  late final lat = TextEditingController(
    text: widget.latitude?.toStringAsFixed(6),
  );
  late final lng = TextEditingController(
    text: widget.longitude?.toStringAsFixed(6),
  );
  @override
  void dispose() {
    lat.dispose();
    lng.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        controller: lat,
        enabled: widget.enabled,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        decoration: _decoration('Latitud'),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: lng,
        enabled: widget.enabled,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        decoration: _decoration('Longitud'),
      ),
      TextButton(
        onPressed: !widget.enabled
            ? null
            : () => widget.onSelect(lat.text, lng.text),
        child: const Text('Usar coordenadas'),
      ),
    ],
  );
}
