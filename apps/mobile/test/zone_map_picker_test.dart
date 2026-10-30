import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/presentation/widgets/zone_map_picker.dart';

void main() {
  testWidgets(
    'Map failure preserves manual alternative, retry replaces source, tap selects and coordinates recenter',
    (tester) async {
      var failed = true;
      var providers = 0;
      double? latitude;
      double? longitude;
      late StateSetter update;
      final clients = <MockClient>[];
      addTearDown(() {
        for (final client in clients) {
          client.close();
        }
      });
      PaintingBinding.instance.imageCache.clear();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return ZoneMapPicker(
                  latitude: latitude,
                  longitude: longitude,
                  radiusMeters: 1000,
                  onSelect: (lat, lng) => setState(() {
                    latitude = lat;
                    longitude = lng;
                  }),
                  createTileProvider: () {
                    providers++;
                    final client = MockClient(
                      (request) async => failed
                          ? http.Response('unavailable', 400, request: request)
                          : http.Response.bytes(
                              TileProvider.transparentImage,
                              200,
                              request: request,
                            ),
                    );
                    clients.add(client);
                    return NetworkTileProvider(
                      httpClient: client,
                      attemptDecodeOfHttpErrorResponses: false,
                      cachingProvider: const DisabledMapCachingProvider(),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
      Future<void> processTiles() async {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 80)),
        );
        await tester.pumpAndSettle();
      }

      await processTiles();
      expect(find.textContaining('No se pudo mostrar el mapa'), findsOneWidget);
      await tester.tap(find.byType(FlutterMap));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(latitude, isNull);
      failed = false;
      await tester.tap(find.text('Reintentar mapa'));
      await processTiles();
      expect(providers, 2);
      expect(find.textContaining('No se pudo mostrar el mapa'), findsNothing);
      await tester.tap(find.byType(FlutterMap));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(latitude, closeTo(-12.0464, .01));
      expect(longitude, closeTo(-77.0428, .01));
      expect(
        providers,
        2,
        reason:
            'Editing must reuse the current source instead of leaking clients',
      );
      update(() {
        latitude = -13;
        longitude = -78;
      });
      await tester.pumpAndSettle();
      final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
      expect(map.mapController!.camera.center.latitude, -13);
      expect(map.mapController!.camera.center.longitude, -78);
      expect(
        tester
            .widget<CircleLayer>(find.byType(CircleLayer))
            .circles
            .single
            .useRadiusInMeter,
        true,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
