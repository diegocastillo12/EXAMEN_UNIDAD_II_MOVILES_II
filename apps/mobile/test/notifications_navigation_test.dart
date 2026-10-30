import 'dart:async';
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
import 'package:flutter_application_entrehuellas/features/notifications/domain/repositories/push_repository.dart';
import 'package:flutter_application_entrehuellas/features/notifications/providers/notification_providers.dart';
import 'package:flutter_application_entrehuellas/features/notifications/presentation/screens/inbox_screen.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'notifications_test.dart' show FakeNotifications;
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'support/fake_password_recovery.dart';
import 'support/fake_profile.dart';

class _Push implements PushRepository {
  int watches = 0;
  final signals = StreamController<PushSignal>.broadcast();
  final owners = <String?>[];
  @override
  Future<PushAvailability> enable(String owner) async => PushAvailability.ready;
  @override
  Future<void> synchronize(String? owner) async {
    owners.add(owner);
  }

  @override
  Stream<PushSignal> watch() {
    watches++;
    return signals.stream;
  }
}

void main() {
  testWidgets('Current app opens inbox without activating deferred push', (
    tester,
  ) async {
    final auth = FakeAuthRepository()
      ..current = const AuthSession(userId: 'one');
    final onboarding = FakeOnboarding(auth)..completed.add('one');
    final push = _Push();
    final c = ProviderContainer(
      overrides: [
        startupStateProvider.overrideWithValue(
          const StartupState(StartupStatus.ready),
        ),
        authRepositoryProvider.overrideWithValue(auth),
        onboardingRepositoryProvider.overrideWithValue(onboarding),
        passwordRecoveryRepositoryProvider.overrideWithValue(
          FakePasswordRecovery(),
        ),
        profileRepositoryProvider.overrideWithValue(FakeProfile()),
        notificationRepositoryProvider.overrideWithValue(FakeNotifications()),
        pushRepositoryProvider.overrideWithValue(push),
      ],
    );
    addTearDown(() async {
      c.dispose();
      await auth.controller.close();
      await push.signals.close();
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: const EntreHuellasApp()),
    );
    await tester.pumpAndSettle();
    expect(push.owners, isEmpty);
    expect(push.watches, 0);
    final bell = tester.getRect(
      find.widgetWithIcon(IconButton, Icons.notifications_none_rounded),
    );
    await tester.tap(find.byTooltip('Alertas'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final transition = tester.widget<OriginPageTransition>(
      find.byType(OriginPageTransition).last,
    );
    expect(transition.origin, bell);
    expect(transition.source?.bounds, bell);
    final surface = tester.getRect(
      find.byKey(const ValueKey('origin-surface')),
    );
    expect(surface.width, greaterThan(bell.width));
    expect(surface.width, lessThan(tester.view.physicalSize.width));
    await tester.pumpAndSettle();
    expect(find.byType(InboxScreen), findsOneWidget);
    expect(find.text('Activar avisos en este teléfono'), findsNothing);
    expect(push.owners, isEmpty);
    expect(push.watches, 0);
    c.read(routerProvider).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.byKey(const ValueKey('origin-surface')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(InboxScreen), findsNothing);
    expect(find.byTooltip('Alertas'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  for (final authenticated in [false, true]) {
    testWidgets(
      'Push waits for authentication and opens only the current inbox; authenticated=$authenticated',
      (tester) async {
        final auth = FakeAuthRepository();
        if (authenticated) auth.current = const AuthSession(userId: 'one');
        final onboarding = FakeOnboarding(auth)..completed.add('one');
        final push = _Push();
        final c = ProviderContainer(
          overrides: [
            startupStateProvider.overrideWithValue(
              const StartupState(StartupStatus.ready),
            ),
            authRepositoryProvider.overrideWithValue(auth),
            onboardingRepositoryProvider.overrideWithValue(onboarding),
            passwordRecoveryRepositoryProvider.overrideWithValue(
              FakePasswordRecovery(),
            ),
            profileRepositoryProvider.overrideWithValue(FakeProfile()),
            notificationRepositoryProvider.overrideWithValue(
              FakeNotifications(),
            ),
            pushRepositoryProvider.overrideWithValue(push),
          ],
        );
        addTearDown(() async {
          c.dispose();
          await auth.controller.close();
          await push.signals.close();
        });
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: c,
            child: const EntreHuellasApp(observeNotifications: true),
          ),
        );
        await tester.pumpAndSettle();
        push.signals.add(PushSignal.opened);
        await tester.pumpAndSettle();
        if (!authenticated) {
          expect(find.byType(InboxScreen), findsNothing);
          auth.emit(const AuthSession(userId: 'one'));
          await tester.pumpAndSettle();
        }
        expect(find.byType(InboxScreen), findsOneWidget);
        expect(push.owners.last, 'one');
        c.read(routerProvider).pop();
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Alertas'));
        await tester.pumpAndSettle();
        expect(find.byType(InboxScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}
