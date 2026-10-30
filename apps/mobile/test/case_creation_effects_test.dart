import 'support/fake_local_drafts.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/providers/local_draft_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/screens/found_editor_screen.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_public_screen_shell.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_location_fields.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/zone_map_picker.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/presentation/view_models/case_editor_view_model.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/view_models/found_editor_view_model.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/event_date_time_fields.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/collection_add_button.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/cover_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/entity_screen_shell.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_text_field.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/providers/lost_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/providers/found_case_providers.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'lost_cases_test.dart' show FakeCases, fields;
import 'found_cases_test.dart' show FakeFoundCases;
import 'alert_preferences_test.dart' show loadFonts;
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/entities/lost_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'support/fake_password_recovery.dart';
import 'support/fake_pets.dart';
import 'support/fake_pet_photos.dart';
import 'support/fake_place_search.dart';
import 'package:flutter_application_entrehuellas/features/places/providers/places_providers.dart';
import 'package:flutter_application_entrehuellas/features/places/presentation/widgets/place_search_fields.dart';

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
  for (final found in [false, true]) {
    for (final fromList in [false, true]) {
      for (final small in [false, true]) {
        testWidgets(
          'Creation opens from real control and keeps pet effects: found=$found list=$fromList small=$small',
          (tester) async {
            tester.view.physicalSize = small
                ? const Size(320, 350)
                : const Size(390, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            tester.platformDispatcher.textScaleFactorTestValue = small ? 2 : 1;
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            tester.platformDispatcher.accessibilityFeaturesTestValue =
                FakeAccessibilityFeatures(disableAnimations: small);
            addTearDown(
              tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
            );
            final capture =
                Platform.environment['CAPTURE_CASE_CREATION'] == '1';
            if (capture) await tester.runAsync(loadFonts);
            final auth = FakeAuthRepository()
              ..current = const AuthSession(userId: 'one');
            final pets = FakePets()
              ..pets['pet'] = const Pet(
                id: 'pet',
                ownerId: 'one',
                fields: fields,
                version: 1,
              );
            final lost = FakeCases()
              ..publicCase = PublicLostCase(
                id: 'case',
                status: 'active',
                occurredAt: DateTime(2026, 10, 9),
                latitude: -12.04,
                longitude: -77.04,
                fields: fields,
                photos: [],
              );
            final reports = FakeFoundCases()
              ..publicCase = PublicFoundCase(
                id: 'case',
                status: 'active',
                occurredAt: DateTime(2026, 10, 9),
                latitude: -12.04,
                longitude: -77.04,
                species: 'dog',
                traits: 'Collar azul',
                photos: [],
              );
            final scope = ProviderContainer(
              overrides: [
                localDraftRepositoryProvider.overrideWithValue(
                  FakeLocalDrafts(),
                ),
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
                placeSearchRepositoryProvider.overrideWithValue(
                  FakePlaceSearch(),
                ),
                petPhotoRepositoryProvider.overrideWithValue(FakePetPhotos()),
                lostCaseRepositoryProvider.overrideWithValue(lost),
                foundCaseRepositoryProvider.overrideWithValue(reports),
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
            final router = scope.read(routerProvider);
            final listRoute = '/home/my-cases';
            final entryRoute = found
                ? '/home/${fromList ? 'found-cases' : 'cases'}/case'
                : fromList
                ? listRoute
                : '/home';
            if (found || fromList) {
              router.go(entryRoute);
              await tester.pumpAndSettle();
            }
            final route = found
                ? '/home/found-cases/new'
                : '/home/lost-cases/new';
            final targetRoute = found
                ? '$route?case=case&community=$fromList'
                : route;
            final add = find.byWidgetPredicate(
              (w) => w is CollectionAddButton && w.route == targetRoute,
              skipOffstage: false,
            );
            final target = found || fromList ? add : find.byTooltip('Reportar');
            await tester.ensureVisible(target);
            await tester.pumpAndSettle();
            final button = found || fromList
                ? find.descendant(
                    of: add,
                    matching: find.byType(FilledButton, skipOffstage: false),
                    skipOffstage: false,
                  )
                : target;
            final origin = tester.getRect(button);
            Future<void> shot(String name) async {
              if (!capture) return;
              await tester.runAsync(() async {
                final render =
                    boundary.currentContext!.findRenderObject()
                        as RenderRepaintBoundary;
                final raster = await render.toImage();
                final bytes = await raster.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                final folder = Directory('build/ui-preview/case-creation')
                  ..createSync(recursive: true);
                File(
                  '${folder.path}/${found ? 'found' : 'lost'}-${fromList ? 'list' : 'home'}-${small ? 'small' : 'normal'}-$name.png',
                ).writeAsBytesSync(bytes!.buffer.asUint8List());
                raster.dispose();
              });
            }

            await tester.tap(button);
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
            final transition = tester.widget<OriginPageTransition>(
              find.byType(OriginPageTransition).last,
            );
            expect(transition.origin, origin);
            expect(transition.source?.bounds, origin);
            expect(
              transition.source?.radius,
              found
                  ? 24
                  : fromList
                  ? 28
                  : 32,
            );
            expect(transition.animation.value, small ? 1 : lessThan(1));
            await shot('opening');
            await tester.pumpAndSettle();
            expect(
              router.routerDelegate.currentConfiguration.last.route.path,
              route.substring('/home/'.length),
            );
            expect(find.byType(EntityScreenShell), findsOneWidget);
            final editorScope = found
                ? ProviderScope.containerOf(
                    tester.element(find.byType(FoundEditorScreen)),
                  )
                : scope;
            await tester.pump(const Duration(seconds: 8));
            await tester.pumpAndSettle();
            expect(find.byType(CaseLocationFields), findsOneWidget);
            for (final removed in [
              'Latitud',
              'Longitud',
              'Usar coordenadas',
              'Recuperar foto interrumpida',
            ]) {
              expect(find.text(removed), findsNothing);
            }
            expect(
              find.widgetWithText(TextButton, 'Mis encontrados'),
              findsNothing,
            );
            final location = tester.widget<ZoneMapPicker>(
              find.byType(ZoneMapPicker),
            );
            expect(find.byType(PlaceSearchFields), findsOneWidget);
            final searchInput = find.descendant(
              of: find.byType(PlaceSearchFields),
              matching: find.byType(TextField),
            );
            await tester.ensureVisible(searchInput);
            await tester.pumpAndSettle();
            await tester.enterText(searchInput, 'Miraflores');
            await tester.pump(const Duration(milliseconds: 650));
            await tester.pumpAndSettle();
            await tester.ensureVisible(find.text(FakePlaceSearch.place.label));
            await tester.pumpAndSettle();
            await tester.tap(find.text(FakePlaceSearch.place.label));
            await tester.pumpAndSettle();
            final searched = tester.widget<ZoneMapPicker>(
              find.byType(ZoneMapPicker),
            );
            expect(searched.latitude, FakePlaceSearch.place.latitude);
            expect(searched.longitude, FakePlaceSearch.place.longitude);
            expect(
              tester
                  .widget<CaseLocationFields>(find.byType(CaseLocationFields))
                  .placeController
                  .text,
              isEmpty,
            );
            if (capture) {
              await tester.ensureVisible(find.byType(PlaceSearchFields));
              await tester.pumpAndSettle();
              await shot('location-search');
            }
            location.onSelect!(-12.04, -77.03);
            await tester.pumpAndSettle();
            final selected = found
                ? editorScope
                      .read(foundEditorViewModelProvider)
                      .requireValue
                      .latitude
                : scope.read(caseEditorViewModelProvider).requireValue.latitude;
            expect(selected, -12.04);
            expect(find.textContaining('Punto seleccionado:'), findsNothing);
            await shot('form');
            if (capture) {
              await tester.ensureVisible(find.byType(EventDateTimeFields));
              await tester.pumpAndSettle();
              await shot('date-time');
            }
            final reveal = tester.state(find.byType(ContentReveal).last);
            // Every input participates in the shared reveal, including optional fields.
            for (final field in find.byType(AppTextField).evaluate()) {
              expect(
                find.ancestor(
                  of: find.byWidget(field.widget),
                  matching: find.byType(StaggerRevealItem),
                ),
                findsWidgets,
              );
            }
            final input = found
                ? find.byWidgetPredicate(
                    (w) =>
                        w is AppTextField && w.label == 'Descripción del aviso',
                  )
                : find.byWidgetPredicate(
                    (w) =>
                        w is AppTextField &&
                        w.label == 'Referencia privada del lugar',
                  );
            await tester.ensureVisible(input);
            await tester.pumpAndSettle();
            await tester.enterText(
              find.descendant(of: input, matching: find.byType(TextField)),
              'Detalle de prueba',
            );
            await tester.pumpAndSettle();
            expect(tester.state(find.byType(ContentReveal).last), same(reveal));
            expect(find.byType(CoverReveal), findsNothing);
            FocusManager.instance.primaryFocus?.unfocus();
            await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 8));
            await tester.pumpAndSettle();
            await tester.tap(find.byTooltip('Volver'));
            await tester.pumpAndSettle();
            expect(find.text('¿Salir del reporte?'), findsOneWidget);
            await tester.ensureVisible(find.text('Salir'));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Salir'));
            await tester.pump();
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
            if (!small) expect(find.byType(OriginPageTransition), findsWidgets);
            await shot('closing');
            await tester.pumpAndSettle();
            expect(router.routeInformationProvider.value.uri.path, entryRoute);
            expect(find.text('¿Salir del reporte?'), findsNothing);
            expect(
              find.byType(EntityScreenShell),
              !found && fromList ? findsOneWidget : findsNothing,
            );
            if (found) {
              expect(find.byType(CasePublicScreenShell), findsOneWidget);
            }
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
          },
        );
      }
    }
  }
}
