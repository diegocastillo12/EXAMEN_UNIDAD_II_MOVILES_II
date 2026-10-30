import '../models/search_place_dto.dart';
import '../../domain/cancellation/place_search_cancellation.dart';

abstract interface class PlaceSearchDataSource {
  Future<List<SearchPlaceDto>> search(
    String query, {
    bool citiesOnly = false,
    PlaceSearchCancellation? cancellation,
  });
}
