import 'support/fake_local_drafts.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/providers/local_draft_providers.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_public_cards.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/providers/lost_case_providers.dart';
import 'lost_cases_test.dart' show FakeCases;
import 'package:flutter_application_entrehuellas/core/presentation/widgets/zone_map_picker.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/immersive_photo_sheet.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/repositories/found_case_repository.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/use_cases/found_case_actions.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/providers/found_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/view_models/found_editor_view_model.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/view_models/found_read_view_model.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/state/found_editor_state.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/screens/found_editor_screen.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/screens/found_detail_screen.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/screens/my_found_cases_screen.dart';
import 'support/fake_password_recovery.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;

final jpeg = img.encodeJpg(img.Image(width: 32, height: 24));

class FakeFoundCases implements FoundCaseRepository {
  final attempts = <FoundCaseDraft>[];
  final discards = <String>[];
  final mine = <FoundPublication>[];
  bool loseResponse = false,
      wrongOwner = false,
      failRead = false,
      failDiscard = false,
      cancelPhoto = false;
  Completer<void>? pending, pendingRead, pendingDiscard;
  PublicFoundCase? publicCase;
  final searches = <RecoverySearch>[
    const RecoverySearch(
      id: 'case',
      community: false,
      name: 'Luna',
      species: 'dog',
    ),
  ];
  final observations = <PublicFoundCase>[];
  final resolvedSearches = <String>[];
  @override
  Future<List<RecoverySearch>> listOpenSearches(String owner) async => searches;
  @override
  Future<List<PublicFoundCase>> listObservations(
    String id,
    bool community,
  ) async => observations
      .where((o) => o.targetId == id && o.communityTarget == community)
      .toList();
  @override
  Future<void> resolveSearch(String owner, String id, bool community) async {
    resolvedSearches.add(id);
    final previous = publicCase;
    if (previous != null && previous.id == id) {
      publicCase = PublicFoundCase(
        id: id,
        status: 'resolved',
        occurredAt: previous.occurredAt,
        latitude: previous.latitude,
        longitude: previous.longitude,
        species: previous.species,
        traits: previous.traits,
        photos: previous.photos,
        reportKind: previous.reportKind,
      );
    }
  }

  @override
  Future<Uint8List?> choosePhoto(
    String owner,
    String id, {
    bool camera = false,
  }) async => cancelPhoto ? null : jpeg;
  @override
  Future<Uint8List?> recoverPhoto(String owner, String id) async => jpeg;
  @override
  Future<FoundPublication> publish(String owner, FoundCaseDraft draft) async {
    attempts.add(draft);
    await pending?.future;
    if (loseResponse) {
      loseResponse = false;
      throw const FoundFailure(FoundFailureKind.unavailable);
    }
    return FoundPublication(
      id: draft.id,
      reportKind: draft.reportKind,
      targetId: draft.targetId,
      communityTarget: draft.communityTarget,
      ownerId: wrongOwner ? 'foreign' : owner,
      status: 'active',
    );
  }

  @override
  Future<PublicFoundCase?> readPublic(String id) async {
    await pendingRead?.future;
    if (failRead) throw const FoundFailure(FoundFailureKind.unavailable);
    return publicCase;
  }

  @override
  Future<List<FoundPublication>> listMine(String owner) async =>
      mine.where((c) => c.ownerId == owner).toList();
  @override
  Future<void> discard(String owner, String id) async {
    discards.add(id);
    await pendingDiscard?.future;
    if (failDiscard) throw const FoundFailure(FoundFailureKind.conflict);
    mine.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> delete(String owner, String id) async {
    if (failDelete) throw const FoundFailure(FoundFailureKind.unavailable);
    await pendingDelete?.future;
    deletes.add(id);
    mine.removeWhere((c) => c.id == id);
  }

  bool failDelete = false;
  Completer<void>? pendingDelete;
  final deletes = <String>[];
}

FoundCaseDraft draft({
  double lat = -12.0464,
  String species = 'dog',
  String traits = 'Blanca',
  String? custody,
  List<FoundPhotoDraft>? photos,
  DateTime? time,
}) => FoundCaseDraft(
  id: 'report',
  occurredAt: time ?? DateTime.utc(2026, 10, 9),
  latitude: lat,
  longitude: -77.0428,
  placeReference: 'Referencia privada',
  species: species,
  traits: traits,
  custody: custody,
  photos: photos ?? [FoundPhotoDraft('photo', jpeg)],
);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => Directory.systemTemp.path,
        ),
  );
  tearDownAll(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        ),
  );
  late FakeAuthRepository auth;
  late FakeFoundCases cases;
  late ProviderContainer container;
  setUp(() {
    auth = FakeAuthRepository()..current = const AuthSession(userId: 'one');
    cases = FakeFoundCases();
    container = ProviderContainer(
      overrides: [
        localDraftRepositoryProvider.overrideWithValue(FakeLocalDrafts()),
        authRepositoryProvider.overrideWithValue(auth),
        foundCaseRepositoryProvider.overrideWithValue(cases),
        lostCaseRepositoryProvider.overrideWithValue(FakeCases()),
        startupStateProvider.overrideWithValue(
          const StartupState(StartupStatus.ready),
        ),
        onboardingRepositoryProvider.overrideWithValue(
          FakeOnboarding(auth)..completed.add('one'),
        ),
        passwordRecoveryRepositoryProvider.overrideWithValue(
          FakePasswordRecovery(),
        ),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await auth.controller.close();
  });
  Future<void> init() async {
    container.listen(foundEditorViewModelProvider, (_, _) {});
    await container.read(foundEditorViewModelProvider.future);
    final m = container.read(foundEditorViewModelProvider.notifier);
    m.edit(
      species: 'dog',
      traits: 'Blanca con manchas negras',
      occurredAt: DateTime.utc(2026, 10, 9),
      latitude: -12.0464,
      longitude: -77.0428,
      placeReference: 'Referencia privada',
    );
    await m.choosePhoto();
  }

  test(
    'Date and time remain independent and partial selection cannot publish',
    () async {
      final subscription = container.listen(
        foundEditorViewModelProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(foundEditorViewModelProvider.future);
      final model = container.read(foundEditorViewModelProvider.notifier);
      model.chooseDate(DateTime(2026, 10, 9));
      var value = container.read(foundEditorViewModelProvider).requireValue;
      expect(value.dateTimeDraft.date, DateTime(2026, 10, 9));
      expect(value.dateTimeDraft.hour, isNull);
      expect(value.occurredAt, isNull);
      model.chooseTime(14, 25);
      value = container.read(foundEditorViewModelProvider).requireValue;
      expect(value.occurredAt, DateTime(2026, 10, 9, 14, 25));
      model.chooseDate(DateTime(2026, 10, 8));
      expect(
        container.read(foundEditorViewModelProvider).requireValue.occurredAt,
        DateTime(2026, 10, 8, 14, 25),
      );
      model.chooseTime(8, 45);
      expect(
        container.read(foundEditorViewModelProvider).requireValue.occurredAt,
        DateTime(2026, 10, 8, 8, 45),
      );
    },
  );

  test(
    'Linked notices require an open-search reference and never call recovery confirmation',
    () async {
      final usecase = PublishFoundCase(cases);
      final base = draft();
      FoundCaseDraft notice(String? target) => FoundCaseDraft(
        id: base.id,
        occurredAt: base.occurredAt,
        latitude: base.latitude,
        longitude: base.longitude,
        placeReference: base.placeReference,
        species: base.species,
        traits: base.traits,
        photos: base.photos,
        reportKind: 'sighting',
        targetId: target,
      );
      await expectLater(
        usecase('one', notice(null)),
        throwsA(isA<FoundFailure>()),
      );
      expect(cases.attempts, isEmpty);
      await usecase('one', notice('case'));
      expect(cases.attempts.single.targetId, 'case');
      expect(cases.resolvedSearches, isEmpty);
    },
  );

  test(
    'Case removal retains failures, blocks duplicates and ignores old identity completion',
    () async {
      const open = FoundPublication(
        id: 'open',
        ownerId: 'one',
        status: 'active',
        species: 'dog',
      );
      const resolved = FoundPublication(
        id: 'done',
        ownerId: 'one',
        status: 'resolved',
        species: 'dog',
      );
      cases.mine.addAll([open, resolved]);
      container.listen(myFoundCasesViewModelProvider, (_, _) {});
      await container.read(myFoundCasesViewModelProvider.future);
      final model = container.read(myFoundCasesViewModelProvider.notifier);
      cases.failDelete = true;
      await model.delete(open);
      expect(
        container.read(myFoundCasesViewModelProvider).requireValue.cases.length,
        2,
      );
      expect(
        container
            .read(myFoundCasesViewModelProvider)
            .requireValue
            .noticeIsError,
        isTrue,
      );
      cases.failDelete = false;
      cases.pendingDelete = Completer<void>();
      final pending = model.delete(open);
      await model.delete(open);
      expect(
        container.read(myFoundCasesViewModelProvider).requireValue.busyId,
        'open',
      );
      cases.pendingDelete!.complete();
      await pending;
      expect(cases.deletes, ['open']);
      expect(
        container
            .read(myFoundCasesViewModelProvider)
            .requireValue
            .cases
            .map((c) => c.id),
        ['done'],
      );
      cases.pendingDelete = null;
      await model.delete(resolved);
      expect(cases.deletes, ['open', 'done']);
      expect(
        container.read(myFoundCasesViewModelProvider).requireValue.cases,
        isEmpty,
      );
      cases.mine.add(open);
      await model.retry();
      cases.pendingDelete = Completer<void>();
      final late = model.delete(open);
      auth.emit(const AuthSession(userId: 'two'));
      await Future<void>.delayed(Duration.zero);
      await container.read(myFoundCasesViewModelProvider.future);
      cases.pendingDelete!.complete();
      await late;
      expect(
        container.read(myFoundCasesViewModelProvider).requireValue.ownerId,
        'two',
      );
      expect(
        container.read(myFoundCasesViewModelProvider).requireValue.notice,
        isNull,
      );
    },
  );
  test(
    'Found publication needs no pet, validates metadata/photos and distrusts a foreign success',
    () async {
      final usecase = PublishFoundCase(cases);
      for (final invalid in [
        draft(lat: double.nan),
        draft(lat: 86),
        draft(species: 'other'),
        draft(traits: ''),
        draft(custody: 'address'),
        draft(photos: []),
        draft(
          photos: [
            FoundPhotoDraft('same', jpeg),
            FoundPhotoDraft('same', jpeg),
          ],
        ),
        draft(time: DateTime.now().add(const Duration(days: 1))),
      ]) {
        await expectLater(
          usecase('one', invalid),
          throwsA(isA<FoundFailure>()),
        );
      }
      expect(cases.attempts, isEmpty);
      final bytes = Uint8List.fromList(jpeg),
          photo = FoundPhotoDraft('copy', bytes);
      bytes[0] = 0;
      expect(photo.bytes[0], 255);
      expect(() => photo.bytes[0] = 0, throwsUnsupportedError);
      cases.wrongOwner = true;
      await expectLater(usecase('one', draft()), throwsA(isA<FoundFailure>()));
    },
  );
  test(
    'Missing fields mark the form; choosing is cancellable and photos are limited to three',
    () async {
      container.listen(foundEditorViewModelProvider, (_, _) {});
      await container.read(foundEditorViewModelProvider.future);
      final m = container.read(foundEditorViewModelProvider.notifier);
      m.preview();
      expect(
        container.read(foundEditorViewModelProvider).requireValue.invalidFields,
        containsAll(
          FoundField.values.where((field) => field != FoundField.target),
        ),
      );
      expect(cases.attempts, isEmpty);
      cases.cancelPhoto = true;
      await m.choosePhoto();
      expect(
        container.read(foundEditorViewModelProvider).requireValue.photos,
        isEmpty,
      );
      cases.cancelPhoto = false;
      for (var i = 0; i < 4; i++) {
        await m.choosePhoto();
      }
      expect(
        container.read(foundEditorViewModelProvider).requireValue.photos.length,
        3,
      );
      final id = container
          .read(foundEditorViewModelProvider)
          .requireValue
          .photos
          .first
          .id;
      m.removePhoto(id);
      expect(
        container.read(foundEditorViewModelProvider).requireValue.photos.length,
        2,
      );
    },
  );
  test(
    'A lost response freezes the identical request and blocks double submission and edits',
    () async {
      await init();
      final m = container.read(foundEditorViewModelProvider.notifier);
      m.preview();
      cases.pending = Completer<void>();
      cases.loseResponse = true;
      final first = m.publish();
      await Future<void>.delayed(Duration.zero);
      await m.publish();
      expect(cases.attempts.length, 1);
      cases.pending!.complete();
      await first;
      final locked = container
          .read(foundEditorViewModelProvider)
          .requireValue
          .lockedDraft;
      expect(locked, isNotNull);
      m.edit(traits: 'Cambio');
      m.removePhoto(locked!.photos.first.id);
      m.backToForm();
      expect(
        container.read(foundEditorViewModelProvider).requireValue.traits,
        'Blanca con manchas negras',
      );
      await m.publish();
      expect(cases.attempts[1].id, cases.attempts[0].id);
      expect(cases.attempts[1].occurredAt, cases.attempts[0].occurredAt);
      expect(cases.attempts[1].traits, cases.attempts[0].traits);
      expect(
        cases.attempts[1].photos.map((p) => p.id),
        cases.attempts[0].photos.map((p) => p.id),
      );
      expect(
        cases.attempts[1].photos.first.bytes,
        cases.attempts[0].photos.first.bytes,
      );
      expect(
        container.read(foundEditorViewModelProvider).requireValue.stage,
        FoundStage.confirmed,
      );
    },
  );
  test(
    'Discard requires server confirmation after a write and never hides a conflict',
    () async {
      await init();
      final m = container.read(foundEditorViewModelProvider.notifier);
      m.preview();
      cases.loseResponse = true;
      await m.publish();
      cases.failDiscard = true;
      expect(await m.discard(), false);
      expect(
        container.read(foundEditorViewModelProvider).requireValue.dirty,
        true,
      );
      cases.failDiscard = false;
      expect(await m.discard(), true);
      expect(cases.discards.length, 2);
    },
  );
  test(
    'Identity changes ignore old publication and recover the same session after errors',
    () async {
      await init();
      final m = container.read(foundEditorViewModelProvider.notifier);
      m.preview();
      cases.pending = Completer<void>();
      final publishing = m.publish();
      auth.current = const AuthSession(userId: 'two');
      auth.controller.add(auth.current);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await container.read(foundEditorViewModelProvider.future);
      cases.pending!.complete();
      await publishing;
      expect(
        container.read(foundEditorViewModelProvider).requireValue.ownerId,
        'two',
      );
      expect(
        container.read(foundEditorViewModelProvider).requireValue.published,
        isNull,
      );
      auth.controller.addError(StateError('session interrupted'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(container.read(foundEditorViewModelProvider).hasError, true);
      auth.controller.add(auth.current);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(
        (await container.read(foundEditorViewModelProvider.future)).ownerId,
        'two',
      );
    },
  );
  test(
    'Public refresh retains same-account content on error and clears it on identity changes',
    () async {
      cases.publicCase = PublicFoundCase(
        id: 'case',
        status: 'active',
        occurredAt: DateTime.utc(2026, 10, 9),
        latitude: -12.045,
        longitude: -77.045,
        species: 'dog',
        traits: 'Blanca',
        photos: [],
      );
      container.listen(publicFoundViewModelProvider('case'), (_, _) {});
      await container.read(publicFoundViewModelProvider('case').future);
      cases.failRead = true;
      await container
          .read(publicFoundViewModelProvider('case').notifier)
          .retry();
      expect(
        container.read(publicFoundViewModelProvider('case')).requireValue.value,
        isNotNull,
      );
      expect(
        container
            .read(publicFoundViewModelProvider('case'))
            .requireValue
            .refreshFailed,
        true,
      );
      cases.pendingRead = Completer<void>();
      auth.current = const AuthSession(userId: 'two');
      auth.controller.add(auth.current);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(
        container.read(publicFoundViewModelProvider('case')).isLoading,
        true,
      );
      cases.pendingRead!.complete();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(
        container.read(publicFoundViewModelProvider('case')).hasError,
        true,
      );
    },
  );
  testWidgets(
    'Bound notice entry preserves dirty dismissal without pet providers',
    (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const EntreHuellasApp(),
        ),
      );
      await tester.pumpAndSettle();
      container.read(routerProvider).go('/home');
      await tester.pumpAndSettle();
      cases.publicCase = PublicFoundCase(
        id: 'case',
        status: 'active',
        occurredAt: DateTime(2026, 10, 9),
        latitude: -12.04,
        longitude: -77.04,
        species: 'dog',
        traits: 'Collar azul',
        photos: [],
      );
      container
          .read(routerProvider)
          .go('/home/found-cases/new?case=case&community=true');
      await tester.pumpAndSettle();
      expect(find.text('Caso abierto'), findsNothing);
      expect(find.text('¿Qué ocurrió?'), findsOneWidget);
      ProviderScope.containerOf(
        tester.element(find.byType(FoundEditorScreen)),
      ).read(foundEditorViewModelProvider.notifier).edit(traits: 'Borrador');
      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();
      expect(find.text('¿Salir del reporte?'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(
        ProviderScope.containerOf(
          tester.element(find.byType(FoundEditorScreen)),
        ).read(foundEditorViewModelProvider).requireValue.traits,
        'Borrador',
      );
      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salir'));
      await tester.pumpAndSettle();
      expect(find.text('Caso abierto'), findsNothing);
      container.read(routerProvider).go('/home/found-cases/new');
      await tester.pumpAndSettle();
      expect(
        container.read(routerProvider).routeInformationProvider.value.uri.path,
        '/home',
      );
      expect(find.byType(FoundEditorScreen), findsNothing);
      auth.current = null;
      auth.controller.add(null);
      await tester.pumpAndSettle();
      container.read(routerProvider).go('/home/found-cases/new');
      await tester.pumpAndSettle();
      expect(find.text('Iniciar sesión'), findsWidgets);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'Pending found uploads are distinct from published cases and discard requires confirmation',
    (tester) async {
      cases.mine.add(
        const FoundPublication(id: 'pending', ownerId: 'one', status: 'draft'),
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MyFoundCasesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Envío pendiente sin publicar'), findsOneWidget);
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(cases.discards, isEmpty);
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Descartar'));
      await tester.pumpAndSettle();
      expect(cases.discards, ['pending']);
      expect(find.text('Envío pendiente sin publicar'), findsNothing);
      cases.mine.add(
        const FoundPublication(id: 'late', ownerId: 'one', status: 'discarded'),
      );
      await container.read(myFoundCasesViewModelProvider.notifier).retry();
      await tester.pumpAndSettle();
      expect(find.text('Limpieza de fotos pendiente'), findsOneWidget);
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Descartar'));
      await tester.pumpAndSettle();
      expect(cases.discards, ['pending', 'late']);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  for (final size in [const Size(390, 844), const Size(320, 350)]) {
    testWidgets(
      'Found form/preview/errors/actions/public fit $size with scaled text',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final capture = Platform.environment['CAPTURE_FOUND_CASES'] == '1';
        if (capture) {
          await tester.runAsync(() async {
            final configFile = File('.dart_tool/package_config.json');
            final config =
                jsonDecode(await configFile.readAsString())
                    as Map<String, dynamic>;
            final flutter = (config['packages'] as List)
                .cast<Map<String, dynamic>>()
                .firstWhere((p) => p['name'] == 'flutter');
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
              for (final file in entry.value) {
                loader.addFont(
                  File.fromUri(
                    root.resolve(file),
                  ).readAsBytes().then(ByteData.sublistView),
                );
              }
              await loader.load();
            }
          });
        }
        final boundary = GlobalKey();
        Future<void> shot(String name) async {
          if (!capture) return;
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 100)),
          );
          void repaint(RenderObject object) {
            object.markNeedsPaint();
            object.visitChildren(repaint);
          }

          repaint(boundary.currentContext!.findRenderObject()!);
          await tester.pump();
          await tester.pump();
          await tester.runAsync(() async {
            final render =
                boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary;
            final image = await render.toImage();
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            final folder = Directory('build/ui-preview/found-cases')
              ..createSync(recursive: true);
            await File(
              '${folder.path}/${size.width.toInt()}-$name.png',
            ).writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }

        Widget host(Widget child) => UncontrolledProviderScope(
          container: container,
          child: RepaintBoundary(
            key: boundary,
            child: MaterialApp(
              theme: AppTheme.light,
              home: MediaQuery(
                data: MediaQueryData(
                  size: size,
                  textScaler: TextScaler.linear(size.width == 320 ? 2 : 1),
                ),
                child: child,
              ),
            ),
          ),
        );
        await tester.pumpWidget(host(const FoundEditorScreen()));
        await tester.pumpAndSettle();
        await tester.runAsync(init);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await shot('form');
        final m = container.read(foundEditorViewModelProvider.notifier);
        // Decode local preview bytes outside FakeAsync before settling animations.
        await tester.runAsync(() async {
          for (final photo
              in container
                  .read(foundEditorViewModelProvider)
                  .requireValue
                  .photos) {
            await precacheImage(
              MemoryImage(photo.bytes),
              tester.element(find.byType(FoundEditorScreen)),
            );
          }
        });
        m.preview();
        await tester.pumpAndSettle();
        expect(find.text('Referencia privada'), findsNothing);
        expect(find.byType(ZoneMapPicker), findsNothing);
        final sheetForpreviewMap = tester.widget<DraggableScrollableSheet>(
          find.byType(DraggableScrollableSheet),
        );
        sheetForpreviewMap.controller!.animateTo(
          sheetForpreviewMap.maxChildSize,
          duration: const Duration(milliseconds: 1),
          curve: Curves.linear,
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byType(ZoneMapPicker, skipOffstage: false),
        );
        await tester.pumpAndSettle();
        final previewMap = tester.widget<ZoneMapPicker>(
          find.byType(ZoneMapPicker),
        );
        final composition = tester.widget<ImmersivePhotoSheet>(
          find.byType(ImmersivePhotoSheet),
        );
        expect(previewMap.latitude, composition.latitude);
        expect(previewMap.longitude, composition.longitude);
        expect(previewMap.readOnly, isTrue);
        expect(previewMap.showCenterMarker, isFalse);
        expect(find.byType(ImmersivePhotoSheet), findsOneWidget);
        await shot('preview');
        cases.loseResponse = true;
        await tester.runAsync(m.publish);
        await tester.pumpAndSettle();
        await shot('error');
        const message =
            'No pudimos confirmar la operación. Conservamos los datos para reintentar.';
        expect(find.text(message), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(SingleChildScrollView).first,
            matching: find.text(message),
          ),
          findsNothing,
        );
        await tester.tap(find.byKey(const ValueKey('feedback-toast')));
        await tester.pumpAndSettle();
        expect(find.text(message), findsNothing);
        final publish = find.widgetWithText(FilledButton, 'Publicar caso');
        await tester.ensureVisible(publish);
        await tester.pumpAndSettle();
        expect(tester.getRect(publish).bottom, lessThanOrEqualTo(size.height));
        expect(tester.takeException(), isNull);
        await shot('actions');
        await tester.runAsync(m.publish);
        await tester.pumpAndSettle();
        expect(find.text('Búsqueda publicada'), findsOneWidget);
        await shot('confirmed');
        cases.publicCase = PublicFoundCase(
          id: 'case',
          status: 'active',
          occurredAt: DateTime.utc(2026, 10, 9),
          latitude: -12.045,
          longitude: -77.045,
          species: 'dog',
          traits: 'Blanca con manchas negras',
          custody: 'with_me',
          photos: [],
        );
        await tester.pumpWidget(host(const FoundDetailScreen(id: 'case')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(CasePublicCards), findsOneWidget);
        expect(find.byType(PageView), findsNothing);
        expect(find.byType(ZoneMapPicker), findsOneWidget);
        await tester.ensureVisible(
          find.byType(ZoneMapPicker, skipOffstage: false),
        );
        await tester.pumpAndSettle();
        final publicMap = tester.widget<ZoneMapPicker>(
          find.byType(ZoneMapPicker),
        );
        expect(publicMap.latitude, -12.045);
        expect(publicMap.longitude, -77.045);
        expect(publicMap.readOnly, isTrue);
        expect(publicMap.showCenterMarker, isFalse);
        expect(publicMap.onSelect, isNull);
        expect(publicMap.radiusMeters, 1000);
        expect(find.text('Ficha pública'), findsOneWidget);
        expect(find.text('Vista previa pública'), findsNothing);
        expect(find.text('Publicar caso'), findsNothing);
        expect(find.text('Editar reporte'), findsNothing);
        await shot('public');
        expect(find.text('Volver a consultar'), findsNothing);
        expect(find.text('Reintentar'), findsNothing);
        expect(tester.takeException(), isNull);
        await shot('public-actions');
        cases.mine.add(
          const FoundPublication(
            id: 'pending',
            ownerId: 'one',
            status: 'draft',
          ),
        );
        container.invalidate(myFoundCasesViewModelProvider);
        await tester.pumpWidget(host(const MyFoundCasesScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Envío pendiente sin publicar'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await shot('pending');
        await tester.ensureVisible(find.text('Descartar'));
        await tester.pumpAndSettle();
        await shot('pending-actions');
        cases.mine[0] = const FoundPublication(
          id: 'pending',
          ownerId: 'one',
          status: 'discarded',
        );
        await tester.runAsync(
          container.read(myFoundCasesViewModelProvider.notifier).retry,
        );
        await tester.pumpAndSettle();
        await shot('cleanup');
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
