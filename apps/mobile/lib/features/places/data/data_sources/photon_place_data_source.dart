import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'place_search_data_source.dart';
import '../models/search_place_dto.dart';
import '../../domain/cancellation/place_search_cancellation.dart';

class PhotonPlaceDataSource implements PlaceSearchDataSource {
  const PhotonPlaceDataSource(
    this._client, {
    this.endpoint = 'https://photon.komoot.io/api/',
  });
  final http.Client _client;
  final String endpoint;
  @override
  Future<List<SearchPlaceDto>> search(
    String query, {
    bool citiesOnly = false,
    PlaceSearchCancellation? cancellation,
  }) async {
    final base = Uri.parse(endpoint);
    if (base.scheme != 'https' ||
        base.host.isEmpty ||
        base.userInfo.isNotEmpty) {
      throw const FormatException('Invalid place service');
    }
    final abort = Completer<void>();
    void cancel() {
      if (!abort.isCompleted) abort.complete();
    }

    if (cancellation?.isCancelled == true) cancel();
    cancellation?.whenCancelled.then((_) => cancel());
    final request = http.AbortableRequest(
      'GET',
      base.replace(
        queryParameters: {
          'q': query,
          'limit': '5',
          'countrycode': 'PE',
          if (citiesOnly) 'layer': 'city',
        },
      ),
      abortTrigger: abort.future,
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'User-Agent':
          'EntreHuellas/0.1 (+https://github.com/srg-cp/entrehuellas)',
    });
    final response =
        await (() async => http.Response.fromStream(
          await _client.send(request),
        ))().timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            cancel();
            throw TimeoutException('Place lookup timed out');
          },
        );
    if (response.statusCode != 200 || response.bodyBytes.length > 262144) {
      throw const FormatException('Place service unavailable');
    }
    final result = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    final features = result['features'] as List;
    final rows = <SearchPlaceDto>[];
    var validPlaces = 0;
    for (final feature in features.take(5)) {
      try {
        final row = Map<String, dynamic>.from(feature as Map);
        final place = SearchPlaceDto.fromJson(row, citiesOnly: citiesOnly);
        validPlaces++;
        // Also enforce the country if an endpoint ignores the request filter.
        final countryCode = (row['properties'] as Map)['countrycode'];
        if (countryCode is String && countryCode.toUpperCase() == 'PE') {
          rows.add(place);
        }
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      } on RangeError {
        continue;
      }
    }
    if (!citiesOnly && features.isNotEmpty && validPlaces == 0) {
      throw const FormatException('No valid places');
    }
    return rows;
  }
}
