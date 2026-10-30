import 'support/fake_local_drafts.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/providers/local_draft_providers.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'alert_preferences_test.dart' show loadFonts;
import 'package:flutter_application_entrehuellas/app/screens/lost_report_screen.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/providers/found_case_providers.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'found_cases_test.dart' show FakeFoundCases;
import 'support/fake_password_recovery.dart';
import 'support/fake_pets.dart';
import 'support/fake_pet_photos.dart';

import 'package:flutter_application_entrehuellas/features/lost_cases/domain/entities/lost_case.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/providers/lost_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/view_models/recovery_reports_view_model.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/screens/recovery_reports_screen.dart';
import 'lost_cases_test.dart' show FakeCases;

class ActivityFound extends FakeFoundCases {
  bool failList = false;
  Completer<void>? pendingList;
  @override
  Future<List<FoundPublication>> listMine(String owner) async {
    final rows = await super.listMine(owner);
    await pendingList?.future;
    if (failList) throw const FoundFailure(FoundFailureKind.unavailable);
    return rows;
  }
}

const own = PublishedLostCase(
  id: 'same',
  ownerId: 'one',
  petId: 'pet',
  status: 'active',
  petName: 'Luna',
);
const community = FoundPublication(
  id: 'same',
  ownerId: 'one',
  status: 'active',
  species: 'dog',
  reportKind: 'possible_loss',
);
const notice = FoundPublication(
  id: 'notice',
  ownerId: 'one',
  status: 'resolved',
  species: 'cat',
  reportKind: 'sighting',
);

void main() {
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
  test(
    'Unified reports retain both sources, refresh failures and reject stale identity responses',
    () async {
      final auth = FakeAuthRepository()
        ..current = const AuthSession(userId: 'one');
      final cases = FakeCases()..mine.add(own);
      final reports = ActivityFound()..mine.addAll([community, notice]);
      final scope = ProviderContainer(
        overrides: [
          localDraftRepositoryProvider.overrideWithValue(FakeLocalDrafts()),
          authRepositoryProvider.overrideWithValue(auth),
          lostCaseRepositoryProvider.overrideWithValue(cases),
          foundCaseRepositoryProvider.overrideWithValue(reports),
        ],
      );
      final subscription = scope.listen(
        recoveryReportsViewModelProvider,
        (_, _) {},
      );
      addTearDown(() async {
        subscription.close();
        scope.dispose();
        await auth.controller.close();
      });
      final initial = await scope.read(recoveryReportsViewModelProvider.future);
      expect(initial.reports.map((r) => r.key).toSet(), {
        'pet:same',
        'community:same',
        'community:notice',
      });
      final model = scope.read(recoveryReportsViewModelProvider.notifier);
      await model.remove(initial.reports.singleWhere((r) => r.fromPet));
      expect(cases.deletes, ['same']);
      expect(reports.deletes, isEmpty);
      expect(
        scope
            .read(recoveryReportsViewModelProvider)
            .requireValue
            .reports
            .map((r) => r.key),
        contains('community:same'),
      );
      reports.failList = true;
      await model.retry();
      expect(
        scope.read(recoveryReportsViewModelProvider).requireValue.refreshFailed,
        true,
      );
      expect(
        scope
            .read(recoveryReportsViewModelProvider)
            .requireValue
            .reports
            .length,
        2,
      );
      reports.failList = false;
      reports.pendingList = Completer<void>();
      final refresh = model.retry();
      auth.emit(const AuthSession(userId: 'two'));
      await Future<void>.delayed(Duration.zero);
      expect(scope.read(recoveryReportsViewModelProvider).isLoading, true);
      reports.pendingList!.complete();
      await refresh;
      final next = await scope.read(recoveryReportsViewModelProvider.future);
      expect(next.ownerId, 'two');
      expect(next.reports, isEmpty);
    },
  );
  for (final small in [false, true]) {
    testWidgets(
      'Report opens lost form directly; unified reports remain reachable; small=$small',
      (tester) async {
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.platformDispatcher.textScaleFactorTestValue = small ? 2 : 1;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        if (Platform.environment['CAPTURE_REPORT_MENU'] == '1') {
          await tester.runAsync(loadFonts);
        }
        final auth = FakeAuthRepository()
          ..current = const AuthSession(userId: 'one');
        final reports = FakeFoundCases()..mine.addAll([community, notice]);
        final cases = FakeCases()..mine.add(own);
        final scope = ProviderContainer(
          overrides: [
            localDraftRepositoryProvider.overrideWithValue(FakeLocalDrafts()),
            startupStateProvider.overrideWithValue(
              const StartupState(StartupStatus.ready),
            ),
            authRepositoryProvider.overrideWithValue(auth),
            passwordRecoveryRepositoryProvider.overrideWithValue(
              FakePasswordRecovery(),
            ),
            onboardingRepositoryProvider.overrideWithValue(
              FakeOnboarding(auth)..completed.add('one'),
            ),
            petRepositoryProvider.overrideWithValue(FakePets()),
            petPhotoRepositoryProvider.overrideWithValue(FakePetPhotos()),
            foundCaseRepositoryProvider.overrideWithValue(reports),
            lostCaseRepositoryProvider.overrideWithValue(cases),
          ],
        );
        addTearDown(() async {
          scope.dispose();
          await auth.controller.close();
        });
        final boundary = GlobalKey();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: scope,
            child: RepaintBoundary(
              key: boundary,
              child: const EntreHuellasApp(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        Future<void> shot(String name) async {
          if (Platform.environment['CAPTURE_REPORT_MENU'] != '1') return;
          await tester.runAsync(() async {
            final render =
                boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary;
            final raster = await render.toImage();
            final bytes = await raster.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final dir = Directory('build/ui-preview/report-menu')
              ..createSync(recursive: true);
            File(
              '${dir.path}/${small ? 'small' : 'normal'}-$name.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            raster.dispose();
          });
        }

        await tester.tap(find.byTooltip('Reportar'));
        await tester.pumpAndSettle();
        expect(find.byType(LostReportScreen), findsOneWidget);
        expect(find.byType(BottomSheet), findsNothing);
        expect(find.text('Mascota encontrada'), findsNothing);
        await shot('direct-report');
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Mis reportes'));
        await tester.tap(find.text('Mis reportes'));
        await tester.pumpAndSettle();
        expect(find.byType(RecoveryReportsScreen), findsOneWidget);
        await tester.ensureVisible(find.text('Luna'));
        await shot('reports');
        expect(find.text('Posiblemente perdida · Perro'), findsOneWidget);
        await tester.ensureVisible(find.text('Resueltos'));
        await tester.tap(find.text('Resueltos'));
        await tester.pumpAndSettle();
        expect(find.text('Avistamiento · Gato'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
