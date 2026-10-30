import '../entities/search_place.dart';
import '../cancellation/place_search_cancellation.dart';

abstract interface class PlaceSearchRepository {
  Future<List<SearchPlace>> search(
    String query, {
    bool citiesOnly = false,
    PlaceSearchCancellation? cancellation,
  });
}
