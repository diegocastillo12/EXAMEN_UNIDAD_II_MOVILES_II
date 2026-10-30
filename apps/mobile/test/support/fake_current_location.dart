import 'package:flutter_application_entrehuellas/features/places/domain/entities/search_place.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/repositories/current_location_repository.dart';

class FakeCurrentLocation implements CurrentLocationRepository {
  const FakeCurrentLocation();
  @override
  Future<SearchPlace> locate() async => const SearchPlace(
    label: 'Ubicación actual',
    latitude: -12.05,
    longitude: -77.05,
  );
}
