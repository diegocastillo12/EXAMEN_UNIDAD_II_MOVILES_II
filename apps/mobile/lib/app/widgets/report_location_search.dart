import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/places/presentation/view_models/place_search_view_model.dart';
import '../../features/places/presentation/widgets/place_search_fields.dart';

/// App composes places without coupling report presentation to another feature.
Widget buildReportLocationSearch(
  bool enabled,
  void Function(double, double) onSelect,
) => ProviderScope(
  overrides: [
    placeSearchViewModelProvider.overrideWith(
      () => PlaceSearchViewModel(false),
    ),
  ],
  child: PlaceSearchFields(
    enabled: enabled,
    onSelect: (place) => onSelect(place.latitude, place.longitude),
  ),
);
