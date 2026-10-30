import 'dart:async';
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
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/swipe_action_card.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/entities/lost_case.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/providers/lost_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/providers/found_case_providers.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'lost_cases_test.dart' show FakeCases;
import 'found_cases_test.dart' show FakeFoundCases;
import 'alert_preferences_test.dart' show loadFonts;
import 'support/fake_password_recovery.dart';

void main() {
  for (final found in [false, true]) {
    for (final small in [false, true]) {
      testWidgets(
        'Case opens and returns from its card like pets; found=$found small=$small',
        (tester) async {
          await tester.binding.setSurfaceSize(
            small ? const Size(320, 350) : const Size(390, 844),
          );
          addTearDown(() => tester.binding.setSurfaceSize(null));
          tester.platformDispatcher.textScaleFactorTestValue = small ? 2 : 1;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          tester.platformDispatcher.accessibilityFeaturesTestValue =
              FakeAccessibilityFeatures(disableAnimations: small);
          addTearDown(
            tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
          );
          if (Platform.environment['CAPTURE_CASE_NAVIGATION'] == '1') {
            await tester.runAsync(loadFonts);
          }
          final auth = FakeAuthRepository()
            ..current = const AuthSession(userId: 'one');
          final wait = Completer<void>();
          final lost = FakeCases()
            ..pendingRead = wait
            ..mine.add(
              const PublishedLostCase(
                id: 'case',
                ownerId: 'one',
                petId: 'pet',
                status: 'active',
                petName: 'Luna',
              ),
            );
          final reports = FakeFoundCases()
            ..pendingRead = wait
            ..mine.add(
              const FoundPublication(
                id: 'case',
                ownerId: 'one',
                status: 'active',
                species: 'dog',
              ),
            );
          final scope = ProviderContainer(
            overrides: [
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
          final listRoute = found ? '/home/my-found-cases' : '/home/my-cases';
          router.go(listRoute);
          await tester.pumpAndSettle();
          expect(find.text('Volver a consultar'), findsNothing);
          final card = find.widgetWithText(
            SwipeActionCard,
            found ? 'Posiblemente perdida · Perro' : 'Luna',
          );
          await tester.ensureVisible(card);
          await tester.pumpAndSettle();
          final origin = tester.getRect(card);
          await tester.tap(card);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          final transition = tester.widget<OriginPageTransition>(
            find.byType(OriginPageTransition).last,
          );
          expect(transition.origin, origin);
          expect(transition.animation.value, small ? 1 : lessThan(1));
          if (Platform.environment['CAPTURE_CASE_NAVIGATION'] == '1') {
            await tester.runAsync(() async {
              final image =
                  await (boundary.currentContext!.findRenderObject()
                          as RenderRepaintBoundary)
                      .toImage();
              final data = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final folder = Directory('build/ui-preview/case-navigation')
                ..createSync(recursive: true);
              await File(
                '${folder.path}/${found ? 'found' : 'lost'}-${small ? 'small' : 'normal'}-opening.png',
              ).writeAsBytes(data!.buffer.asUint8List());
              image.dispose();
            });
          }
          // Data is deliberately pending while exercising return during skeleton.
          router.pop();
          await tester.pumpAndSettle();
          expect(router.routeInformationProvider.value.uri.path, listRoute);
          expect(card, findsOneWidget);
          expect(tester.getRect(card), origin);
          expect(tester.takeException(), isNull);
          wait.complete();
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }
}
