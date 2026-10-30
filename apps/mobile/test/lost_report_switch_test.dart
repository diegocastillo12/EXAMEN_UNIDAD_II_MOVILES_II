import 'support/fake_local_drafts.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/providers/local_draft_providers.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/providers/found_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/view_models/found_editor_view_model.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'found_cases_test.dart' show FakeFoundCases;
import 'support/fake_password_recovery.dart';
import 'support/fake_pets.dart';
import 'support/fake_pet_photos.dart';

import 'package:flutter_application_entrehuellas/app/screens/lost_report_screen.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/skeleton_form_fields.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_report_fields.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/event_date_time_fields.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_location_fields.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/two_option_filter.dart';
import 'alert_preferences_test.dart' show loadFonts;
import 'lost_cases_test.dart' show fields;
import 'package:flutter_application_entrehuellas/features/lost_cases/presentation/view_models/case_editor_view_model.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';

class CountingPets extends FakePets {
  int lists = 0;
  @override
  Future<List<Pet>> list(String ownerId, {bool archived = false}) {
    lists++;
    return super.list(ownerId, archived: archived);
  }
}

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
  for (final initialOther in [false, true]) {
    testWidgets(
      'Switching lost-report mode retains chrome/drafts without reload; initialOther=$initialOther',
      (tester) async {
        tester.view.physicalSize = initialOther
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.platformDispatcher.textScaleFactorTestValue = initialOther
            ? 2
            : 1;
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            FakeAccessibilityFeatures(disableAnimations: initialOther);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        final auth = FakeAuthRepository()
          ..current = const AuthSession(userId: 'one');
        final reports = FakeFoundCases();
        final pets = CountingPets()
          ..pets['pet'] = const Pet(
            id: 'pet',
            ownerId: 'one',
            fields: fields,
            version: 1,
          );
        final capture = Platform.environment['CAPTURE_UNIFIED_REPORT'] == '1';
        if (capture) await tester.runAsync(loadFonts);
        final boundary = GlobalKey();
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
            petRepositoryProvider.overrideWithValue(pets),
            petPhotoRepositoryProvider.overrideWithValue(FakePetPhotos()),
            foundCaseRepositoryProvider.overrideWithValue(reports),
          ],
        );
        addTearDown(() async {
          scope.dispose();
          await auth.controller.close();
        });
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
        final router = scope.read(routerProvider);
        router.go(
          initialOther
              ? '/home/lost-cases/community/new'
              : '/home/lost-cases/new',
        );
        await tester.pumpAndSettle();

        final editorScope = ProviderScope.containerOf(
          tester.element(find.byType(LostReportScreen)),
        );
        final own = editorScope.read(caseEditorViewModelProvider.notifier);
        final other = editorScope.read(foundEditorViewModelProvider.notifier);
        own.chooseDate(DateTime(2026, 10, 9));
        own.edit(
          placeReference: 'Referencia de mi mascota',
          latitude: -12.04,
          longitude: -77.03,
        );
        other.chooseDate(DateTime(2026, 10, 8));
        other.edit(
          species: 'dog',
          traits: 'Collar azul',
          placeReference: 'Parque',
          latitude: -13.01,
          longitude: -76.02,
        );
        final ownId = editorScope
            .read(caseEditorViewModelProvider)
            .requireValue
            .draftId;
        final otherId = editorScope
            .read(foundEditorViewModelProvider)
            .requireValue
            .draftId;
        final listCount = pets.lists;
        final selectorState = tester.element(
          find.byKey(const ValueKey('report-pet-selection')),
        );
        final route = router.routeInformationProvider.value.uri;
        Future<void> select(bool second) async {
          final selector = find.byKey(const ValueKey('report-pet-selection'));
          await tester.ensureVisible(selector);
          await tester.tap(selector);
          await tester.pumpAndSettle();
          final label = second ? 'No está en mis mascotas' : 'Luna';
          await tester.ensureVisible(find.text(label).last);
          await tester.tapAt(
            tester.getTopLeft(find.text(label).last) + const Offset(8, 8),
          );
          await tester.pumpAndSettle();
          expect(
            find.byType(SkeletonFormFields, skipOffstage: false),
            findsNothing,
          );
          expect(tester.element(selector), same(selectorState));
          expect(find.byType(TwoOptionFilter), findsNothing);
          expect(find.byType(CaseReportFields), findsOneWidget);
          expect(find.byType(EventDateTimeFields), findsOneWidget);
          expect(find.byType(CaseLocationFields), findsOneWidget);
          expect(find.text('¿Cambiar de reporte?'), findsNothing);
          expect(router.routeInformationProvider.value.uri, route);
          await tester.pump(const Duration(milliseconds: 160));
          expect(
            find.byType(SkeletonFormFields, skipOffstage: false),
            findsNothing,
          );
          await tester.pumpAndSettle();
        }

        await tester.pumpAndSettle();
        await select(!initialOther);
        await select(initialOther);
        await select(true);
        expect(
          find.byWidgetPredicate(
            (w) => w is TextField && w.controller?.text == 'Collar azul',
          ),
          findsOneWidget,
        );
        await select(false);
        final ownDraft = editorScope
            .read(caseEditorViewModelProvider)
            .requireValue;
        final otherDraft = editorScope
            .read(foundEditorViewModelProvider)
            .requireValue;
        expect(ownDraft.draftId, ownId);
        expect(otherDraft.draftId, otherId);
        expect(
          ownDraft.placeReference,
          initialOther ? 'Parque' : 'Referencia de mi mascota',
        );
        expect(
          ownDraft.dateTimeDraft.date,
          DateTime(2026, 10, initialOther ? 8 : 9),
        );
        expect(otherDraft.traits, 'Collar azul');
        expect(otherDraft.dateTimeDraft.date, ownDraft.dateTimeDraft.date);
        expect(otherDraft.placeReference, ownDraft.placeReference);
        expect(ownDraft.latitude, initialOther ? -13.01 : -12.04);
        expect(ownDraft.longitude, initialOther ? -76.02 : -77.03);
        expect(otherDraft.latitude, ownDraft.latitude);
        expect(otherDraft.longitude, ownDraft.longitude);
        expect(ownDraft.occurredAt, isNull);
        expect(otherDraft.occurredAt, isNull);
        expect(pets.lists, listCount);
        expect(tester.takeException(), isNull);
        Future<void> shot(String suffix) async {
          if (!capture) return;
          if (suffix != 'report-fields') {
            FocusManager.instance.primaryFocus?.unfocus();
            await tester.pumpAndSettle();
            final scroll = tester.widget<SingleChildScrollView>(
              find.ancestor(
                of: find.text('Mascota perdida'),
                matching: find.byType(SingleChildScrollView),
              ),
            );
            scroll.controller!.jumpTo(0);
            await tester.pumpAndSettle();
          }
          await tester.runAsync(() async {
            final render =
                boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary;
            final raster = await render.toImage();
            final bytes = await raster.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final folder = Directory('build/ui-preview/unified-report')
              ..createSync(recursive: true);
            File(
              '${folder.path}/${initialOther ? 'small' : 'normal'}-$suffix.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            raster.dispose();
          });
        }

        await tester.ensureVisible(
          find.byKey(const ValueKey('report-pet-selection')),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Mascota perdida'));
        await tester.pump(const Duration(seconds: 6));
        await tester.pumpAndSettle();
        await shot('registered');
        await select(true);
        await tester.ensureVisible(find.text('Mascota perdida'));
        await tester.pump(const Duration(seconds: 6));
        await tester.pumpAndSettle();
        await shot('unregistered');
        await tester.ensureVisible(find.text('Revisar publicación'));
        await tester.pumpAndSettle();
        await shot('report-fields');
        await tester.tap(find.text('Revisar publicación'));
        await tester.pumpAndSettle();
        expect(find.byType(CaseReportFields), findsOneWidget);
        expect(
          editorScope
              .read(foundEditorViewModelProvider)
              .requireValue
              .invalidFields,
          isNotEmpty,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
