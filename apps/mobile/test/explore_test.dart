import 'package:flutter/services.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/collection_empty_state.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pets_section.dart';
import 'support/fake_pets.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/cover_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/loading_shimmer.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'support/fake_place_search.dart';
import 'package:flutter_application_entrehuellas/features/places/providers/places_providers.dart';
import 'package:flutter_application_entrehuellas/features/places/presentation/widgets/place_search_fields.dart';
import 'support/fake_current_location.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/zone_map_picker.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/filter_choice_group.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/filter_expansion.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_case_grid.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_map_button.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_application_entrehuellas/core/presentation/widgets/entity_card_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/entities/explore_query.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/entities/explore_page.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/failures/explore_failure.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/repositories/explore_repository.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/use_cases/search_cases.dart';
import 'package:flutter_application_entrehuellas/features/explore/data/data_sources/explore_data_source.dart';
import 'package:flutter_application_entrehuellas/features/explore/data/models/explore_page_dto.dart';
import 'package:flutter_application_entrehuellas/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/explore/providers/explore_providers.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/view_models/explore_view_model.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_section.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/state/home_view_state.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/view_models/home_view_model.dart';
import 'alert_preferences_test.dart' show loadFonts;
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';

ExploreCase item(
  String id, {
  bool fromPet = true,
  Uri? coverUri,
  String? name,
}) => ExploreCase(
  id: id,
  fromPet: fromPet,
  kind: fromPet ? ExploreKind.lost : ExploreKind.found,
  status: ExploreStatus.active,
  species: 'dog',
  name: name ?? (fromPet ? 'Luna' : ''),
  coverUri: coverUri,
  traits: 'Blanca',
  occurredAt: DateTime.utc(2026, 10, 14),
  latitude: -12.05,
  longitude: -77.04,
);

class SearchFake implements ExploreRepository {
  final calls = <(String, ExploreQuery, String?)>[];
  Completer<ExplorePage>? pending;
  bool fail = false;
  bool empty = false;
  List<ExploreCase>? firstPage;
  @override
  Future<ExplorePage> search(
    String owner,
    ExploreQuery query, {
    String? cursor,
  }) async {
    calls.add((owner, query, cursor));
    if (fail) throw const ExploreFailure(ExploreFailureKind.unavailable);
    if (pending != null) return pending!.future;
    if (empty) return ExplorePage(items: []);
    return cursor == null
        ? ExplorePage(items: firstPage ?? [item('one')], nextCursor: 'page-2')
        : ExplorePage(
            items: [item('one'), item('one', fromPet: false), item('two')],
          );
  }
}

class SourceFake implements ExploreDataSource {
  bool fail = false;
  @override
  Future<ExplorePageDto> search(
    String owner,
    ExploreQuery query,
    String? cursor,
  ) async {
    if (fail) throw const ExploreSourceFailure(true);
    return ExplorePageDto({
      'items': [
        {
          'id': 'one',
          'source': 'lost',
          'kind': 'lost',
          'status': 'active',
          'species': 'dog',
          'name': 'Luna',
          'traits': 'Blanca',
          'occurred_at': '2026-10-14T12:00:00Z',
          'latitude': -12.05,
          'longitude': -77.04,
          'distance_meters': 1000,
          'cover_path': 'verified.jpg',
        },
      ],
      'next_cursor': {'id': 'opaque'},
    });
  }

  @override
  Future<Uri> cover(String owner, String source, String path) async =>
      Uri.parse('https://example.com/verified.jpg');
}

class ExploreHome extends HomeViewModel {
  @override
  HomeViewState build() => const HomeViewState(section: HomeSection.explore);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => Directory.systemTemp.path,
        );
  });
  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
  });
  for (final reduced in [false, true]) {
    testWidgets(
      'Explore has one entrance and one initial query; reduced=$reduced',
      (tester) async {
        final repo = SearchFake()..pending = Completer<ExplorePage>();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              exploreRepositoryProvider.overrideWithValue(repo),
              currentLocationRepositoryProvider.overrideWithValue(
                const FakeCurrentLocation(),
              ),
              exploreSessionProvider.overrideWith(
                (_) => Stream.value(const AuthSession(userId: 'a')),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: MediaQuery(
                data: MediaQueryData(disableAnimations: reduced),
                child: const HomeScreen(
                  profileAvatar: SizedBox(width: 48, height: 48),
                  exploreFloatingAction: ExploreMapButton(),
                  exploreContent: ExploreSection(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Explorar'));
        await tester.pump();
        await tester.pump();
        final skeleton = find.byWidgetPredicate(
          (widget) =>
              widget is LoadingShimmer &&
              widget.loadingLabel == 'Consultando casos',
        );
        final shimmerState = tester.state(skeleton);
        final entrances = find.ancestor(
          of: skeleton,
          matching: find.byWidgetPredicate(
            (widget) => widget is AuthStageTransition && widget.enabled,
          ),
        );
        expect(entrances, findsNothing);
        expect(find.byType(CoverReveal), findsNothing);
        expect(
          find.ancestor(
            of: skeleton,
            matching: find.byWidgetPredicate(
              (widget) => widget is StaggerReveal && widget.enabled,
            ),
          ),
          findsOneWidget,
        );
        for (var frame = 0; frame < 90; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(find.byType(CoverReveal), findsNothing);
          expect(tester.state(skeleton), same(shimmerState));
          expect(repo.calls, hasLength(1));
        }
        for (final opacity in tester.widgetList<Opacity>(
          find.ancestor(of: skeleton, matching: find.byType(Opacity)),
        )) {
          expect(opacity.opacity, 1);
        }
        repo.pending!.complete(ExplorePage(items: []));
        await tester.pumpAndSettle();
        expect(skeleton, findsNothing);
        expect(find.text('No encontramos casos'), findsOneWidget);
        expect(find.byType(CollectionEmptyState), findsOneWidget);
        expect(find.text('No hay casos con estos filtros.'), findsNothing);
        expect(repo.calls, hasLength(1));
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final small in [false, true]) {
    testWidgets('Home section titles keep the same origin; small=$small', (
      tester,
    ) async {
      tester.view.physicalSize = small
          ? const Size(320, 350)
          : const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(loadFonts);
      final pets = FakePets()..pendingList = Completer<void>();
      final boundary = GlobalKey();
      pets.pets['pet'] = const Pet(
        id: 'pet',
        ownerId: 'a',
        version: 1,
        fields: PetFields(name: 'Luna', species: PetSpecies.dog),
      );
      final repo = SearchFake()..pending = Completer<ExplorePage>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            petRepositoryProvider.overrideWithValue(pets),
            petSessionProvider.overrideWith(
              (_) => Stream.value(const AuthSession(userId: 'a')),
            ),
            exploreRepositoryProvider.overrideWithValue(repo),
            currentLocationRepositoryProvider.overrideWithValue(
              const FakeCurrentLocation(),
            ),
            exploreSessionProvider.overrideWith(
              (_) => Stream.value(const AuthSession(userId: 'a')),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(small ? 2 : 1),
                disableAnimations: small,
              ),
              child: RepaintBoundary(
                key: boundary,
                child: const HomeScreen(
                  profileAvatar: SizedBox.square(dimension: 48),
                  exploreFloatingAction: ExploreMapButton(),
                  exploreContent: ExploreSection(),
                  petsContent: PetsSection(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Mis mascotas'));
      await tester.pump();
      await tester.pump();
      final origin = tester.getTopLeft(find.text('Mis mascotas'));
      pets.pendingList!.complete();
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Mis mascotas')), origin);
      await capture(tester, boundary, small, 'header-pets');
      await tester.tap(find.byTooltip('Explorar'));
      await tester.pump();
      await tester.pump();
      expect(tester.getTopLeft(find.text('Explorar')), origin);
      for (var frame = 0; frame < 90; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.getTopLeft(find.text('Explorar')), origin);
      }
      repo.pending!.complete(ExplorePage(items: []));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Explorar')), origin);
      await capture(tester, boundary, small, 'header-explore');
      expect(repo.calls, hasLength(1));
      expect(tester.takeException(), isNull);
    });
  }
  test(
    'Search rejects partial/manual coordinates and malformed ranges before reaching data',
    () async {
      final repo = SearchFake();
      final use = SearchCases(repo);
      for (final query in [
        const ExploreQuery(radiusMeters: 1000),
        const ExploreQuery(
          latitude: double.nan,
          longitude: 0,
          radiusMeters: 100,
        ),
        ExploreQuery(
          since: DateTime.utc(2026, 10, 15),
          until: DateTime.utc(2026, 10, 14),
        ),
      ]) {
        expect(() => use('account', query), throwsA(isA<ExploreFailure>()));
      }
      expect(repo.calls, isEmpty);
      await use(
        'account',
        const ExploreQuery(latitude: 0, longitude: 0, radiusMeters: 100),
      );
      expect(repo.calls, hasLength(1));
    },
  );
  test(
    'Repository maps DTO, opaque cursor, verified cover and safe failures',
    () async {
      final source = SourceFake();
      final repo = ExploreRepositoryImpl(source);
      final result = await repo.search('account', const ExploreQuery());
      expect(result.items.single.latitude, -12.05);
      expect(
        result.items.single.coverUri,
        Uri.parse('https://example.com/verified.jpg'),
      );
      expect(result.nextCursor, '{"id":"opaque"}');
      source.fail = true;
      await expectLater(
        repo.search('account', const ExploreQuery()),
        throwsA(
          isA<ExploreFailure>().having(
            (e) => e.kind,
            'kind',
            ExploreFailureKind.forbidden,
          ),
        ),
      );
    },
  );
  test(
    'Pagination deduplicates origin/ID, blocks duplicate requests and retries the same cursor',
    () async {
      final repo = SearchFake();
      final container = ProviderContainer(
        overrides: [
          exploreRepositoryProvider.overrideWithValue(repo),
          currentLocationRepositoryProvider.overrideWithValue(
            const FakeCurrentLocation(),
          ),
          exploreSessionProvider.overrideWith(
            (ref) => Stream.value(const AuthSession(userId: 'a')),
          ),
        ],
      );
      addTearDown(container.dispose);
      final sub = container.listen(exploreViewModelProvider, (_, _) {});
      addTearDown(sub.close);
      await container.read(exploreViewModelProvider.future);
      final vm = container.read(exploreViewModelProvider.notifier);
      repo.fail = true;
      await vm.more();
      var value = container.read(exploreViewModelProvider).requireValue;
      expect(value.failed, true);
      expect(value.items, hasLength(1));
      expect(value.cursor, 'page-2');
      repo.fail = false;
      repo.pending = Completer();
      final work = vm.more();
      await vm.more();
      expect(repo.calls, hasLength(3));
      repo.pending!.complete(
        ExplorePage(
          items: [item('one'), item('one', fromPet: false), item('two')],
        ),
      );
      await work;
      value = container.read(exploreViewModelProvider).requireValue;
      expect(value.items.map((i) => i.key).toSet(), {
        'lost:one',
        'found:one',
        'lost:two',
      });
      expect(value.cursor, isNull);
    },
  );
  test(
    'Refresh retains content; applying filters resets the cursor and hides old results',
    () async {
      final repo = SearchFake();
      final container = ProviderContainer(
        overrides: [
          exploreRepositoryProvider.overrideWithValue(repo),
          currentLocationRepositoryProvider.overrideWithValue(
            const FakeCurrentLocation(),
          ),
          exploreSessionProvider.overrideWith(
            (ref) => Stream.value(const AuthSession(userId: 'a')),
          ),
        ],
      );
      addTearDown(container.dispose);
      final sub = container.listen(exploreViewModelProvider, (_, _) {});
      addTearDown(sub.close);
      await container.read(exploreViewModelProvider.future);
      final vm = container.read(exploreViewModelProvider.notifier);
      repo.pending = Completer();
      final refresh = vm.refresh();
      expect(
        container.read(exploreViewModelProvider).requireValue.items,
        hasLength(1),
      );
      repo.pending!.completeError(Exception('network'));
      await refresh;
      expect(
        container.read(exploreViewModelProvider).requireValue.items,
        hasLength(1),
      );
      repo.pending = Completer();
      final apply = vm.apply(
        kind: ExploreKind.found,
        species: ExploreSpecies.cat,
        status: ExploreStatus.active,
        days: 7,
        latitude: 0,
        longitude: 0,
        radiusMeters: 1000,
      );
      expect(
        container.read(exploreViewModelProvider).requireValue.items,
        isEmpty,
      );
      expect(repo.calls.last.$3, isNull);
      expect(repo.calls.last.$2.species, ExploreSpecies.cat);
      repo.pending!.complete(ExplorePage(items: []));
      await apply;
      expect(
        container.read(exploreViewModelProvider).requireValue.failed,
        false,
      );
    },
  );
  test(
    'Account changes hide previous content and discard late pagination; recovery after session error works',
    () async {
      final repo = SearchFake();
      final sessions = StreamController<AuthSession?>();
      addTearDown(sessions.close);
      final container = ProviderContainer(
        overrides: [
          exploreRepositoryProvider.overrideWithValue(repo),
          currentLocationRepositoryProvider.overrideWithValue(
            const FakeCurrentLocation(),
          ),
          exploreSessionProvider.overrideWith((ref) => sessions.stream),
        ],
      );
      addTearDown(container.dispose);
      final sub = container.listen(exploreViewModelProvider, (_, _) {});
      addTearDown(sub.close);
      await Future<void>.delayed(Duration.zero);
      sessions.add(const AuthSession(userId: 'a'));
      await container.read(exploreViewModelProvider.future);
      repo.pending = Completer();
      final late = repo.pending!;
      final work = container.read(exploreViewModelProvider.notifier).more();
      repo.pending = null;
      sessions.add(const AuthSession(userId: 'b'));
      await Future<void>.delayed(Duration.zero);
      await container.read(exploreViewModelProvider.future);
      late.complete(ExplorePage(items: [item('private-a')]));
      await work;
      expect(container.read(exploreViewModelProvider).requireValue.owner, 'b');
      expect(
        container
            .read(exploreViewModelProvider)
            .requireValue
            .items
            .any((i) => i.id == 'private-a'),
        false,
      );
      sessions.addError(Exception('session'));
      await Future<void>.delayed(Duration.zero);
      expect(container.read(exploreViewModelProvider).hasError, true);
      sessions.add(const AuthSession(userId: 'b'));
      await Future<void>.delayed(Duration.zero);
      expect(
        (await container.read(exploreViewModelProvider.future)).owner,
        'b',
      );
    },
  );
  for (final placement in FilterPanelPlacement.values) {
    testWidgets(
      'Filter exit retains its panel and reverses mid-opening $placement',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FilterExpansion<int>(
                label: 'Abrir selector',
                placement: placement,
                editorBuilder: (_, confirm) => TextButton(
                  onPressed: () => confirm(1),
                  child: const Text('Confirmar selección'),
                ),
                onApply: (_) {},
              ),
            ),
          ),
        );
        await tester.tap(find.text('Abrir selector'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 140));
        final panelOpacity = find
            .ancestor(
              of: find.text('Confirmar selección'),
              matching: find.byType(Opacity),
            )
            .first;
        final beforeClose = tester.widget<Opacity>(panelOpacity).opacity;
        await tester.tapAt(const Offset(790, 590));
        await tester.pump();
        expect(
          tester.widget<Opacity>(panelOpacity).opacity,
          closeTo(beforeClose, .001),
        );
        await tester.pump(const Duration(milliseconds: 80));
        expect(find.text('Confirmar selección'), findsOneWidget);
        expect(tester.widget<Opacity>(panelOpacity).opacity, greaterThan(0));
        await tester.pumpAndSettle();
        expect(find.text('Confirmar selección'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('Inline filters discard their editor when the host leaves', (
    tester,
  ) async {
    final visible = ValueNotifier(true);
    addTearDown(visible.dispose);
    int results = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: visible,
            builder: (context, show, _) => show
                ? FilterExpansion<int>(
                    label: 'Filtros de prueba',
                    editorBuilder: (context, confirm) => TextButton(
                      onPressed: () => confirm(1),
                      child: const Text('Confirmar'),
                    ),
                    onApply: (_) => results++,
                  )
                : const Text('Otra cuenta'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Filtros de prueba'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Confirmar'), findsOneWidget);
    visible.value = false;
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Otra cuenta'), findsOneWidget);
    expect(results, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  for (final small in [false, true]) {
    testWidgets(
      'Explore renders, opens a real detail route and keeps filters accessible ${small ? 'small' : 'normal'}',
      (tester) async {
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.runAsync(loadFonts);
        final repo = SearchFake();
        repo.pending = Completer();
        final initial = repo.pending!;
        final places = FakePlaceSearch();
        final photoUri = Uri.parse(
          'https://example.com/explore-grid-fixture.png',
        );
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
        repo.firstPage = [
          item('one', coverUri: photoUri),
          item('three', fromPet: false, coverUri: photoUri),
          item('four', name: 'Sol'),
        ];
        final key = GlobalKey();
        final router = GoRouter(
          initialLocation: '/home',
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, _) => HomeScreen(
                profileAvatar: const SizedBox(width: 40),
                exploreFloatingAction: ExploreMapButton(),
                exploreContent: ExploreSection(
                  locationSearchBuilder: (label, onSelect) => PlaceSearchFields(
                    initialLabel: label,
                    onSelect: onSelect,
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/home/cases/:id',
              builder: (_, s) =>
                  Scaffold(body: Text('Detalle ${s.pathParameters['id']}')),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              homeViewModelProvider.overrideWith(ExploreHome.new),
              placeSearchRepositoryProvider.overrideWithValue(places),
              placesSessionProvider.overrideWith(
                (_) => Stream.value(const AuthSession(userId: 'a')),
              ),
              exploreRepositoryProvider.overrideWithValue(repo),
              currentLocationRepositoryProvider.overrideWithValue(
                const FakeCurrentLocation(),
              ),
              exploreSessionProvider.overrideWith(
                (ref) => Stream.value(const AuthSession(userId: 'a')),
              ),
            ],
            child: MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
              builder: (_, child) => MediaQuery(
                data: MediaQueryData(
                  size: tester.view.physicalSize,
                  textScaler: TextScaler.linear(small ? 2 : 1),
                  disableAnimations: small,
                ),
                child: RepaintBoundary(key: key, child: child!),
              ),
            ),
          ),
        );
        await tester.pump();
        for (var frame = 0; frame < 120; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        await capture(tester, key, small, 'skeleton');
        initial.completeError(
          const ExploreFailure(ExploreFailureKind.unavailable),
        );
        repo.pending = null;
        await tester.pumpAndSettle();
        expect(find.text('Reintentar'), findsOneWidget);
        expect(find.byType(CollectionEmptyState), findsNothing);
        await capture(tester, key, small, 'error');
        await tester.pump(const Duration(seconds: 7));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Reintentar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Reintentar'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final cards = find.byType(EntityCardSurface);
        expect(cards, findsNWidgets(3));
        expect(find.text('Mascota perdida'), findsNothing);
        final first = tester.getRect(cards.at(0));
        final second = tester.getRect(cards.at(1));
        if (small) {
          expect(second.left, first.left);
          expect(second.top, greaterThan(first.bottom));
        } else {
          expect(second.top, first.top);
          expect(second.left, greaterThan(first.right));
          expect(first.left, 12);
          expect(second.right, tester.view.physicalSize.width - 12);
        }
        await tester.ensureVisible(find.byTooltip('Filtrar casos'));
        await tester.pumpAndSettle();
        final filterButton = tester.getRect(find.byTooltip('Filtrar casos'));
        expect(filterButton.size, const Size(48, 48));
        expect(find.text('Filtrar casos'), findsNothing);
        final locationButton = tester.getRect(
          find.byKey(const ValueKey('explore-location-filter')),
        );
        expect(locationButton.width, greaterThan(filterButton.width));
        if (!small) expect(locationButton.height, 48);
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .jumpTo(0);
        await tester.pumpAndSettle();
        await capture(tester, key, small, 'list');
        final horizontal = find.descendant(
          of: find.byType(ExploreCaseGrid),
          matching: find.byType(SingleChildScrollView),
        );
        expect(horizontal, findsNothing);
        if (!small) {
          final top = tester.getRect(cards.first).top;
          await tester.drag(cards.first, const Offset(0, -120));
          await tester.pumpAndSettle();
          expect(tester.getRect(cards.first).top, lessThan(top));
          expect(
            tester.getRect(cards.at(1)).right,
            tester.view.physicalSize.width - 12,
          );
          await capture(tester, key, small, 'vertical');
        }
        await tester.ensureVisible(cards.first);
        await tester.pumpAndSettle();
        await capture(tester, key, small, 'card');
        await tester.ensureVisible(find.byTooltip('Filtrar casos'));
        final collectionBounds = tester.getRect(cards.first);
        final callsBeforePanel = repo.calls.length;
        await tester.tap(find.byTooltip('Filtrar casos'));
        await tester.pumpAndSettle();
        expect(tester.getRect(cards.first).top, collectionBounds.top);
        expect(find.byType(Dialog), findsNothing);
        expect(repo.calls.length, callsBeforePanel);
        await capture(tester, key, small, 'filters-top');
        await tester.ensureVisible(find.text('Perdidas'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Perdidas'));
        await tester.pumpAndSettle();
        expect(repo.calls.length, callsBeforePanel);
        expect(
          tester
              .widget<FilterChoiceGroup<ExploreKind>>(
                find.byType(FilterChoiceGroup<ExploreKind>),
              )
              .value,
          ExploreKind.lost,
        );
        await tester.ensureVisible(find.byTooltip('Filtrar casos'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Filtrar casos'));
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        expect(repo.calls.length, callsBeforePanel);
        await tester.tap(find.byTooltip('Filtrar casos'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<FilterChoiceGroup<ExploreKind>>(
                find.byType(FilterChoiceGroup<ExploreKind>),
              )
              .value,
          ExploreKind.all,
        );
        await tester.ensureVisible(find.text('Perdidas'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Perdidas'));
        await tester.pumpAndSettle();
        expect(find.text('Por ubicación'), findsNothing);
        await tester.ensureVisible(find.text('Aplicar filtros'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Aplicar filtros'));
        await tester.pumpAndSettle();
        expect(repo.calls.last.$2.kind, ExploreKind.lost);
        final locationControl = find.byKey(
          const ValueKey('explore-location-filter'),
        );
        await tester.ensureVisible(locationControl);
        await tester.pumpAndSettle();
        final locationOrigin = tester.getRect(locationControl);
        await tester.tap(locationControl);
        await tester.pumpAndSettle();
        final locationPanel = tester.getRect(
          find
              .ancestor(
                of: find.text('Ubicación de búsqueda'),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(
          locationPanel.top,
          closeTo(locationOrigin.top.clamp(8, 844), .01),
        );
        expect(locationPanel.left, closeTo(locationOrigin.left, .01));
        await capture(tester, key, small, 'location-origin');
        expect(find.byType(FilterChoiceGroup<ExploreKind>), findsNothing);
        expect(find.text('Todas las ubicaciones'), findsNothing);
        await tester.ensureVisible(find.byType(TextField));
        await tester.enterText(find.byType(TextField), 'Miraflores');
        expect(places.queries, isEmpty);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
        expect(places.queries, ['Miraflores']);
        await tester.ensureVisible(find.text(FakePlaceSearch.place.label));
        await tester.pumpAndSettle();
        await tester.tap(find.text(FakePlaceSearch.place.label));
        await tester.pumpAndSettle();
        tester.widget<Slider>(find.byType(Slider)).onChanged!(25);
        await tester.pumpAndSettle();
        final map = tester.widget<ZoneMapPicker>(find.byType(ZoneMapPicker));
        expect(map.latitude, FakePlaceSearch.place.latitude);
        expect(map.longitude, FakePlaceSearch.place.longitude);
        expect(map.radiusMeters, 25000);
        expect(map.fitRadius, true);
        await tester.ensureVisible(find.byType(ZoneMapPicker));
        await tester.pumpAndSettle();
        // HTTP tile requests are intentionally unavailable in widget tests.
        // Allow the shared, temporary failure toast to complete before tapping.
        await tester.pump(const Duration(seconds: 7));
        await tester.pumpAndSettle();
        await capture(tester, key, small, 'zone');
        await tester.ensureVisible(find.text('Aplicar ubicación'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await capture(tester, key, small, 'filters');
        await tester.pump();
        final mapNotice = find.byKey(const ValueKey('feedback-toast'));
        if (mapNotice.evaluate().isNotEmpty) {
          await tester.tap(mapNotice);
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Aplicar ubicación'));
        await tester.pumpAndSettle();
        expect(repo.calls.last.$3, isNull);
        expect(repo.calls.last.$2.kind, ExploreKind.lost);
        expect(repo.calls.last.$2.radiusMeters, 25000);
        expect(repo.calls.last.$2.latitude, FakePlaceSearch.place.latitude);
        expect(
          find.descendant(
            of: locationControl,
            matching: find.text(FakePlaceSearch.place.label),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: locationControl, matching: find.text('25 km')),
          findsOneWidget,
        );
        await capture(tester, key, small, 'location-applied');
        expect(find.byType(Dialog), findsNothing);
        expect(tester.getRect(cards.first).size, collectionBounds.size);
        expect(find.byType(FilterChoiceGroup<ExploreKind>), findsNothing);
        await tester.tap(find.byTooltip('Filtrar casos'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<FilterChoiceGroup<ExploreKind>>(
                find.byType(FilterChoiceGroup<ExploreKind>),
              )
              .value,
          ExploreKind.lost,
        );
        await tester.ensureVisible(find.byTooltip('Filtrar casos'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Filtrar casos'));
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        repo.empty = true;
        final container = ProviderScope.containerOf(
          tester.element(find.byType(ExploreSection)),
        );
        await container.read(exploreViewModelProvider.notifier).refresh();
        await tester.pumpAndSettle();
        expect(find.text('No encontramos casos'), findsOneWidget);
        expect(find.byType(CollectionEmptyState), findsOneWidget);
        expect(
          find.text(
            'Prueba con otra ubicación o ajusta los filtros de búsqueda.',
          ),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text('No encontramos casos'));
        await tester.pumpAndSettle();
        await capture(tester, key, small, 'empty');
        repo.empty = false;
        await container.read(exploreViewModelProvider.notifier).refresh();
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Luna'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Luna'));
        await tester.pumpAndSettle();
        expect(find.text('Detalle one'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}

Future<void> capture(
  WidgetTester tester,
  GlobalKey key,
  bool small,
  String stage,
) async {
  if (!const bool.fromEnvironment('CAPTURE_EXPLORE')) return;
  await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
            .toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('build/ui-preview/explore')
      ..createSync(recursive: true);
    File(
      '${dir.path}/${small ? 'small' : 'normal'}-$stage.png',
    ).writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
