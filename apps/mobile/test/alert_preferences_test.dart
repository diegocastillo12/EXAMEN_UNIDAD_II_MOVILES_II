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
import 'package:flutter_application_entrehuellas/core/presentation/widgets/loading_shimmer.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/domain/entities/alert_preferences.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/domain/failures/preference_failure.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/domain/use_cases/manage_alert_preferences.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/providers/alert_preference_providers.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/presentation/view_models/alert_preferences_view_model.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/presentation/screens/alert_preferences_screen.dart';
import 'support/fake_alert_preferences.dart';
import 'app_test.dart' show FakeAuthRepository;

void main() {
  test(
    'Confirmed absence uses disabled defaults; errors stay errors; validation blocks empty enabled types/channels',
    () async {
      final repo = FakeAlertPreferences();
      final read = ReadAlertPreferences(repo);
      final save = SaveAlertPreferences(repo);
      final defaults = await read('one');
      expect(defaults.enabled, false);
      expect(defaults.push, false);
      expect(defaults.version, 0);
      expect(repo.rows, isEmpty);
      repo.failRead = true;
      await expectLater(read('one'), throwsA(isA<PreferenceFailure>()));
      await expectLater(
        save(
          defaults.copyWith(
            enabled: true,
            lostPets: false,
            foundPets: false,
            caseUpdates: false,
          ),
        ),
        throwsA(
          isA<PreferenceFailure>().having(
            (e) => e.kind,
            'kind',
            PreferenceFailureKind.invalidTypes,
          ),
        ),
      );
      await expectLater(
        save(defaults.copyWith(enabled: true, inApp: false, push: false)),
        throwsA(
          isA<PreferenceFailure>().having(
            (e) => e.kind,
            'kind',
            PreferenceFailureKind.invalidChannels,
          ),
        ),
      );
      expect(repo.writes, isEmpty);
      final paused = await save(
        defaults.copyWith(
          lostPets: false,
          foundPets: false,
          caseUpdates: false,
          inApp: false,
        ),
      );
      expect(paused.version, 1);
      repo.rows['two'] = const AlertPreferences(ownerId: 'foreign', version: 1);
      await expectLater(read('two'), throwsA(isA<PreferenceFailure>()));
      repo.failRead = false;
      await expectLater(read('two'), throwsA(isA<PreferenceFailure>()));
      repo.pendingSave = Completer<AlertPreferences>()
        ..complete(const AlertPreferences(ownerId: 'foreign', version: 2));
      await expectLater(
        save(paused.copyWith(enabled: false, push: true)),
        throwsA(isA<PreferenceFailure>()),
      );
    },
  );

  late FakeAlertPreferences repo;
  late FakeAuthRepository auth;
  late ProviderContainer container;
  setUp(() {
    repo = FakeAlertPreferences();
    auth = FakeAuthRepository()..current = const AuthSession(userId: 'one');
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        alertPreferenceRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await auth.controller.close();
  });
  Future<void> init() async {
    container.listen(alertPreferencesViewModelProvider, (_, _) {});
    await container.read(alertPreferencesViewModelProvider.future);
  }

  Future<void> tick() async {
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test(
    'Failed and lost-response saves retain version/choices; retry confirms once; pause preserves selected channels',
    () async {
      await init();
      final vm = container.read(alertPreferencesViewModelProvider.notifier);
      vm.edit(enabled: true, foundPets: false, push: true);
      final draft = container
          .read(alertPreferencesViewModelProvider)
          .requireValue
          .draft;
      repo.failSave = true;
      await vm.save();
      expect(
        container
            .read(alertPreferencesViewModelProvider)
            .requireValue
            .draft
            .sameChoices(draft),
        true,
      );
      expect(
        container
            .read(alertPreferencesViewModelProvider)
            .requireValue
            .confirmed,
        false,
      );
      // Server persisted before the response was lost. Retry must retain original version.
      repo.rows['one'] = draft.copyWith(version: 1);
      repo.failSave = false;
      await vm.save();
      expect(repo.writes.map((p) => p.version), [0, 0]);
      final saved = container
          .read(alertPreferencesViewModelProvider)
          .requireValue;
      expect(saved.confirmed, true);
      expect(saved.dirty, false);
      vm.edit(enabled: false);
      expect(
        container
            .read(alertPreferencesViewModelProvider)
            .requireValue
            .draft
            .push,
        true,
      );
      await vm.save();
      expect(repo.rows['one']!.enabled, false);
      expect(repo.rows['one']!.push, true);
      container.invalidate(alertPreferencesViewModelProvider);
      expect(
        (await container.read(
          alertPreferencesViewModelProvider.future,
        )).draft.version,
        2,
      );
      expect(
        container
            .read(alertPreferencesViewModelProvider)
            .requireValue
            .confirmed,
        false,
      );
    },
  );

  test(
    'Duplicate writes/edits are blocked; late old-account results and disposal cannot leak',
    () async {
      await init();
      final vm = container.read(alertPreferencesViewModelProvider.notifier);
      vm.edit(enabled: true);
      repo.pendingSave = Completer<AlertPreferences>();
      final pending = vm.save();
      await vm.save();
      vm.edit(push: true);
      expect(repo.writes.length, 1);
      expect(
        container
            .read(alertPreferencesViewModelProvider)
            .requireValue
            .draft
            .push,
        false,
      );
      auth.emit(const AuthSession(userId: 'two'));
      await tick();
      await container.read(alertPreferencesViewModelProvider.future);
      repo.pendingSave!.complete(repo.writes.single.copyWith(version: 1));
      await pending;
      expect(
        container
            .read(alertPreferencesViewModelProvider)
            .requireValue
            .saved
            .ownerId,
        'two',
      );
      expect(
        container
            .read(alertPreferencesViewModelProvider)
            .requireValue
            .confirmed,
        false,
      );
      repo.pendingSave = Completer<AlertPreferences>();
      vm.edit(enabled: true);
      final disposed = vm.save();
      container.dispose();
      repo.pendingSave!.complete(repo.writes.last.copyWith(version: 1));
      await disposed;
      container = ProviderContainer();
    },
  );

  test(
    'Refresh preserves content/draft on failure; conflicts require reload; same account recovers after stream error',
    () async {
      await init();
      final vm = container.read(alertPreferencesViewModelProvider.notifier);
      vm.edit(enabled: true);
      repo.rows['one'] = const AlertPreferences(
        ownerId: 'one',
        version: 1,
        push: true,
      );
      await vm.save();
      expect(
        container.read(alertPreferencesViewModelProvider).requireValue.issue,
        PreferenceFailureKind.conflict,
      );
      final reads = repo.reads;
      await vm.refresh();
      expect(repo.reads, reads);
      repo.pendingRead = Completer<AlertPreferences?>();
      final refreshing = vm.refresh(discardDraft: true);
      expect(
        container
            .read(alertPreferencesViewModelProvider)
            .requireValue
            .refreshing,
        true,
      );
      expect(
        container
            .read(alertPreferencesViewModelProvider)
            .requireValue
            .saved
            .ownerId,
        'one',
      );
      repo.pendingRead!.completeError(
        const PreferenceFailure(PreferenceFailureKind.unavailable),
      );
      await refreshing;
      expect(
        container
            .read(alertPreferencesViewModelProvider)
            .requireValue
            .draft
            .enabled,
        true,
      );
      repo.pendingRead = null;
      await vm.refresh(discardDraft: true);
      expect(
        container
            .read(alertPreferencesViewModelProvider)
            .requireValue
            .draft
            .push,
        true,
      );
      expect(
        container.read(alertPreferencesViewModelProvider).requireValue.dirty,
        false,
      );
      auth.controller.addError(StateError('private'));
      await tick();
      expect(container.read(alertPreferencesViewModelProvider).hasError, true);
      auth.emit(const AuthSession(userId: 'one'));
      await tick();
      expect(
        (await container.read(
          alertPreferencesViewModelProvider.future,
        )).saved.version,
        1,
      );
    },
  );

  for (final small in [false, true]) {
    testWidgets(
      'Preference choices, contextual failure/retry, pause and discard remain reachable; small=$small',
      (tester) async {
        if (const bool.fromEnvironment('CAPTURE_PREFERENCES')) {
          await tester.runAsync(loadFonts);
        }
        await tester.binding.setSurfaceSize(
          small ? const Size(320, 350) : const Size(390, 844),
        );
        addTearDown(() => tester.binding.setSurfaceSize(null));
        tester.platformDispatcher.textScaleFactorTestValue = small ? 2 : 1;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        repo.pendingRead = Completer<AlertPreferences?>();
        final boundary = GlobalKey();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: RepaintBoundary(
              key: boundary,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                home: const AlertPreferencesScreen(),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));
        expect(find.byType(SwitchListTile), findsNothing);
        expect(find.byType(LoadingShimmer), findsOneWidget);
        await capture(tester, boundary, small, 'loading');
        repo.pendingRead!.completeError(
          const PreferenceFailure(PreferenceFailureKind.unavailable),
        );
        await tester.pumpAndSettle();
        await capture(tester, boundary, small, 'read-error');
        repo.pendingRead = null;
        await tester.ensureVisible(find.text('Reintentar'));
        await tester.tap(find.text('Reintentar'));
        await tester.pumpAndSettle();
        expect(find.byType(SwitchListTile), findsNWidgets(6));
        await capture(tester, boundary, small, 'choices');
        Future<void> toggle(String label) async {
          final toast = find.byKey(const ValueKey('feedback-toast'));
          if (toast.evaluate().isNotEmpty) {
            await tester.tap(toast);
            await tester.pumpAndSettle();
          }
          await tester.ensureVisible(find.text(label));
          await tester.pumpAndSettle();
          final tile = find.ancestor(
            of: find.text(label),
            matching: find.byType(SwitchListTile),
          );
          final control = find.descendant(
            of: tile,
            matching: find.byType(Switch),
          );
          await tester.ensureVisible(control);
          await tester.pumpAndSettle();
          await tester.tap(control);
          await tester.pumpAndSettle();
        }

        await toggle('Recibir alertas');
        await toggle('Mascotas encontradas');
        await toggle('Notificaciones del teléfono');
        await capture(tester, boundary, small, 'channels');
        repo.failSave = true;
        await tester.ensureVisible(find.text('Guardar preferencias'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Guardar preferencias'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Tu selección se conserva'), findsOneWidget);
        await tester.ensureVisible(
          find.textContaining('Tu selección se conserva'),
        );
        await capture(tester, boundary, small, 'save-error');
        repo.failSave = false;
        await tester.tap(find.byKey(const ValueKey('feedback-toast')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Guardar preferencias'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Guardar preferencias'));
        await tester.pumpAndSettle();
        expect(repo.rows['one']!.push, true);
        expect(repo.rows['one']!.foundPets, false);
        expect(find.text('Preferencias guardadas'), findsOneWidget);
        await capture(tester, boundary, small, 'saved');
        await tester.pump(const Duration(seconds: 4));
        await toggle('Recibir alertas');
        expect(
          container
              .read(alertPreferencesViewModelProvider)
              .requireValue
              .draft
              .push,
          true,
        );
        await tester.ensureVisible(find.text('Descartar cambios'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Descartar cambios'));
        await tester.pumpAndSettle();
        await capture(tester, boundary, small, 'discard');
        await tester.ensureVisible(find.text('Cancelar'));
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(
          container.read(alertPreferencesViewModelProvider).requireValue.dirty,
          true,
        );
        await tester.tap(find.text('Descartar cambios'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Descartar'),
        );
        await tester.pumpAndSettle();
        await capture(tester, boundary, small, 'discard-actions');
        await tester.tap(find.widgetWithText(FilledButton, 'Descartar'));
        await tester.pumpAndSettle();
        expect(
          container.read(alertPreferencesViewModelProvider).requireValue.dirty,
          false,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<void> loadFonts() async {
  final configFile = File('.dart_tool/package_config.json').absolute;
  final config =
      jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
  final flutter = (config['packages'] as List)
      .cast<Map<String, dynamic>>()
      .firstWhere((p) => p['name'] == 'flutter');
  final root = configFile.uri
      .resolve('${flutter['rootUri']}/')
      .resolve('../../bin/cache/artifacts/material_fonts/');
  // The SDK archive preserves mixed-case filenames on Linux; Windows resolves
  // the old lowercase paths as well. Resolve the actual file on both systems.
  final fontFiles = {
    for (final file in Directory.fromUri(root).listSync().whereType<File>())
      file.uri.pathSegments.last.toLowerCase(): file,
  };
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
        (fontFiles[font] ?? (throw StateError('SDK font missing: $font')))
            .readAsBytes()
            .then(ByteData.sublistView),
      );
    }
    await loader.load();
  }
}

Future<void> capture(
  WidgetTester tester,
  GlobalKey key,
  bool small,
  String name,
) async {
  if (!const bool.fromEnvironment('CAPTURE_PREFERENCES')) return;
  await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
            .toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/ui-preview/preferences')
      ..createSync(recursive: true);
    File(
      '${directory.path}/${small ? 'small' : 'normal'}-$name.png',
    ).writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
