import '../../../places/domain/entities/search_place.dart';
import '../../domain/failures/explore_failure.dart';
import '../../domain/repositories/current_location_repository.dart';
import '../data_sources/device_location_source.dart';

class CurrentLocationRepositoryImpl implements CurrentLocationRepository {
  const CurrentLocationRepositoryImpl(this._source);
  final DeviceLocationSource _source;

  @override
  Future<SearchPlace> locate() async {
    try {
      final point = await _source.locate();
      return SearchPlace(
        label: 'Ubicación actual',
        latitude: point.latitude,
        longitude: point.longitude,
      );
    } catch (error) {
      throw ExploreFailure(switch (error) {
        DeviceLocationIssue.denied => ExploreFailureKind.locationDenied,
        DeviceLocationIssue.disabled => ExploreFailureKind.locationDisabled,
        _ => ExploreFailureKind.unavailable,
      });
    }
  }
}

class UnavailableCurrentLocationRepository
    implements CurrentLocationRepository {
  const UnavailableCurrentLocationRepository();
  @override
  Future<SearchPlace> locate() async =>
      throw const ExploreFailure(ExploreFailureKind.unavailable);
}
