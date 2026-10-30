import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/domain/entities/interest_zone.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/domain/entities/zone_point.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/domain/failures/zone_failure.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/domain/repositories/interest_zone_repository.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/domain/use_cases/manage_interest_zones.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/providers/interest_zone_providers.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/presentation/screens/interest_zones_screen.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/presentation/view_models/interest_zones_view_model.dart';
import 'app_test.dart' show FakeAuthRepository;

class FakeZones implements InterestZoneRepository {
  final rows = <String, InterestZone>{};
  bool failSave = false;
  bool failRead = false;
  bool failDelete = false;
  int saves = 0;
  int deletes = 0;
  Completer<InterestZone>? pendingSave;
  Completer<List<InterestZone>>? pendingRead;
  @override
  Future<List<InterestZone>> list(String owner) async {
    if (pendingRead != null) return pendingRead!.future;
    if (failRead) throw const ZoneFailure(ZoneFailureKind.network);
    return rows.values.where((zone) => zone.ownerId == owner).toList();
  }

  @override
  Future<InterestZone> save(String owner, ZoneDraft draft) async {
    saves++;
    if (pendingSave != null) return pendingSave!.future;
    if (failSave) throw const ZoneFailure(ZoneFailureKind.network);
    final row = InterestZone(
      id: draft.id,
      ownerId: owner,
      name: draft.name,
      latitude: draft.latitude!,
      longitude: draft.longitude!,
      radiusMeters: draft.radiusMeters,
      version: draft.version + 1,
    );
    rows[draft.id] = row;
    return row;
  }

  @override
  Future<void> delete(String owner, InterestZone zone) async {
    deletes++;
    if (failDelete) throw const ZoneFailure(ZoneFailureKind.network);
    rows.remove(zone.id);
  }
}

const zone = InterestZone(
  id: 'zone',
  ownerId: 'one',
  name: 'Parque',
  latitude: -12.04,
  longitude: -77.04,
  radiusMeters: 1000,
  version: 1,
);
const draft = ZoneDraft(
  id: 'zone',
  name: 'Parque',
  latitude: -12.04,
  longitude: -77.04,
  radiusMeters: 1000,
);

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
  test(
    'Required fields, Unicode, finite coordinates and radius bounds block writes; foreign owner cannot delete',
    () async {
      final repo = FakeZones();
      final save = SaveInterestZone(repo);
      for (final invalid in [
        draft.copyWith(name: ' '),
        draft.copyWith(name: '🐾' * 61),
        draft.copyWith(latitude: double.nan),
        draft.copyWith(longitude: double.infinity),
        draft.copyWith(latitude: 86),
        draft.copyWith(longitude: 181),
        draft.copyWith(radiusMeters: 99),
        draft.copyWith(radiusMeters: 50001),
      ]) {
        await expectLater(save('one', invalid), throwsA(isA<ZoneFailure>()));
      }
      await expectLater(
        save(
          'one',
          const ZoneDraft(
            id: 'zone',
            name: 'Zone',
            latitude: null,
            longitude: null,
            radiusMeters: 1000,
          ),
        ),
        throwsA(isA<ZoneFailure>()),
      );
      expect(repo.saves, 0);
      expect(
        () => DeleteInterestZone(repo)('two', zone),
        throwsA(isA<ZoneFailure>()),
      );
      expect(repo.deletes, 0);
      final saved = await save('one', draft.copyWith(name: ' 🐾 '));
      expect(saved.name, '🐾');
      expect(ZonePoint.parse('-12,04', '-77.04').latitude, -12.04);
    },
  );

  late ProviderContainer container;
  late FakeAuthRepository auth;
  late FakeZones repo;
  setUp(() {
    auth = FakeAuthRepository()..current = const AuthSession(userId: 'one');
    repo = FakeZones();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        interestZoneRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await auth.controller.close();
  });
  Future<void> init() async {
    container.listen(interestZonesViewModelProvider, (_, _) {});
    await container.read(interestZonesViewModelProvider.future);
  }

  Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 20));

  test(
    'Save failure preserves stable draft; confirmed create/edit/delete and discard use server results',
    () async {
      await init();
      final vm = container.read(interestZonesViewModelProvider.notifier);
      vm.startEditor();
      vm.edit(name: 'Casa', latitude: -12, longitude: -77, radiusMeters: 1500);
      final id = container
          .read(interestZonesViewModelProvider)
          .requireValue
          .draft!
          .id;
      repo.failSave = true;
      await vm.save();
      var current = container.read(interestZonesViewModelProvider).requireValue;
      expect(current.draft!.id, id);
      expect(current.confirmation, isNull);
      expect(current.busy, false);
      repo.failSave = false;
      await vm.save();
      current = container.read(interestZonesViewModelProvider).requireValue;
      expect(current.zones.single.id, id);
      expect(current.draft, isNull);
      vm.startEditor(current.zones.single);
      vm.edit(name: 'Casa nueva');
      await vm.save();
      current = container.read(interestZonesViewModelProvider).requireValue;
      expect(current.zones.single.version, 2);
      vm.startEditor(current.zones.single);
      vm.edit(name: 'Sin guardar');
      vm.discard();
      expect(
        container
            .read(interestZonesViewModelProvider)
            .requireValue
            .zones
            .single
            .name,
        'Casa nueva',
      );
      repo.failDelete = true;
      await vm.delete(current.zones.single);
      expect(
        container.read(interestZonesViewModelProvider).requireValue.zones,
        hasLength(1),
      );
      repo.failDelete = false;
      await vm.delete(current.zones.single);
      expect(
        container.read(interestZonesViewModelProvider).requireValue.zones,
        isEmpty,
      );
    },
  );
  test(
    'Busy save prevents duplicates; account changes discard late confirmation and draft',
    () async {
      await init();
      final vm = container.read(interestZonesViewModelProvider.notifier);
      vm.startEditor();
      vm.edit(name: 'Casa', latitude: -12, longitude: -77);
      final oldDraft = container
          .read(interestZonesViewModelProvider)
          .requireValue
          .draft!;
      repo.pendingSave = Completer<InterestZone>();
      final operation = vm.save();
      await vm.save();
      expect(repo.saves, 1);
      auth.emit(const AuthSession(userId: 'two'));
      await tick();
      var current = await container.read(interestZonesViewModelProvider.future);
      expect(current.ownerId, 'two');
      expect(current.draft, isNull);
      repo.pendingSave!.complete(
        InterestZone(
          id: oldDraft.id,
          ownerId: 'one',
          name: 'Casa',
          latitude: -12,
          longitude: -77,
          radiusMeters: 1000,
          version: 1,
        ),
      );
      await operation;
      current = container.read(interestZonesViewModelProvider).requireValue;
      expect(current.ownerId, 'two');
      expect(current.confirmation, isNull);
      expect(current.zones, isEmpty);
    },
  );
  test(
    'Refresh retains content and preserves draft on failure; stream error recovers same identity',
    () async {
      repo.rows[zone.id] = zone;
      await init();
      final vm = container.read(interestZonesViewModelProvider.notifier);
      vm.startEditor(zone);
      vm.edit(name: 'Borrador');
      repo.pendingRead = Completer<List<InterestZone>>();
      final operation = vm.refresh();
      expect(
        container.read(interestZonesViewModelProvider).requireValue.refreshing,
        true,
      );
      vm.edit(name: 'Edición durante refresh');
      expect(
        container
            .read(interestZonesViewModelProvider)
            .requireValue
            .zones
            .single
            .name,
        'Parque',
      );
      repo.pendingRead!.completeError(
        const ZoneFailure(ZoneFailureKind.network),
      );
      await operation;
      repo.pendingRead = null;
      expect(
        container.read(interestZonesViewModelProvider).requireValue.draft!.name,
        'Edición durante refresh',
      );
      auth.controller.addError(StateError('expired'));
      await tick();
      expect(container.read(interestZonesViewModelProvider).hasError, true);
      auth.emit(const AuthSession(userId: 'one'));
      await tick();
      final recovered = await container.read(
        interestZonesViewModelProvider.future,
      );
      expect(recovered.ownerId, 'one');
      expect(recovered.zones.single.name, 'Parque');
    },
  );
  test(
    'Invalid coordinate input remains contextual and does not mutate selected point',
    () async {
      await init();
      final vm = container.read(interestZonesViewModelProvider.notifier);
      vm.startEditor();
      vm.chooseCoordinates('NaN', '181');
      expect(
        container.read(interestZonesViewModelProvider).requireValue.issue,
        ZoneFailureKind.invalidPoint,
      );
      expect(
        container
            .read(interestZonesViewModelProvider)
            .requireValue
            .draft!
            .latitude,
        isNull,
      );
      vm.chooseCoordinates('-12,1', '-77,2');
      expect(
        container.read(interestZonesViewModelProvider).requireValue.issue,
        isNull,
      );
      expect(
        container
            .read(interestZonesViewModelProvider)
            .requireValue
            .draft!
            .longitude,
        -77.2,
      );
    },
  );

  for (final small in [false, true]) {
    testWidgets(
      'Zones empty/list/editor/error supports scroll, discard and text scaling small=$small',
      (tester) async {
        if (const bool.fromEnvironment('CAPTURE_ZONES')) {
          await tester.runAsync(() async {
            final configFile = File('.dart_tool/package_config.json').absolute;
            final config =
                jsonDecode(await configFile.readAsString())
                    as Map<String, dynamic>;
            final flutter = (config['packages'] as List)
                .cast<Map<String, dynamic>>()
                .firstWhere((package) => package['name'] == 'flutter');
            final root = configFile.uri
                .resolve('${flutter['rootUri']}/')
                .resolve('../../bin/cache/artifacts/material_fonts/');
            for (final entry in {
              'sans-serif': [
                'roboto-regular.ttf',
                'roboto-medium.ttf',
                'roboto-bold.ttf',
              ],
              'MaterialIcons': ['materialicons-regular.otf'],
            }.entries) {
              final loader = FontLoader(entry.key);
              for (final font in entry.value) {
                loader.addFont(
                  File.fromUri(
                    root.resolve(font),
                  ).readAsBytes().then(ByteData.sublistView),
                );
              }
              await loader.load();
            }
          });
        }
        final size = small ? const Size(320, 350) : const Size(390, 844);
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        tester.platformDispatcher.textScaleFactorTestValue = small ? 2 : 1;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final key = GlobalKey();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: RepaintBoundary(
              key: key,
              child: MaterialApp(
                theme: AppTheme.light,
                home: const InterestZonesScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        Future<void> capture(String name) async {
          if (!const bool.fromEnvironment('CAPTURE_ZONES')) return;
          await tester.runAsync(() async {
            final boundary =
                key.currentContext!.findRenderObject() as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final directory = Directory('build/ui-preview/zones')
              ..createSync(recursive: true);
            File(
              '${directory.path}/${small ? 'small' : 'normal'}-$name.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        expect(
          find.text('Todavía no tienes ubicaciones de interés.'),
          findsOneWidget,
        );
        await capture('empty');
        final vm = container.read(interestZonesViewModelProvider.notifier);
        vm.startEditor();
        await tester.pumpAndSettle();
        await capture('editor');
        expect(tester.takeException(), isNull);
        await tester.enterText(find.byType(TextFormField).first, 'Casa');
        await tester.ensureVisible(find.text('Indicar coordenadas'));
        await tester.tap(find.text('Indicar coordenadas'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.widgetWithText(TextField, 'Latitud'));
        await tester.enterText(
          find.widgetWithText(TextField, 'Latitud'),
          '-12',
        );
        await tester.ensureVisible(find.widgetWithText(TextField, 'Longitud'));
        await tester.enterText(
          find.widgetWithText(TextField, 'Longitud'),
          '-77',
        );
        await tester.ensureVisible(find.text('Usar coordenadas'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Usar coordenadas'));
        await tester.pumpAndSettle();
        expect(
          container
              .read(interestZonesViewModelProvider)
              .requireValue
              .draft!
              .latitude,
          -12,
        );
        repo.failSave = true;
        await vm.save();
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Guardar ubicación'));
        await tester.pumpAndSettle();
        await capture('save-error');
        expect(find.textContaining('Tus cambios se conservan'), findsOneWidget);
        repo.failSave = false;
        await vm.save();
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 7));
        expect(find.text('Casa'), findsOneWidget);
        await capture('list');
        expect(tester.takeException(), isNull);
        vm.startEditor(
          container
              .read(interestZonesViewModelProvider)
              .requireValue
              .zones
              .single,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Volver a mis ubicaciones'));
        await tester.pumpAndSettle();
        expect(find.text('¿Descartar cambios?'), findsOneWidget);
        await capture('discard-confirmation');
        await tester.ensureVisible(find.text('Descartar'));
        await tester.tap(find.text('Descartar'));
        await tester.pumpAndSettle();
        expect(find.text('Casa'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
