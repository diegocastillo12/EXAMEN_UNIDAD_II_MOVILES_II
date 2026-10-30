import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/recovery_access.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/failures/recovery_failure.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/use_cases/request_password_recovery.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/use_cases/reset_password.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/view_models/password_recovery_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/view_models/recovery_access_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'access_test.dart' show FakeAccess;
import 'support/fake_password_recovery.dart';

void main() {
  test('Recovery callback supersedes a request still in flight', () async {
    final repo = FakePasswordRecovery()..pending = Completer<void>();
    final container = ProviderContainer(
      overrides: [
        startupStateProvider.overrideWithValue(
          const StartupState(StartupStatus.ready),
        ),
        passwordRecoveryRepositoryProvider.overrideWithValue(repo),
      ],
    );
    final subscription = container.listen(
      passwordRecoveryViewModelProvider,
      (_, _) {},
    );
    await container.read(recoveryAccessViewModelProvider.future);
    final pending = container
        .read(passwordRecoveryViewModelProvider.notifier)
        .request('ana@example.com');
    repo.emit(RecoveryAccess.ready);
    await container.pump();
    repo.pending!.complete();
    await pending;
    expect(container.read(passwordRecoveryViewModelProvider).email, isNull);
    expect(container.read(passwordRecoveryViewModelProvider).resendSeconds, 0);
    subscription.close();
    container.dispose();
    await repo.events.close();
  });

  testWidgets(
    'Cooldown after rate limit blocks retry and weak password remains editable',
    (tester) async {
      final repo = FakePasswordRecovery()
        ..failure = RecoveryFailureKind.rateLimited;
      final container = ProviderContainer(
        overrides: [passwordRecoveryRepositoryProvider.overrideWithValue(repo)],
      );
      final subscription = container.listen(
        passwordRecoveryViewModelProvider,
        (_, _) {},
      );
      final vm = container.read(passwordRecoveryViewModelProvider.notifier);
      await vm.request('ana@example.com');
      expect(
        container.read(passwordRecoveryViewModelProvider).resendSeconds,
        60,
      );
      await vm.request('ana@example.com');
      expect(repo.sends, 1);
      await tester.pump(const Duration(seconds: 60));
      repo.current = RecoveryAccess.ready;
      repo.failure = RecoveryFailureKind.weakPassword;
      await vm.reset('new-password', 'new-password');
      expect(container.read(passwordRecoveryViewModelProvider).isBusy, false);
      expect(
        container.read(passwordRecoveryViewModelProvider).fieldHint,
        contains('más segura'),
      );
      repo.failure = null;
      await vm.reset('new-password', 'new-password');
      expect(container.read(passwordRecoveryViewModelProvider).updated, true);
      subscription.close();
      container.dispose();
      await repo.events.close();
    },
  );
  test(
    'Recovery validates before network, normalizes email and preserves password whitespace',
    () async {
      final repo = FakePasswordRecovery()..current = RecoveryAccess.ready;
      addTearDown(repo.events.close);
      final request = RequestPasswordRecovery(repo);
      expect(() => request('bad'), throwsA(isA<RecoveryFailure>()));
      expect(repo.sends, 0);
      await request('  ana@example.com  ');
      expect(repo.sentEmail, 'ana@example.com');
      final reset = ResetPassword(repo);
      expect(() => reset('short', 'short'), throwsA(isA<RecoveryFailure>()));
      expect(
        () => reset('12345678', 'different'),
        throwsA(isA<RecoveryFailure>()),
      );
      expect(repo.updates, 0);
      await reset('  new password  ', '  new password  ');
      expect(repo.savedPassword, '  new password  ');
    },
  );

  test(
    'ViewModel prevents duplicate requests and tolerates disposal in flight',
    () async {
      final repo = FakePasswordRecovery()..pending = Completer<void>();
      addTearDown(repo.events.close);
      final container = ProviderContainer(
        overrides: [passwordRecoveryRepositoryProvider.overrideWithValue(repo)],
      );
      final subscription = container.listen(
        passwordRecoveryViewModelProvider,
        (_, _) {},
      );
      final vm = container.read(passwordRecoveryViewModelProvider.notifier);
      final pending = vm.request('ana@example.com');
      await vm.request('ana@example.com');
      expect(repo.sends, 1);
      subscription.close();
      container.dispose();
      repo.pending!.complete();
      await pending;
    },
  );

  testWidgets(
    'Request shares login dimensions, validates, resends, closes with inverse transition',
    (tester) async {
      final auth = FakeAuthRepository();
      final repo = FakePasswordRecovery();
      final container = ProviderContainer(
        overrides: [
          startupStateProvider.overrideWithValue(
            const StartupState(StartupStatus.ready),
          ),
          authRepositoryProvider.overrideWithValue(auth),
          accessRepositoryProvider.overrideWithValue(FakeAccess()),
          passwordRecoveryRepositoryProvider.overrideWithValue(repo),
          onboardingRepositoryProvider.overrideWithValue(FakeOnboarding(auth)),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await auth.controller.close();
        await repo.events.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const EntreHuellasApp(),
        ),
      );
      await tester.pumpAndSettle();
      final brand = tester.getRect(find.byKey(const ValueKey('auth-brand')));
      final inputSize = tester.getSize(
        find.byKey(const ValueKey('login-email')),
      );
      final buttonSize = tester.getSize(
        find.widgetWithText(FilledButton, 'Ingresar'),
      );
      await tester.tap(find.text('¿Olvidaste tu contraseña?'));
      await tester.pumpAndSettle();
      expect(find.text('Recuperar contraseña'), findsOneWidget);
      expect(tester.getRect(find.byKey(const ValueKey('auth-brand'))), brand);
      expect(
        tester.getSize(find.byKey(const ValueKey('recovery-email'))),
        inputSize,
      );
      expect(
        tester.getSize(find.widgetWithText(FilledButton, 'Enviar código')),
        buttonSize,
      );
      final reveal = tester.state(find.byType(StaggerReveal));
      await tester.ensureVisible(find.text('Enviar código'));
      await tester.tap(find.text('Enviar código'));
      await tester.pumpAndSettle();
      expect(find.text('Correo no válido'), findsOneWidget);
      expect(repo.sends, 0);
      expect(tester.state(find.byType(StaggerReveal)), same(reveal));
      await tester.enterText(
        find.byKey(const ValueKey('recovery-email')),
        'ana@example.com',
      );
      repo.failure = RecoveryFailureKind.unavailable;
      await tester.ensureVisible(find.text('Enviar código'));
      await tester.tap(find.text('Enviar código'));
      await tester.pumpAndSettle();
      expect(
        find.text('No pudimos completar la solicitud. Reintenta.'),
        findsOneWidget,
      );
      repo.failure = null;
      await tester.ensureVisible(find.text('Enviar código'));
      await tester.tap(find.text('Enviar código'));
      await tester.pumpAndSettle();
      expect(find.text('Revisa tu correo'), findsOneWidget);
      expect(
        find.text('Ingresa el código que llegó a ana@example.com.'),
        findsOneWidget,
      );
      await container.read(passwordRecoveryViewModelProvider.notifier).resend();
      expect(repo.sends, 2);
      await tester.pump(const Duration(seconds: 60));
      await tester.pump();
      await tester.ensureVisible(find.text('Reenviar código'));
      await tester.tap(find.text('Reenviar código'));
      await tester.pumpAndSettle();
      expect(repo.sends, 3);
      expect(find.text('Volver a iniciar sesión'), findsNothing);
      await tester.ensureVisible(find.byTooltip('Cerrar registro'));
      await tester.tap(find.byTooltip('Cerrar registro'));
      await tester.pump();
      expect(find.text('Revisa tu correo'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Iniciar sesión'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  for (final cold in [false, true]) {
    testWidgets(
      'Recovery callback takes precedence over home, saves then signs out; cold=$cold',
      (tester) async {
        final auth = FakeAuthRepository();
        final repo = FakePasswordRecovery()..onEnd = () => auth.emit(null);
        final onboarding = FakeOnboarding(auth)..completed.add('user');
        if (cold) {
          auth.current = const AuthSession(userId: 'user');
          repo.current = RecoveryAccess.ready;
        }
        final container = ProviderContainer(
          overrides: [
            startupStateProvider.overrideWithValue(
              const StartupState(StartupStatus.ready),
            ),
            authRepositoryProvider.overrideWithValue(auth),
            accessRepositoryProvider.overrideWithValue(FakeAccess()),
            passwordRecoveryRepositoryProvider.overrideWithValue(repo),
            onboardingRepositoryProvider.overrideWithValue(onboarding),
          ],
        );
        addTearDown(() async {
          container.dispose();
          await auth.controller.close();
          await repo.events.close();
        });
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const EntreHuellasApp(),
          ),
        );
        await tester.pumpAndSettle();
        if (!cold) {
          auth.emit(const AuthSession(userId: 'user'));
          repo.emit(RecoveryAccess.ready);
          await tester.pumpAndSettle();
        }
        expect(find.byKey(const ValueKey('recovery-password')), findsOneWidget);
        expect(
          container
              .read(routerProvider)
              .routeInformationProvider
              .value
              .uri
              .path,
          '/reset-password',
        );
        // A regular authenticated navigation cannot bypass the recovery gate.
        container.read(routerProvider).go('/home');
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('recovery-password')), findsOneWidget);
        await tester.enterText(
          find.byKey(const ValueKey('recovery-password')),
          'new-password',
        );
        await tester.enterText(
          find.byKey(const ValueKey('recovery-confirmation')),
          'mismatch',
        );
        await tester.ensureVisible(find.text('Guardar contraseña'));
        await tester.tap(find.text('Guardar contraseña'));
        await tester.pumpAndSettle();
        expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
        expect(repo.updates, 0);
        await tester.enterText(
          find.byKey(const ValueKey('recovery-confirmation')),
          'new-password',
        );
        await tester.ensureVisible(find.text('Guardar contraseña'));
        await tester.tap(find.text('Guardar contraseña'));
        await tester.pumpAndSettle();
        expect(repo.savedPassword, 'new-password');
        expect(find.text('Contraseña actualizada'), findsOneWidget);
        await tester.tap(find.text('Volver a iniciar sesión'));
        await tester.pumpAndSettle();
        expect(repo.ends, 1);
        expect(find.text('Iniciar sesión'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Invalid link, observation error and next event recover; system back cancels',
    (tester) async {
      final auth = FakeAuthRepository();
      final repo = FakePasswordRecovery()..current = RecoveryAccess.invalid;
      final container = ProviderContainer(
        overrides: [
          startupStateProvider.overrideWithValue(
            const StartupState(StartupStatus.ready),
          ),
          authRepositoryProvider.overrideWithValue(auth),
          accessRepositoryProvider.overrideWithValue(FakeAccess()),
          passwordRecoveryRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await auth.controller.close();
        await repo.events.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const EntreHuellasApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Enlace no válido'), findsOneWidget);
      await tester.tap(find.text('Volver a iniciar sesión'));
      await tester.pumpAndSettle();
      expect(find.text('Iniciar sesión'), findsOneWidget);
      repo.events.addError(
        const RecoveryFailure(RecoveryFailureKind.unavailable),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Recuperación no disponible'), findsOneWidget);
      repo.emit(RecoveryAccess.ready);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('recovery-password')), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Iniciar sesión'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Request and reset scroll with enlarged text and reduced motion',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.binding.setSurfaceSize(const Size(320, 350));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final auth = FakeAuthRepository();
      final repo = FakePasswordRecovery();
      final container = ProviderContainer(
        overrides: [
          startupStateProvider.overrideWithValue(
            const StartupState(StartupStatus.ready),
          ),
          authRepositoryProvider.overrideWithValue(auth),
          accessRepositoryProvider.overrideWithValue(FakeAccess()),
          passwordRecoveryRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await auth.controller.close();
        await repo.events.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const EntreHuellasApp(),
        ),
      );
      await tester.pumpAndSettle();
      container.read(routerProvider).push('/recover-password');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('recovery-email')));
      await tester.enterText(
        find.byKey(const ValueKey('recovery-email')),
        'ana@example.com',
      );
      await tester.ensureVisible(find.text('Enviar código'));
      await tester.ensureVisible(find.text('Enviar código'));
      await tester.tap(find.text('Enviar código'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.textContaining('Reenviar código'));
      await tester.pumpAndSettle();
      repo.emit(RecoveryAccess.ready);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Guardar contraseña'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
