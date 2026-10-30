import 'dart:io';
import 'package:flutter_application_entrehuellas/core/config/map_config.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_entrehuellas/app/navigation/entity_editor_page.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_section.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/screens/explore_map_screen.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/zone_map_picker.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/entities/explore_query.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/view_models/explore_view_model.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_case_map.dart';
import 'package:flutter_application_entrehuellas/features/explore/providers/explore_providers.dart';
import 'alert_preferences_test.dart' show loadFonts;
import 'explore_test.dart' show SearchFake, item, ExploreHome;
import 'package:flutter_application_entrehuellas/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/view_models/home_view_model.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/liquid_navigation.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_map_button.dart';
import 'support/fake_current_location.dart';
import 'lost_cases_test.dart' show FakeCases;
import 'found_cases_test.dart' show FakeFoundCases;
import 'package:flutter_application_entrehuellas/features/lost_cases/providers/lost_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/providers/found_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/entities/lost_case.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_map_pin.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_map_pins.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/entities/explore_page.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_map_case_preview.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_photo.dart';
import 'package:flutter_application_entrehuellas/core/presentation/formatters/case_date_label.dart';

class _MemoryTiles extends TileProvider {
  _MemoryTiles(this.bytes);
  final Uint8List bytes;
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(bytes);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => Directory.systemTemp.path,
        );
  });
  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
  });

  testWidgets(
    'Nearby and coincident pins stay individually tappable after zoom and rotation',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = MapController();
      addTearDown(controller.dispose);
      final cases = List.generate(
        5,
        (index) => previewItem(
          '$index',
          latitude: -12.05 + (index < 2 ? 0 : index * .00001),
        ),
      );
      final selected = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterMap(
              mapController: controller,
              options: const MapOptions(
                initialCenter: LatLng(-12.05, -77.04),
                initialZoom: 14,
              ),
              children: [
                ExploreMapPins(
                  items: cases,
                  selectedKey: null,
                  onSelect: (item) => selected.add(item.key),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      for (final zoom in [12.0, 18.0]) {
        controller.move(const LatLng(-12.05, -77.04), zoom);
        controller.rotate(zoom == 12 ? 0 : 45);
        await tester.pump();
        final pins = find.byType(ExploreMapPin);
        expect(pins, findsNWidgets(cases.length));
        for (var i = 0; i < cases.length; i++) {
          final rect = tester.getRect(pins.at(i));
          expect(rect.size, const Size(48, 48));
          for (var j = i + 1; j < cases.length; j++) {
            expect(rect.overlaps(tester.getRect(pins.at(j))), false);
          }
          await tester.tap(
            find.byTooltip('Seleccionar caso: ${cases[i].name}'),
          );
          await tester.pump();
        }
      }
      expect(selected, [
        ...cases.map((item) => item.key),
        ...cases.map((item) => item.key),
      ]);
      expect(cases[0].latitude, cases[1].latitude);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Summary shows the recorded pet type instead of breed', (
    tester,
  ) async {
    for (final entry in {
      'dog': 'Perro',
      'cat': 'Gato',
      'other': 'Otra especie',
      '': 'Tipo no registrado',
    }.entries) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExploreMapPreviewContent(
              item: previewItem('type', species: entry.key),
            ),
          ),
        ),
      );
      expect(find.text(entry.value), findsOneWidget);
      expect(find.textContaining('Raza'), findsNothing);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final reduced in [false, true]) {
    testWidgets(
      'Map opens from its option, shares results, opens detail and returns; reduced=$reduced',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = reduced
            ? const Size(320, 350)
            : const Size(390, 844);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final photoUri = Uri.parse('https://example.com/map-preview.png');
        await tester.runAsync(() async {
          final bytes = await File(
            'assets/onboarding/dog_and_cat.png',
          ).readAsBytes();
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          PaintingBinding.instance.imageCache.putIfAbsent(
            NetworkImage(photoUri.toString()),
            () => OneFrameImageStreamCompleter(
              Future.value(ImageInfo(image: frame.image)),
            ),
          );
          codec.dispose();
        });
        addTearDown(
          () => PaintingBinding.instance.imageCache.evict(
            NetworkImage(photoUri.toString()),
          ),
        );
        final repo = SearchFake()
          ..firstPage = [item('one', coverUri: photoUri)];
        await tester.runAsync(loadFonts);
        final boundary = GlobalKey();
        final tileBytes = await tester.runAsync(_neutralTile);
        OriginPageSource? source;
        final router = GoRouter(
          initialLocation: '/home',
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, _) => const HomeScreen(
                profileAvatar: SizedBox.square(dimension: 40),
                exploreContent: ExploreSection(),
                exploreFloatingAction: ExploreMapButton(),
              ),
              routes: [
                GoRoute(
                  path: 'explore-map',
                  pageBuilder: (context, state) {
                    source = state.extra as OriginPageSource;
                    return entityEditorPage(
                      context: context,
                      key: state.pageKey,
                      source: state.extra,
                      child: ExploreMapScreen(
                        createTileProvider: () => _MemoryTiles(tileBytes!),
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'cases/:id',
                  builder: (context, state) => Scaffold(
                    body: TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Volver al mapa ${state.pathParameters['id']}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              homeViewModelProvider.overrideWith(ExploreHome.new),
              exploreRepositoryProvider.overrideWithValue(repo),
              lostCaseRepositoryProvider.overrideWithValue(
                FakeCases()
                  ..publicCase = PublicLostCase(
                    id: 'one',
                    status: 'active',
                    occurredAt: DateTime.utc(2026, 10, 14),
                    latitude: -12.05,
                    longitude: -77.04,
                    fields: const PetFields(
                      name: 'Luna',
                      species: PetSpecies.dog,
                      size: PetSize.medium,
                    ),
                    photos: [],
                  ),
              ),
              foundCaseRepositoryProvider.overrideWithValue(FakeFoundCases()),
              currentLocationRepositoryProvider.overrideWithValue(
                const FakeCurrentLocation(),
              ),
              exploreSessionProvider.overrideWith(
                (_) => Stream.value(const AuthSession(userId: 'a')),
              ),
            ],
            child: MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
              builder: (context, child) => RepaintBoundary(
                key: boundary,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    disableAnimations: reduced,
                    textScaler: TextScaler.linear(reduced ? 2 : 1),
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                  ),
                  child: child!,
                ),
              ),
            ),
          ),
        );
        await settleMap(tester);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(ExploreSection)),
        );
        final location = container
            .read(exploreViewModelProvider)
            .requireValue
            .query;
        await container
            .read(exploreViewModelProvider.notifier)
            .apply(
              kind: ExploreKind.lost,
              species: ExploreSpecies.dog,
              status: ExploreStatus.active,
              days: 7,
              latitude: location.latitude,
              longitude: location.longitude,
              radiusMeters: location.radiusMeters,
            );
        await settleMap(tester);
        final initial = container.read(exploreViewModelProvider).requireValue;
        final searchCount = repo.calls.length;
        await tester.ensureVisible(find.text('Mapa'));
        await settleMap(tester);
        final option = find
            .ancestor(of: find.text('Mapa'), matching: find.byType(InkWell))
            .first;
        final bounds = tester.getRect(option);
        expect(find.text('Lista'), findsNothing);
        expect(bounds.height, greaterThanOrEqualTo(48));
        expect(
          bounds.bottom,
          lessThanOrEqualTo(
            tester.getRect(find.byType(LiquidNavigation)).top - 20,
          ),
        );
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -120),
        );
        await settleMap(tester);
        expect(tester.getRect(option), bounds);
        final listOffset = tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels;
        await tester.tap(find.text('Mapa'));
        await settleMap(tester);
        expect(find.byType(ExploreMapScreen), findsOneWidget);
        expect(source!.bounds, bounds);
        expect(
          container.read(exploreViewModelProvider).requireValue.query,
          same(initial.query),
        );
        expect(repo.calls, hasLength(searchCount));
        expect(
          container.read(exploreViewModelProvider).requireValue.items,
          same(initial.items),
        );
        expect(
          container.read(exploreViewModelProvider).requireValue.cursor,
          initial.cursor,
        );
        if (const bool.fromEnvironment('CAPTURE_EXPLORE_MAP')) {
          await tester.runAsync(() async {
            final raster =
                await (boundary.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await raster.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final dir = Directory('build/ui-preview/explore-map')
              ..createSync(recursive: true);
            File(
              '${dir.path}/screen-${reduced ? 'small' : 'normal'}.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            raster.dispose();
          });
        }
        final sheet = tester.widget<DraggableScrollableSheet>(
          find.byType(DraggableScrollableSheet),
        );
        final before = sheet.controller!.size;
        if (!reduced) {
          final gentleDrag = await tester.startGesture(
            tester.getCenter(
              find.bySemanticsLabel(
                'Desliza para ampliar o reducir el resumen',
              ),
            ),
          );
          await gentleDrag.moveBy(
            Offset(0, -tester.view.physicalSize.height * .12),
          );
          await tester.pump(const Duration(milliseconds: 200));
          await gentleDrag.up();
          await tester.pump();
          await tester.pump();
          final released = sheet.controller!.size;
          expect(released, greaterThan(.5));
          await tester.pump(const Duration(milliseconds: 100));
          expect(sheet.controller!.size, greaterThan(.5));
          expect(sheet.controller!.size, lessThan(released));
          await settleMap(tester);
          expect(sheet.controller!.size, closeTo(.5, .001));

          // A quick release keeps travelling, and touching it again holds the
          // current position before a new drag wins the gesture arena.
          final handle = find.bySemanticsLabel(
            'Desliza para ampliar o reducir el resumen',
          );
          await tester.timedDrag(
            handle,
            const Offset(0, -90),
            const Duration(milliseconds: 100),
          );
          await tester.pump();
          await tester.pump();
          final flung = sheet.controller!.size;
          await tester.pump(const Duration(milliseconds: 32));
          expect(sheet.controller!.size, greaterThan(flung));
          expect(sheet.controller!.size, lessThan(.9));
          final interrupt = await tester.startGesture(tester.getCenter(handle));
          final held = sheet.controller!.size;
          await tester.pump(const Duration(milliseconds: 120));
          expect(sheet.controller!.size, closeTo(held, .0001));
          await interrupt.moveBy(const Offset(0, 60));
          await tester.pump();
          expect(sheet.controller!.size, lessThan(held));
          await interrupt.up();
          await settleMap(tester);
          sheet.controller!.jumpTo(.5);
          await tester.pump();
        }
        expect(sheet.minChildSize, .22);
        expect(find.text('Filtros de búsqueda'), findsNothing);
        final back = find.byTooltip('Volver a Explorar');
        double backOpacity() => tester
            .widgetList<Opacity>(
              find.ancestor(of: back, matching: find.byType(Opacity)),
            )
            .first
            .opacity;
        final backTop = tester.getTopLeft(back).dy;
        sheet.controller!.jumpTo(.9);
        await settleMap(tester);
        expect(backOpacity(), 0);
        if (!reduced) expect(tester.getTopLeft(back).dy, lessThan(backTop));
        await capturePanel(
          tester,
          boundary,
          reduced ? 'small-expanded' : 'normal-expanded',
        );
        sheet.controller!.jumpTo(.5);
        await settleMap(tester);
        expect(backOpacity(), 1);
        expect(tester.getTopLeft(back).dy, backTop);
        sheet.controller!.jumpTo(sheet.minChildSize);
        await settleMap(tester);
        final surface = find.byKey(const ValueKey('map-case-surface'));
        final normalTop = tester.getTopLeft(surface).dy;
        final drag = await tester.startGesture(
          tester.getCenter(
            find.bySemanticsLabel('Desliza para ampliar o reducir el resumen'),
          ),
        );
        await drag.moveBy(const Offset(0, 100));
        await tester.pump();
        expect(sheet.controller!.size, closeTo(sheet.minChildSize, .001));
        if (!reduced) {
          expect(tester.getTopLeft(surface).dy, greaterThan(normalTop));
          expect(
            tester.getTopLeft(surface).dy - normalTop,
            lessThanOrEqualTo(18),
          );
        }
        await drag.up();
        await settleMap(tester);
        expect(tester.getTopLeft(surface).dy, closeTo(normalTop, .01));
        expect(sheet.controller!.size, closeTo(sheet.minChildSize, .001));
        await tester.drag(
          find.bySemanticsLabel('Desliza para ampliar o reducir el resumen'),
          Offset(0, -tester.view.physicalSize.height * .5),
        );
        await settleMap(tester);
        expect(sheet.controller!.size, greaterThan(before));
        expect(find.text('Abrir caso'), findsNothing);
        expect(find.text('Aplicar filtros'), findsNothing);
        expect(find.text('Perdidas'), findsNothing);
        expect(
          find.text('Selecciona un pin para ver el resumen del caso.'),
          findsOneWidget,
        );
        final applied = initial.query;
        sheet.controller!.jumpTo(.5);
        await settleMap(tester);
        await tester.tap(find.byTooltip('Seleccionar caso: Luna'));
        await settleMap(tester);
        expect(find.text('Abrir caso'), findsNothing);
        final selectedSheet = tester.widget<DraggableScrollableSheet>(
          find.byType(DraggableScrollableSheet),
        );
        await tester.drag(
          find.bySemanticsLabel('Desliza para ampliar o reducir el resumen'),
          Offset(0, tester.view.physicalSize.height),
        );
        await settleMap(tester);
        final button = find.text('Ver ficha');
        expect(
          tester.getBottomLeft(button).dy,
          lessThanOrEqualTo(tester.view.physicalSize.height - 24 - 12 + 1),
        );
        final detailsTop = tester.getTopLeft(find.text('Detalles del caso')).dy;
        expect(
          detailsTop,
          greaterThanOrEqualTo(tester.view.physicalSize.height - 24 - 12),
        );
        if (MapConfig.usesCarto) {
          final credit = find.text('© CARTO');
          expect(credit, findsOneWidget);
          expect(
            tester.getBottomLeft(credit).dy,
            lessThan(tester.getTopLeft(surface).dy),
          );
        }
        await capturePanel(
          tester,
          boundary,
          reduced ? 'small-minimized' : 'normal-minimized',
        );
        selectedSheet.controller!.jumpTo(selectedSheet.initialChildSize);
        await settleMap(tester);
        await capturePanel(
          tester,
          boundary,
          reduced ? 'small-summary' : 'normal-summary',
        );
        expect(find.text('Mediano'), findsOneWidget);
        expect(find.text('Perro'), findsOneWidget);
        expect(find.textContaining('Raza'), findsNothing);
        expect(find.text('Abierto'), findsNothing);
        expect(find.textContaining('casos consultados'), findsNothing);
        expect(find.textContaining('Ubicaciones aproximadas'), findsNothing);
        final photoSize = tester.getSize(
          find.byKey(const ValueKey('map-preview-photo')),
        );
        expect(photoSize, const Size(112, 112));
        expect(find.text('Blanca'), findsOneWidget);
        expect(find.text('Mascota perdida'), findsNothing);
        final dateLabel = caseDateOnlyLabel(DateTime.utc(2026, 10, 14));
        expect(find.text(dateLabel), findsOneWidget);
        if (!reduced) {
          await Scrollable.ensureVisible(
            tester.element(find.text(dateLabel)),
            alignment: .5,
          );
          await settleMap(tester);
          expect(
            tester.getBottomLeft(find.text(dateLabel)).dy,
            lessThanOrEqualTo(tester.view.physicalSize.height - 24 - 16),
          );
        }
        expect(find.byType(CasePhotoView), findsOneWidget);
        sheet.controller!.jumpTo(.9);
        await settleMap(tester);
        await capturePanel(
          tester,
          boundary,
          reduced ? 'small-case-expanded' : 'normal-case-expanded',
        );
        sheet.controller!.jumpTo(.5);
        await settleMap(tester);

        expect(
          tester
              .getBottomLeft(find.byKey(const ValueKey('map-preview-photo')))
              .dy,
          lessThan(
            tester
                .getTopLeft(find.byKey(const ValueKey('map-preview-facts')))
                .dy,
          ),
        );
        final sizeIcon = tester.getCenter(
          find.byIcon(Icons.straighten_rounded),
        );
        final dateIcon = tester.getCenter(
          find.byIcon(Icons.calendar_today_outlined),
        );
        expect(sizeIcon.dx, closeTo(dateIcon.dx, .01));
        expect(sizeIcon.dy, lessThan(dateIcon.dy));
        expect(
          tester.getTopLeft(find.byType(ExploreMapPreviewContent)).dy,
          greaterThanOrEqualTo(tester.getTopLeft(surface).dy),
        );
        await tester.ensureVisible(find.text('Ver ficha'));
        await settleMap(tester);
        expect(find.byType(ExploreMapPin), findsOneWidget);
        await capturePanel(
          tester,
          boundary,
          reduced ? 'small-preview-photo' : 'normal-preview-photo',
        );
        await tester.tap(find.text('Ver ficha'));
        await settleMap(tester);
        expect(find.text('Volver al mapa one'), findsOneWidget);
        await tester.tap(find.text('Volver al mapa one'));
        await settleMap(tester);
        expect(find.byType(ExploreMapScreen), findsOneWidget);
        expect(repo.calls, hasLength(searchCount + 1));
        await tester.ensureVisible(find.text('Ver más casos'));
        await settleMap(tester);
        await tester.tap(find.text('Ver más casos'));
        await settleMap(tester);
        expect(repo.calls, hasLength(searchCount + 2));
        expect(repo.calls.last.$3, 'page-2');
        expect(
          container.read(exploreViewModelProvider).requireValue.query,
          same(applied),
        );
        sheet.controller!.jumpTo(.5);
        await settleMap(tester);
        await tester.tap(find.byTooltip('Volver a Explorar'));
        await settleMap(tester);
        expect(find.byType(ExploreMapScreen), findsNothing);
        expect(
          tester
              .state<ScrollableState>(find.byType(Scrollable).first)
              .position
              .pixels,
          listOffset,
        );
        expect(find.text('Explorar'), findsOneWidget);
        expect(repo.calls, hasLength(searchCount + 2));
        expect(
          container.read(exploreViewModelProvider).requireValue.query,
          same(applied),
        );
        await tester.tap(find.byTooltip('Inicio'));
        await settleMap(tester);
        expect(find.byType(ExploreMapButton), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  for (final small in [false, true]) {
    testWidgets(
      'Public map separates coincident pins, opens each case, and permits navigation without editing; small=$small',
      (tester) async {
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        late Uint8List tileBytes;
        await tester.runAsync(() async {
          await loadFonts();
          final recorder = ui.PictureRecorder();
          Canvas(recorder).drawColor(const Color(0xFFF5F5F7), BlendMode.src);
          final picture = recorder.endRecording();
          final image = await picture.toImage(256, 256);
          tileBytes = (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!.buffer.asUint8List();
          image.dispose();
          picture.dispose();
        });
        final boundary = GlobalKey();
        final opened = <String>[];
        const query = ExploreQuery(
          latitude: -12.05,
          longitude: -77.04,
          radiusMeters: 15000,
        );
        final items = [
          item('same', name: 'Luna'),
          item('same', fromPet: false, name: 'Sol'),
        ];
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                size: tester.view.physicalSize,
                textScaler: TextScaler.linear(small ? 2 : 1),
                disableAnimations: small,
              ),
              child: Scaffold(
                body: RepaintBoundary(
                  key: boundary,
                  child: ColoredBox(
                    color: Colors.white,
                    child: ExploreCaseMap(
                      items: items,
                      query: query,
                      createTileProvider: () => _MemoryTiles(tileBytes),
                      onOpen: (value, _) => opened.add(value.key),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await settleMap(tester);
        final picker = tester.widget<ZoneMapPicker>(find.byType(ZoneMapPicker));
        expect(picker.showRadius, false);
        expect(find.byType(CircleLayer), findsNothing);
        expect(picker.readOnly, true);
        expect(picker.readOnlyNavigation, true);
        expect(picker.onSelect, isNull);
        expect(find.byType(ExploreMapPin), findsNWidgets(2));
        expect(items[0].latitude, items[1].latitude);
        expect(items[0].longitude, items[1].longitude);
        final pins = find.byType(ExploreMapPin);
        expect(
          tester.getRect(pins.at(0)).overlaps(tester.getRect(pins.at(1))),
          false,
        );
        expect(
          tester.getSize(find.byType(FlutterMap)),
          tester.view.physicalSize,
        );
        await tester.tap(find.byTooltip('Seleccionar caso: Luna'));
        await settleMap(tester);
        final sheet = tester.widget<DraggableScrollableSheet>(
          find.byType(DraggableScrollableSheet),
        );
        expect(sheet.controller!.size, greaterThanOrEqualTo(.5));
        await capturePanel(
          tester,
          boundary,
          small ? 'small-preview-selected' : 'normal-preview-selected',
        );
        for (final name in ['Luna', 'Sol']) {
          sheet.controller!.jumpTo(.5);
          await settleMap(tester);
          await tester.tap(find.byTooltip('Seleccionar caso: $name'));
          await settleMap(tester);
          expect(find.text(name == 'Sol' ? 'Luna' : 'Sol'), findsNothing);
          expect(find.text('1 de 2'), findsNothing);
          expect(find.text('2 de 2'), findsNothing);
          expect(find.byTooltip('Caso siguiente'), findsNothing);
          expect(find.text(name), findsOneWidget);
          expect(find.text('Abrir caso'), findsNothing);
          await settleMap(tester);
          await Scrollable.ensureVisible(
            tester.element(find.text('Ver ficha')),
          );
          await settleMap(tester);
          await tester.tap(find.text('Ver ficha'));
          await tester.ensureVisible(find.byTooltip('Abrir ficha del caso'));
          await settleMap(tester);
          await tester.tap(find.byTooltip('Abrir ficha del caso'));
        }
        expect(opened, ['lost:same', 'lost:same', 'found:same', 'found:same']);
        sheet.controller!.jumpTo(.5);
        await settleMap(tester);
        if (const bool.fromEnvironment('CAPTURE_EXPLORE_MAP')) {
          await tester.runAsync(() async {
            final image =
                await (boundary.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final dir = Directory('build/ui-preview/explore-map')
              ..createSync(recursive: true);
            File(
              '${dir.path}/${small ? 'small' : 'normal'}.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        final center = MapController.of(
          tester.element(find.byType(TileLayer)),
        ).camera.center;
        sheet.controller!.jumpTo(.5);
        await settleMap(tester);
        await tester.dragFrom(const Offset(40, 24), const Offset(60, 0));
        await settleMap(tester);
        expect(
          MapController.of(
            tester.element(find.byType(TileLayer)),
          ).camera.center,
          isNot(center),
        );
        expect(picker.latitude, query.latitude);
        expect(picker.longitude, query.longitude);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await settleMap(tester);
      },
    );
  }
}

Future<Uint8List> _neutralTile() async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawColor(const Color(0xFFF5F5F7), BlendMode.src);
  final picture = recorder.endRecording();
  final image = await picture.toImage(256, 256);
  final bytes = (await image.toByteData(
    format: ui.ImageByteFormat.png,
  ))!.buffer.asUint8List();
  image.dispose();
  picture.dispose();
  return bytes;
}

Future<void> capturePanel(
  WidgetTester tester,
  GlobalKey boundary,
  String name,
) async {
  if (!const bool.fromEnvironment('CAPTURE_EXPLORE_MAP')) return;
  await tester.runAsync(() async {
    final image =
        await (boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('build/ui-preview/explore-map')
      ..createSync(recursive: true);
    await File(
      '${dir.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

// AppPageBackground animates continuously; advance route, sheet and reveal
// frames explicitly rather than waiting for every ticker to become idle.
Future<void> settleMap(WidgetTester tester) async {
  for (var frame = 0; frame < 90; frame++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

ExploreCase previewItem(
  String id, {
  String species = 'dog',
  double latitude = -12.05,
}) => ExploreCase(
  id: id,
  fromPet: true,
  kind: ExploreKind.lost,
  status: ExploreStatus.active,
  species: species,
  name: 'Mascota $id',
  traits: '',
  occurredAt: DateTime.utc(2026, 10, 14),
  latitude: latitude,
  longitude: -77.04,
);
