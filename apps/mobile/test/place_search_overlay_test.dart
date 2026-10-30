import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/places/domain/entities/search_place.dart';
import 'package:flutter_application_entrehuellas/features/places/presentation/widgets/place_search_fields.dart';
import 'package:flutter_application_entrehuellas/features/places/providers/places_providers.dart';
import 'support/fake_place_search.dart';
import 'package:flutter_application_entrehuellas/features/places/domain/cancellation/place_search_cancellation.dart';
import 'alert_preferences_test.dart' show loadFonts;

class _Places extends FakePlaceSearch {
  @override
  Future<List<SearchPlace>> search(
    String query, {
    bool citiesOnly = false,
    PlaceSearchCancellation? cancellation,
  }) async {
    await super.search(
      query,
      citiesOnly: citiesOnly,
      cancellation: cancellation,
    );
    return const [
      SearchPlace(
        label: 'Chiclayo, Lambayeque, Perú',
        latitude: -6.77,
        longitude: -79.84,
      ),
      SearchPlace(
        label: 'Chiclayo, Sarayacu, Loreto, Perú',
        latitude: -6.7,
        longitude: -75,
      ),
      SearchPlace(
        label: 'Chiclayo, San Martín de Socabaya, Socabaya, Arequipa, Perú',
        latitude: -16.4,
        longitude: -71.5,
      ),
      SearchPlace(label: 'Lima, Perú', latitude: -12, longitude: -77),
      SearchPlace(label: 'Tacna, Perú', latitude: -18, longitude: -70),
    ];
  }
}

void main() {
  for (final small in [false, true]) {
    testWidgets(
      'Suggestions overlay keeps layout, scrolls and selects: small=$small',
      (tester) async {
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.platformDispatcher.textScaleFactorTestValue = small ? 2 : 1;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final capture = Platform.environment['CAPTURE_PLACE_OVERLAY'] == '1';
        if (capture) await tester.runAsync(loadFonts);
        final repo = _Places()..pending = Completer();
        SearchPlace? selected;
        final boundary = GlobalKey();
        const next = ValueKey('following-content');
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              placeSearchRepositoryProvider.overrideWithValue(repo),
              placesSessionProvider.overrideWith(
                (_) => Stream.value(const AuthSession(userId: 'one')),
              ),
            ],
            child: RepaintBoundary(
              key: boundary,
              child: MaterialApp(
                theme: AppTheme.light,
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        PlaceSearchFields(
                          onSelect: (place) => selected = place,
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(
                          key: next,
                          height: 100,
                          width: double.infinity,
                          child: ColoredBox(
                            color: Color(0xFFD5E9F9),
                            child: Text('Radio: 15 km'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final before = tester.getRect(find.byKey(next));
        final field = tester.getRect(find.byType(PlaceSearchFields));
        await tester.enterText(find.byType(TextField), 'chiclayo');
        await tester.pump(const Duration(milliseconds: 650));
        await tester.pump();
        expect(tester.getRect(find.byKey(next)), before);
        expect(find.byKey(const ValueKey('place-suggestions')), findsOneWidget);
        repo.pending!.complete(const []);
        await tester.pumpAndSettle();
        expect(tester.getRect(find.byKey(next)), before);
        expect(tester.getRect(find.byType(PlaceSearchFields)), field);
        final panel = find.byKey(const ValueKey('place-suggestions'));
        expect(tester.getRect(panel).width, field.width);
        expect(tester.getRect(panel).top, closeTo(field.bottom + 8, .01));
        expect(
          tester.getRect(panel).bottom,
          lessThanOrEqualTo(tester.view.physicalSize.height - 8),
        );
        if (capture) {
          await tester.runAsync(() async {
            final raster =
                await (boundary.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await raster.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final folder = Directory('build/ui-preview/place-overlay')
              ..createSync(recursive: true);
            File(
              '${folder.path}/${small ? 'small' : 'normal'}.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            raster.dispose();
          });
        }
        final last = find.text('Tacna, Perú');
        await tester.ensureVisible(last);
        await tester.pumpAndSettle();
        await tester.tap(last);
        await tester.pumpAndSettle();
        expect(selected?.label, 'Tacna, Perú');
        expect(panel, findsNothing);
        expect(tester.getRect(find.byKey(next)), before);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets(
    'Dropdown stays above keyboard and opens upwards near screen edge',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      SearchPlace? selected;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            placeSearchRepositoryProvider.overrideWithValue(_Places()),
            placesSessionProvider.overrideWith(
              (_) => Stream.value(const AuthSession(userId: 'one')),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Spacer(),
                    PlaceSearchFields(onSelect: (place) => selected = place),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Chiclayo');
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      final panel = tester.getRect(
        find.byKey(const ValueKey('place-suggestions')),
      );
      final field = tester.getRect(find.byType(PlaceSearchFields));
      expect(panel.bottom, closeTo(field.top - 8, .01));
      expect(panel.top, greaterThanOrEqualTo(8));
      expect(panel.bottom, lessThan(544));
      final option = find.text('Chiclayo, Lambayeque, Perú');
      await tester.ensureVisible(option);
      await tester.pumpAndSettle();
      await tester.tap(option);
      await tester.pumpAndSettle();
      expect(selected?.label, 'Chiclayo, Lambayeque, Perú');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Outside dismissal invalidates pending results and unmount removes overlay',
    (tester) async {
      final repo = FakePlaceSearch()..pending = Completer();
      var outsideTaps = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            placeSearchRepositoryProvider.overrideWithValue(repo),
            placesSessionProvider.overrideWith(
              (_) => Stream.value(const AuthSession(userId: 'one')),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  PlaceSearchFields(
                    onSelect: (_) => fail('Dismissal must not select a place'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => outsideTaps++,
                    child: const Text('Otra acción'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Tacna');
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pump();
      expect(find.byKey(const ValueKey('place-suggestions')), findsOneWidget);
      await tester.tap(find.text('Otra acción'));
      await tester.pump();
      repo.pending!.complete(const [FakePlaceSearch.place]);
      await tester.pumpAndSettle();
      expect(outsideTaps, 1);
      expect(find.byKey(const ValueKey('place-suggestions')), findsNothing);
      repo.pending = null;
      await tester.enterText(find.byType(TextField), 'Lima');
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('place-suggestions')), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(find.byKey(const ValueKey('place-suggestions')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
