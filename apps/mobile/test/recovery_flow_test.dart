import 'support/fake_local_drafts.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/providers/local_draft_providers.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/providers/lost_case_providers.dart';
import 'lost_cases_test.dart' show FakeCases;
import 'dart:io';
import 'content_reports_test.dart' show FakeReports;
import 'package:flutter_application_entrehuellas/features/content_reports/providers/content_report_providers.dart';
import 'package:flutter_application_entrehuellas/features/content_reports/presentation/screens/content_report_screen.dart';
import 'package:flutter_application_entrehuellas/features/content_reports/presentation/view_models/content_report_view_model.dart';
import 'case_closure_test.dart' show FakeClosure;
import 'package:flutter_application_entrehuellas/features/case_closure/domain/entities/case_closure.dart';
import 'package:flutter_application_entrehuellas/features/case_closure/providers/case_closure_providers.dart';
import 'package:flutter_application_entrehuellas/features/case_closure/presentation/screens/case_closure_screen.dart';
import 'package:flutter_application_entrehuellas/features/case_closure/presentation/view_models/case_closure_view_model.dart';
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
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/providers/found_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/screens/found_editor_screen.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/view_models/found_editor_view_model.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/view_models/recovery_case_view_model.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/widgets/recovery_case_actions.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'found_cases_test.dart' show FakeFoundCases;
import 'sightings_test.dart' show FakeSightings;
import 'case_timeline_test.dart' show FakeTimeline;
import 'package:flutter_application_entrehuellas/features/case_timeline/providers/case_timeline_providers.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/presentation/screens/case_timeline_screen.dart';
import 'package:flutter_application_entrehuellas/features/sightings/providers/sighting_providers.dart';
import 'package:flutter_application_entrehuellas/features/sightings/presentation/screens/sighting_screen.dart';
import 'support/fake_password_recovery.dart';
import 'support/fake_pets.dart';
import 'support/fake_pet_photos.dart';

PublicFoundCase projection(FoundCaseDraft d, {bool owner = false}) =>
    PublicFoundCase(
      id: d.id,
      status: 'active',
      occurredAt: d.occurredAt,
      latitude: -12.045,
      longitude: -77.045,
      species: d.species,
      traits: d.traits,
      photos: [],
      reportKind: d.reportKind,
      targetId: d.targetId,
      communityTarget: d.communityTarget,
      canResolve: owner,
    );

class FlowClosure extends FakeClosure {
  FlowClosure(this.reports);
  final FakeFoundCases reports;
  @override
  Future<ClosureReceipt> close(String owner, ClosureCommand command) async {
    await reports.resolveSearch(
      owner,
      command.target.id,
      command.target.community,
    );
    return super.close(owner, command);
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
  for (final small in [false, true]) {
    testWidgets(
      'Search without owned pet, linked found notice and explicit author confirmation; small=$small',
      (tester) async {
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.platformDispatcher.textScaleFactorTestValue = small ? 2 : 1;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final auth = FakeAuthRepository()
          ..current = const AuthSession(userId: 'one');
        final reports = FakeFoundCases();
        final closures = FlowClosure(reports);
        final pets = FakePets();
        final scope = ProviderContainer(
          overrides: [
            localDraftRepositoryProvider.overrideWithValue(FakeLocalDrafts()),
            contentReportRepositoryProvider.overrideWithValue(FakeReports()),
            caseClosureRepositoryProvider.overrideWithValue(closures),
            sightingRepositoryProvider.overrideWithValue(FakeSightings()),
            caseTimelineRepositoryProvider.overrideWithValue(FakeTimeline()),
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
            lostCaseRepositoryProvider.overrideWithValue(FakeCases()),
          ],
        );
        addTearDown(() async {
          scope.dispose();
          await auth.controller.close();
        });
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: scope,
            child: const EntreHuellasApp(),
          ),
        );
        await tester.pumpAndSettle();
        final router = scope.read(routerProvider);
        router.go('/home/lost-cases/new');
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Mascota a reportar'));
        await tester.tap(find.text('Mascota a reportar'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('No está en mis mascotas'));
        await tester.tapAt(
          tester.getTopLeft(find.text('No está en mis mascotas')) +
              const Offset(8, 8),
        );
        await tester.pumpAndSettle();
        final editorScope = ProviderScope.containerOf(
          tester.element(find.byType(FoundEditorScreen)),
        );
        final model = editorScope.read(foundEditorViewModelProvider.notifier);
        expect(
          editorScope
              .read(foundEditorViewModelProvider)
              .requireValue
              .communitySearch,
          true,
        );
        expect(pets.pets, isEmpty);
        model.edit(
          species: 'dog',
          traits: 'Collar azul y mancha blanca',
          occurredAt: DateTime(2026, 10, 9, 12),
          latitude: -12.0464,
          longitude: -77.0428,
          placeReference: 'Parque',
        );
        await tester.runAsync(model.choosePhoto);
        await tester.pumpAndSettle();
        await tester.runAsync(
          () => precacheImage(
            MemoryImage(
              editorScope
                  .read(foundEditorViewModelProvider)
                  .requireValue
                  .photos
                  .first
                  .bytes,
            ),
            tester.element(find.byType(FoundEditorScreen)),
          ),
        );
        model.preview();
        await tester.pumpAndSettle();
        await tester.runAsync(model.publish);
        await tester.pumpAndSettle();
        final search = reports.attempts.single;
        expect(search.reportKind, 'possible_loss');
        expect(search.targetId, isNull);
        reports.publicCase = projection(search, owner: true);
        reports.searches.add(
          RecoverySearch(
            id: search.id,
            community: true,
            name: 'Perro con collar azul',
            species: 'dog',
          ),
        );
        await tester.ensureVisible(find.text('Ver ficha pública'));
        await tester.tap(find.text('Ver ficha pública'));
        await tester.pumpAndSettle();
        expect(
          find.byType(RecoveryCaseActions, skipOffstage: false),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 8));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.text('Ver seguimiento', skipOffstage: false),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ver seguimiento', skipOffstage: false));
        await tester.pumpAndSettle();
        expect(find.byType(CaseTimelineScreen), findsOneWidget);
        final timeline = tester.widget<CaseTimelineScreen>(
          find.byType(CaseTimelineScreen),
        );
        expect(timeline.target.id, search.id);
        expect(timeline.target.community, true);
        router.pop();
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Compartir ficha'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byTooltip('Denunciar contenido'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Denunciar contenido'));
        await tester.pumpAndSettle();
        expect(find.byType(ContentReportScreen), findsOneWidget);
        final reportScreen = tester.widget<ContentReportScreen>(
          find.byType(ContentReportScreen),
        );
        expect(reportScreen.target, (kind: 'found', id: search.id));
        final reportModel = scope.read(
          contentReportViewModelProvider(reportScreen.target).notifier,
        );
        reportModel.edit(reason: 'Publicación que requiere revisión');
        expect(await reportModel.submit(), true);
        await tester.pumpAndSettle();
        expect(find.text('Denuncia registrada'), findsOneWidget);
        router.pop();
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.text('Reportar avistamiento', skipOffstage: false),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.text('Reportar avistamiento', skipOffstage: false),
        );
        await tester.pumpAndSettle();
        expect(find.byType(SightingScreen), findsOneWidget);
        final sightingScope = ProviderScope.containerOf(
          tester.element(find.byType(SightingScreen)),
        );
        expect(sightingScope.read(sightingTargetProvider).id, search.id);
        expect(sightingScope.read(sightingTargetProvider).community, true);
        router.pop();
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.text('La vi o la encontré', skipOffstage: false),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('La vi o la encontré', skipOffstage: false));
        await tester.pumpAndSettle();
        final noticeScope = ProviderScope.containerOf(
          tester.element(find.byType(FoundEditorScreen)),
        );
        final noticeModel = noticeScope.read(
          foundEditorViewModelProvider.notifier,
        );
        final noticeState = noticeScope
            .read(foundEditorViewModelProvider)
            .requireValue;
        expect(noticeState.communitySearch, false);
        expect(noticeState.targetId, search.id);
        expect(noticeState.communityTarget, true);
        expect(find.text('Descripción del aviso'), findsOneWidget);
        expect(find.text('Especie'), findsNothing);
        noticeModel.chooseObservation('with_reporter');
        noticeModel.edit(
          traits: 'Está conmigo en el parque',
          occurredAt: DateTime(2026, 10, 10, 12),
          latitude: -12.04,
          longitude: -77.03,
          placeReference: 'Entrada del parque',
        );

        noticeModel.preview();
        await tester.pumpAndSettle();
        await tester.runAsync(noticeModel.publish);
        await tester.pumpAndSettle();
        final notice = reports.attempts.last;
        expect(notice.reportKind, 'with_reporter');
        expect(notice.targetId, search.id);
        expect(notice.communityTarget, true);
        expect(reports.resolvedSearches, isEmpty);
        reports.observations.add(projection(notice));
        scope.invalidate(recoveryCaseViewModelProvider((search.id, true)));
        reports.publicCase = projection(search, owner: true);
        router.go('/home/found-cases/${search.id}');
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 8));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.text('Ya fue recuperada', skipOffstage: false),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ya fue recuperada', skipOffstage: false));
        await tester.pumpAndSettle();
        expect(find.byType(CaseClosureScreen), findsOneWidget);
        final closeTarget = (id: search.id, community: true);
        scope
            .read(caseClosureViewModelProvider(closeTarget).notifier)
            .edit(reason: 'Regresó a casa');
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Confirmar recuperación'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirmar recuperación'));
        await tester.pumpAndSettle();
        expect(find.text('¿Confirmar recuperación?'), findsOneWidget);
        await tester.ensureVisible(find.text('Confirmar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();
        expect(reports.resolvedSearches, [search.id]);
        expect(closures.attempts.single.target, closeTarget);
        expect(find.text('Búsqueda finalizada'), findsOneWidget);
        expect(reports.publicCase!.status, 'resolved');
        router.pop();
        await tester.pumpAndSettle();
        expect(
          find.text('La vi o la encontré', skipOffstage: false),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
