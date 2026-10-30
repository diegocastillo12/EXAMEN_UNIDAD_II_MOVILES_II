import '../../domain/entities/search_place.dart';
import '../../domain/failures/place_search_failure.dart';
import '../../domain/repositories/place_search_repository.dart';
import '../../domain/cancellation/place_search_cancellation.dart';
import '../data_sources/place_search_data_source.dart';

class PlaceSearchRepositoryImpl implements PlaceSearchRepository {
  PlaceSearchRepositoryImpl(this._source);
  final PlaceSearchDataSource _source;
  final _cache = <String, ({DateTime expires, List<SearchPlace> places})>{};
  @override
  Future<List<SearchPlace>> search(
    String query, {
    bool citiesOnly = false,
    PlaceSearchCancellation? cancellation,
  }) async {
    if (cancellation?.isCancelled == true) {
      throw const PlaceSearchFailure(PlaceSearchFailureKind.cancelled);
    }
    final key = '$citiesOnly:${query.toLowerCase()}';
    final cached = _cache[key];
    if (cached != null && DateTime.now().isBefore(cached.expires)) {
      return cached.places;
    }
    try {
      final rows = List<SearchPlace>.unmodifiable(
        (await _source.search(
          query,
          citiesOnly: citiesOnly,
          cancellation: cancellation,
        )).map((dto) => dto.toEntity()),
      );
      if (cancellation?.isCancelled == true) {
        throw const PlaceSearchFailure(PlaceSearchFailureKind.cancelled);
      }
      if (_cache.length >= 30) _cache.remove(_cache.keys.first);
      _cache[key] = (
        expires: DateTime.now().add(const Duration(minutes: 5)),
        places: rows,
      );
      return rows;
    } catch (_) {
      if (cancellation?.isCancelled == true) {
        throw const PlaceSearchFailure(PlaceSearchFailureKind.cancelled);
      }
      throw const PlaceSearchFailure(PlaceSearchFailureKind.unavailable);
    }
  }
}
