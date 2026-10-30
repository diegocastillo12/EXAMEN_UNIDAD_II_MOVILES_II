import 'explore_test.dart' show SearchFake;
import 'support/fake_current_location.dart';
import 'package:flutter_application_entrehuellas/features/explore/providers/explore_providers.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/widgets/explore_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'access_test.dart' show FakeAccess;
import 'support/fake_password_recovery.dart';
import 'support/fake_profile.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/providers/interest_zone_providers.dart';
import 'interest_zones_test.dart' show FakeZones;
import 'package:flutter_application_entrehuellas/features/alert_preferences/providers/alert_preference_providers.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/presentation/view_models/alert_preferences_view_model.dart';
import 'support/fake_alert_preferences.dart';

void main() {
  for (final small in [false, true]) {
    testWidgets(
      'Header avatar opens protected profile from its bounds and returns to same section; small=$small',
      (tester) async {
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = small ? 2 : 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final auth = FakeAuthRepository()
          ..current = const AuthSession(userId: 'one');
        final onboarding = FakeOnboarding(auth)..completed.add('one');
        final recovery = FakePasswordRecovery();
        final container = ProviderContainer(
          overrides: [
            exploreRepositoryProvider.overrideWithValue(SearchFake()),
            currentLocationRepositoryProvider.overrideWithValue(
              const FakeCurrentLocation(),
            ),
            startupStateProvider.overrideWithValue(
              const StartupState(StartupStatus.ready),
            ),
            authRepositoryProvider.overrideWithValue(auth),
            accessRepositoryProvider.overrideWithValue(FakeAccess()),
            onboardingRepositoryProvider.overrideWithValue(onboarding),
            passwordRecoveryRepositoryProvider.overrideWithValue(recovery),
            profileRepositoryProvider.overrideWithValue(FakeProfile()),
            interestZoneRepositoryProvider.overrideWithValue(FakeZones()),
            alertPreferenceRepositoryProvider.overrideWithValue(
              FakeAlertPreferences(),
            ),
          ],
        );
        addTearDown(() async {
          container.dispose();
          await auth.controller.close();
          await recovery.events.close();
        });
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const EntreHuellasApp(),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byTooltip('Perfil'), findsNothing);
        expect(find.byTooltip('Abrir perfil'), findsOneWidget);
        await tester.tap(find.byTooltip('Explorar'));
        await tester.pumpAndSettle();
        final avatarBounds = tester.getRect(find.byTooltip('Abrir perfil'));
        await tester.tap(find.byTooltip('Abrir perfil'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));

        final transition = tester.widget<OriginPageTransition>(
          find.byType(OriginPageTransition),
        );
        expect(transition.origin, avatarBounds);
        await tester.pumpAndSettle();
        expect(find.text('Perfil'), findsOneWidget);
        await tester.ensureVisible(find.text('Ubicaciones de interés'));
        await tester.tap(find.text('Ubicaciones de interés'));
        await tester.pumpAndSettle();
        expect(
          find.text('Todavía no tienes ubicaciones de interés.'),
          findsOneWidget,
        );
        await tester.tap(find.byTooltip('Volver al perfil'));
        await tester.pumpAndSettle();
        expect(find.text('Perfil'), findsOneWidget);
        await tester.ensureVisible(find.text('Cerrar sesión'));
        await tester.ensureVisible(find.text('Preferencias de alertas'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Preferencias de alertas'));
        await tester.pumpAndSettle();
        expect(find.text('Tipos de aviso'), findsOneWidget);
        container
            .read(alertPreferencesViewModelProvider.notifier)
            .edit(enabled: true);
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Volver al perfil'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Cancelar'));
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(find.text('Tipos de aviso'), findsOneWidget);
        await tester.tap(find.byTooltip('Volver al perfil'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Descartar'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Descartar'));
        await tester.pumpAndSettle();
        expect(find.text('Perfil'), findsOneWidget);
        await tester.ensureVisible(find.text('Cerrar sesión'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byTooltip('Cerrar perfil'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Cerrar perfil'));
        await tester.pumpAndSettle();
        expect(
          container
              .read(routerProvider)
              .routeInformationProvider
              .value
              .uri
              .path,
          '/home',
        );
        expect(find.byType(ExploreSection), findsOneWidget);
        auth.emit(null);
        await tester.pumpAndSettle();
        container.read(routerProvider).go('/home/profile');
        await tester.pumpAndSettle();
        expect(find.text('Iniciar sesión'), findsOneWidget);
        expect(find.text('Perfil'), findsNothing);
        container.read(routerProvider).go('/home/interest-zones');
        await tester.pumpAndSettle();
        expect(find.text('Iniciar sesión'), findsOneWidget);
        expect(find.text('Ubicaciones de interés'), findsNothing);
        container.read(routerProvider).go('/home/alert-preferences');
        await tester.pumpAndSettle();
        expect(find.text('Iniciar sesión'), findsOneWidget);
        expect(find.text('Tipos de aviso'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
