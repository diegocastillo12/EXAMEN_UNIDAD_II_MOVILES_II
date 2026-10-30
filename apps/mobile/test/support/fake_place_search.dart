import 'dart:async';
import 'package:flutter_application_entrehuellas/features/places/domain/entities/search_place.dart';
import 'package:flutter_application_entrehuellas/features/places/domain/repositories/place_search_repository.dart';
import 'package:flutter_application_entrehuellas/features/places/domain/cancellation/place_search_cancellation.dart';
import 'package:flutter_application_entrehuellas/features/places/domain/failures/place_search_failure.dart';

class FakePlaceSearch implements PlaceSearchRepository {
  final queries = <String>[];
  final cancellations = <PlaceSearchCancellation?>[];
  bool fail = false;
  Completer<List<SearchPlace>>? pending;
  static const place = SearchPlace(
    label: 'Miraflores, Lima, Perú',
    latitude: -12.12,
    longitude: -77.03,
  );
  @override
  Future<List<SearchPlace>> search(
    String query, {
    bool citiesOnly = false,
    PlaceSearchCancellation? cancellation,
  }) async {
    queries.add(query);
    cancellations.add(cancellation);
    if (fail) {
      throw const PlaceSearchFailure(PlaceSearchFailureKind.unavailable);
    }
    if (pending != null) return pending!.future;
    return const [place];
  }
}
