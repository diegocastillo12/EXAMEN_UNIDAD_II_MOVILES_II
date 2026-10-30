import '../../domain/entities/search_place.dart';
import '../../domain/failures/place_search_failure.dart';
import '../../domain/repositories/place_search_repository.dart';
import '../../domain/cancellation/place_search_cancellation.dart';

class UnavailablePlaceSearchRepository implements PlaceSearchRepository {
  const UnavailablePlaceSearchRepository();
  @override
  Future<List<SearchPlace>> search(
    String query, {
    bool citiesOnly = false,
    PlaceSearchCancellation? cancellation,
  }) async =>
      throw const PlaceSearchFailure(PlaceSearchFailureKind.unavailable);
}
