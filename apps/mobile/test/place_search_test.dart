import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/places/domain/use_cases/search_places.dart';
import 'package:flutter_application_entrehuellas/features/places/domain/failures/place_search_failure.dart';
import 'package:flutter_application_entrehuellas/features/places/data/data_sources/photon_place_data_source.dart';
import 'package:flutter_application_entrehuellas/features/places/data/repositories/place_search_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/places/presentation/view_models/place_search_view_model.dart';
import 'package:flutter_application_entrehuellas/features/places/providers/places_providers.dart';
import 'support/fake_place_search.dart';

void main() {
  for (final citiesOnly in [false, true]) {
    test(
      'Peru filter rejects foreign and unverified countries: cities=$citiesOnly',
      () async {
        var foreignOnly = false;
        Map<String, Object> feature(String? code) => {
          'geometry': {
            'coordinates': [-70.25, -18.01],
          },
          'properties': {
            'name': 'Tacna',
            'country': 'Perú',
            'type': 'city',
            if (code != null) 'countrycode': code,
          },
        };
        final client = MockClient((request) async {
          expect(request.url.queryParameters['countrycode'], 'PE');
          expect(
            request.url.queryParameters['layer'],
            citiesOnly ? 'city' : isNull,
          );
          return http.Response(
            jsonEncode({
              'features': [
                feature('CL'),
                feature(null),
                feature(''),
                if (!foreignOnly) feature('pe'),
              ],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });
        addTearDown(client.close);
        final source = PhotonPlaceDataSource(client);
        final places = await source.search('Tacna', citiesOnly: citiesOnly);
        expect(places, hasLength(1));
        expect(places.single.latitude, -18.01);
        foreignOnly = true;
        expect(
          await source.search('Santiago', citiesOnly: citiesOnly),
          isEmpty,
        );
      },
    );
  }
  test(
    'Place lookup validates, normalizes, decodes longitude/latitude and caches requests',
    () async {
      int requests = 0;
      final client = MockClient((request) async {
        requests++;
        expect(request.url.queryParameters, {
          'q': 'Miraflores Lima',
          'limit': '5',
          'countrycode': 'PE',
        });
        expect(request.headers.containsKey('Authorization'), false);
        expect(request.headers['User-Agent'], startsWith('EntreHuellas/'));
        return http.Response(
          jsonEncode({
            'features': [
              {
                'geometry': {
                  'coordinates': [-77.03, -12.12],
                },
                'properties': {
                  'name': 'Miraflores',
                  'city': 'Miraflores',
                  'country': 'Perú',
                  'countrycode': 'PE',
                },
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      addTearDown(client.close);
      final use = SearchPlaces(
        PlaceSearchRepositoryImpl(PhotonPlaceDataSource(client)),
      );
      expect(() => use('x'), throwsA(isA<PlaceSearchFailure>()));
      expect(requests, 0);
      final rows = await use('  Miraflores   Lima  ');
      expect(rows.single.label, 'Miraflores, Perú');
      expect(rows.single.latitude, -12.12);
      expect(rows.single.longitude, -77.03);
      await use('Miraflores Lima');
      expect(requests, 1);
    },
  );
  test(
    'Malformed, invalid coordinates and HTTP errors stay failures; empty remains confirmed empty',
    () async {
      for (final body in [
        'not json',
        jsonEncode({
          'features': [
            {
              'geometry': {
                'coordinates': [0, 91],
              },
              'properties': {'name': 'Invalid'},
            },
          ],
        }),
      ]) {
        final client = MockClient((_) async => http.Response(body, 200));
        addTearDown(client.close);
        await expectLater(
          PlaceSearchRepositoryImpl(
            PhotonPlaceDataSource(client),
          ).search('Lima'),
          throwsA(isA<PlaceSearchFailure>()),
        );
      }
      final failing = MockClient(
        (_) async => http.Response('Private service error', 503),
      );
      addTearDown(failing.close);
      await expectLater(
        PlaceSearchRepositoryImpl(
          PhotonPlaceDataSource(failing),
        ).search('Lima'),
        throwsA(isA<PlaceSearchFailure>()),
      );
      final empty = MockClient(
        (_) async => http.Response('{"features":[]}', 200),
      );
      addTearDown(empty.close);
      expect(
        await PlaceSearchRepositoryImpl(
          PhotonPlaceDataSource(empty),
        ).search('Nothing'),
        isEmpty,
      );
    },
  );
  test(
    'Search blocks duplicate work and discards responses across identity changes',
    () async {
      final repo = FakePlaceSearch();
      final sessions = StreamController<AuthSession?>();
      final container = ProviderContainer(
        overrides: [
          placeSearchRepositoryProvider.overrideWithValue(repo),
          placesSessionProvider.overrideWith((_) => sessions.stream),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(sessions.close);
      final sub = container.listen(placeSearchViewModelProvider, (_, _) {});
      addTearDown(sub.close);
      await Future<void>.delayed(Duration.zero);
      sessions.add(const AuthSession(userId: 'a'));
      await container.read(placesSessionProvider.future);
      repo.pending = Completer();
      final late = repo.pending!;
      final work = container
          .read(placeSearchViewModelProvider.notifier)
          .search('Lima');
      await container
          .read(placeSearchViewModelProvider.notifier)
          .search('Lima');
      expect(repo.queries, hasLength(1));
      sessions.add(const AuthSession(userId: 'b'));
      await Future<void>.delayed(Duration.zero);
      late.complete(const [FakePlaceSearch.place]);
      await work;
      expect(container.read(placeSearchViewModelProvider).places, isEmpty);
      repo.pending = null;
      await container
          .read(placeSearchViewModelProvider.notifier)
          .search('Lima');
      expect(container.read(placeSearchViewModelProvider).places, hasLength(1));
    },
  );
  test(
    'Search recovers after failure and clear discards pending results',
    () async {
      final repo = FakePlaceSearch()..fail = true;
      final container = ProviderContainer(
        overrides: [
          placeSearchRepositoryProvider.overrideWithValue(repo),
          placesSessionProvider.overrideWith(
            (_) => Stream.value(const AuthSession(userId: 'a')),
          ),
        ],
      );
      addTearDown(container.dispose);
      final sub = container.listen(placeSearchViewModelProvider, (_, _) {});
      addTearDown(sub.close);
      await container.read(placesSessionProvider.future);
      final model = container.read(placeSearchViewModelProvider.notifier);
      await model.search('Lima');
      expect(container.read(placeSearchViewModelProvider).notice, isNotNull);
      repo.fail = false;
      await model.search('Lima');
      expect(container.read(placeSearchViewModelProvider).places, hasLength(1));
      repo.pending = Completer();
      final work = model.search('Cusco');
      model.clear();
      repo.pending!.complete(const [FakePlaceSearch.place]);
      await work;
      expect(container.read(placeSearchViewModelProvider).places, isEmpty);
      expect(container.read(placeSearchViewModelProvider).busy, false);
    },
  );
}
