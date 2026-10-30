import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'support/fake_password_recovery.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/registration_outcome.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/failures/registration_failure.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/repositories/registration_repository.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/use_cases/register_account.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/state/registration_view_state.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/view_models/registration_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/registration_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'access_test.dart' show FakeAccess;

class FakeRegistration implements RegistrationRepository {
  int verifications = 0;
  String? verifiedCode;
  void Function()? onVerified;
  @override
  Future<void> verifyCode(String email, String code) async {
    verifications++;
    verifiedCode = code;
    if (failure != null) throw failure!;
    onVerified?.call();
  }

  int calls = 0;
  int resends = 0;
  String? name;
  String? email;
  String? password;
  RegistrationFailure? failure;
  RegistrationOutcome outcome = RegistrationOutcome.confirmationRequired;
  Completer<RegistrationOutcome>? pending;
  @override
  Future<RegistrationOutcome> register({
    required String name,
    required String email,
    required String password,
  }) async {
    calls++;
    this.name = name;
    this.email = email;
    this.password = password;
    if (failure != null) throw failure!;
    return pending == null ? outcome : pending!.future;
  }

  @override
  Future<void> resendConfirmation(String email) async {
    resends++;
    if (failure != null) throw failure!;
  }
}

void main() {
  testWidgets(
    'Close and system back contract registration to its trigger before popping',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final auth = FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [
          startupStateProvider.overrideWithValue(
            const StartupState(StartupStatus.ready),
          ),
          passwordRecoveryRepositoryProvider.overrideWithValue(
            FakePasswordRecovery(),
          ),
          authRepositoryProvider.overrideWithValue(auth),
          accessRepositoryProvider.overrideWithValue(FakeAccess()),
          registrationRepositoryProvider.overrideWithValue(FakeRegistration()),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await auth.controller.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const EntreHuellasApp(),
        ),
      );
      await tester.pumpAndSettle();
      for (final useBack in [true, false]) {
        final trigger = find.widgetWithText(TextButton, 'Crear cuenta');
        await tester.ensureVisible(trigger);
        final origin = tester.getRect(trigger);
        await tester.tap(trigger);
        await tester.pump();
        await tester.pump();
        expect(
          tester
              .widget<OriginPageTransition>(find.byType(OriginPageTransition))
              .origin,
          origin,
        );
        await tester.pumpAndSettle();
        if (useBack) {
          await tester.tap(find.byTooltip('Cerrar registro'));
        } else {
          await tester.binding.handlePopRoute();
        }
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 160));
        expect(find.byType(RegisterScreen), findsOneWidget);
        final transition = tester.widget<OriginPageTransition>(
          find.byType(OriginPageTransition),
        );
        expect(transition.animation.status, AnimationStatus.reverse);
        expect(transition.origin, origin);
        await tester.pumpAndSettle();
        expect(find.byType(RegisterScreen), findsNothing);
        expect(find.text('Iniciar sesión'), findsOneWidget);
      }
    },
  );
  for (final reducedMotion in [false, true]) {
    testWidgets(
      'Register reveals all components once; reducedMotion=$reducedMotion',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final container = ProviderContainer(
          overrides: [
            registrationRepositoryProvider.overrideWithValue(
              FakeRegistration(),
            ),
          ],
        );
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(disableAnimations: reducedMotion),
                child: const RegisterScreen(),
              ),
            ),
          ),
        );
        final items = tester.widgetList<StaggerRevealItem>(
          find.byType(StaggerRevealItem),
        );
        expect(items.map((item) => item.order).toSet(), {
          0,
          1,
          2,
          3,
          4,
          5,
          6,
          7,
        });
        double fieldOpacity(String field) => tester
            .widget<Opacity>(
              find.ancestor(
                of: find.byKey(ValueKey('register-$field')),
                matching: find.byType(Opacity),
              ),
            )
            .opacity;
        if (!reducedMotion) {
          expect(fieldOpacity('name'), 0);
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pump(const Duration(milliseconds: 16));
          expect(fieldOpacity('name'), greaterThan(0));
          expect(fieldOpacity('confirmation'), 0);
        } else {
          expect(fieldOpacity('name'), 1);
          expect(fieldOpacity('confirmation'), 1);
        }
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('register-name')),
          'Ana',
        );
        await tester.enterText(
          find.byKey(const ValueKey('register-email')),
          'invalid',
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
        await tester.pumpAndSettle();
        expect(find.text('Correo no válido'), findsOneWidget);
        expect(
          tester
              .widgetList<Opacity>(find.byType(Opacity))
              .every((opacity) => opacity.opacity == 1),
          isTrue,
        );
        await tester.enterText(
          find.byKey(const ValueKey('register-email')),
          'a@example.com',
        );
        await tester.pump();
        await tester.pump();
        expect(fieldOpacity('email'), 1);
        expect(find.text('Correo no válido'), findsNothing);
        await tester.pumpWidget(const SizedBox());
        expect(tester.takeException(), isNull);
      },
    );
  }
  test(
    'Registration validates before sending, normalizes identity and preserves password spaces',
    () async {
      final repo = FakeRegistration();
      final register = RegisterAccount(repo);
      for (final entry in [
        (
          '',
          'a@example.com',
          '12345678',
          '12345678',
          RegistrationFailureKind.invalidName,
        ),
        (
          'Ana',
          'bad',
          '12345678',
          '12345678',
          RegistrationFailureKind.invalidEmail,
        ),
        (
          'Ana',
          'a@example.com',
          '123',
          '123',
          RegistrationFailureKind.weakPassword,
        ),
        (
          'Ana',
          'a@example.com',
          '12345678',
          '12345679',
          RegistrationFailureKind.passwordMismatch,
        ),
      ]) {
        await expectLater(
          register(
            name: entry.$1,
            email: entry.$2,
            password: entry.$3,
            confirmation: entry.$4,
          ),
          throwsA(
            isA<RegistrationFailure>().having((e) => e.kind, 'kind', entry.$5),
          ),
        );
      }
      expect(repo.calls, 0);
      await register(
        name: ' Ana ',
        email: ' a@example.com ',
        password: ' secret password ',
        confirmation: ' secret password ',
      );
      expect(repo.name, 'Ana');
      expect(repo.email, 'a@example.com');
      expect(repo.password, ' secret password ');
    },
  );

  test(
    'ViewModel blocks duplicate sends and handles disposal during registration',
    () async {
      final repo = FakeRegistration()
        ..pending = Completer<RegistrationOutcome>();
      final container = ProviderContainer(
        overrides: [registrationRepositoryProvider.overrideWithValue(repo)],
      );
      container.listen(registrationViewModelProvider, (_, _) {});
      final vm = container.read(registrationViewModelProvider.notifier);
      final first = vm.submit('Ana', 'a@example.com', '12345678', '12345678');
      await vm.submit('Ana', 'a@example.com', '12345678', '12345678');
      expect(repo.calls, 1);
      container.dispose();
      repo.pending!.complete(RegistrationOutcome.confirmationRequired);
      await first;
    },
  );

  testWidgets(
    'Registration field errors recover, confirmation throttles resend and a session enters onboarding',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repo = FakeRegistration();
      final auth = FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [
          startupStateProvider.overrideWithValue(
            const StartupState(StartupStatus.ready),
          ),
          passwordRecoveryRepositoryProvider.overrideWithValue(
            FakePasswordRecovery(),
          ),
          authRepositoryProvider.overrideWithValue(auth),
          accessRepositoryProvider.overrideWithValue(FakeAccess()),
          registrationRepositoryProvider.overrideWithValue(repo),
          onboardingRepositoryProvider.overrideWithValue(FakeOnboarding(auth)),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await auth.controller.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const EntreHuellasApp(),
        ),
      );
      await tester.pumpAndSettle();
      final loginBrand = tester.getRect(
        find.byKey(const ValueKey('auth-brand')),
      );
      final loginInputSize = tester.getSize(
        find.byKey(const ValueKey('login-email')),
      );
      final loginButtonSize = tester.getSize(
        find.widgetWithText(FilledButton, 'Ingresar'),
      );
      final loginTitleY = tester
          .getTopLeft(find.byKey(const ValueKey('auth-title')))
          .dy;
      await tester.ensureVisible(find.text('Crear cuenta'));
      await tester.tap(find.text('Crear cuenta'));
      await tester.pump();
      await tester.pump();
      final entrance = tester.widget<OriginPageTransition>(
        find.ancestor(
          of: find.byType(RegisterScreen),
          matching: find.byType(OriginPageTransition),
        ),
      );
      expect(entrance.origin, isNotNull);
      expect(entrance.animation.value, lessThan(1));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(const ValueKey('auth-brand'))),
        loginBrand,
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('auth-title'))).dy,
        loginTitleY,
      );
      expect(find.byType(Checkbox), findsNothing);
      for (final field in ['name', 'email', 'password', 'confirmation']) {
        expect(
          tester.getSize(find.byKey(ValueKey('register-$field'))),
          loginInputSize,
        );
      }
      expect(
        tester.getSize(find.widgetWithText(FilledButton, 'Crear cuenta')),
        loginButtonSize,
      );
      expect(find.text('¿Ya tienes una cuenta?'), findsNothing);
      expect(find.text('Únete para ayudar a más mascotas'), findsNothing);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Crear cuenta'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
      await tester.pumpAndSettle();
      expect(
        container.read(registrationViewModelProvider).errorField,
        RegistrationField.name,
      );
      await tester.enterText(
        find.byKey(const ValueKey('register-name')),
        'Ana',
      );
      await tester.enterText(
        find.byKey(const ValueKey('register-email')),
        'a@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('register-password')),
        '12345678',
      );
      await tester.enterText(
        find.byKey(const ValueKey('register-confirmation')),
        'different',
      );
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Crear cuenta'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('register-confirmation')),
      );
      expect(field.style!.color, const Color(0xFFB53F48));
      expect(
        (field.decoration!.enabledBorder! as OutlineInputBorder)
            .borderSide
            .width,
        3.5,
      );
      expect(repo.calls, 0);
      await tester.enterText(
        find.byKey(const ValueKey('register-confirmation')),
        '12345678',
      );
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Crear cuenta'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
      await tester.pumpAndSettle();
      expect(find.text('Revisa tu correo'), findsOneWidget);
      expect(find.byKey(const ValueKey('email-code')), findsOneWidget);
      final vm = container.read(registrationViewModelProvider.notifier);
      await vm.resend();
      expect(repo.resends, 0);
      await tester.pump(const Duration(seconds: 60));
      await tester.pump();
      await tester.ensureVisible(find.text('Reenviar código'));
      await tester.tap(find.text('Reenviar código'));
      await tester.pumpAndSettle();
      expect(repo.resends, 1);
      auth.emit(const AuthSession(userId: 'registered'));
      await tester.pumpAndSettle();
      expect(find.text('Cada huella'), findsOneWidget);
      expect(find.text('Revisa tu correo'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Registration supports short screens and enlarged text', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.binding.setSurfaceSize(const Size(320, 350));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [
        startupStateProvider.overrideWithValue(
          const StartupState(StartupStatus.ready),
        ),
        passwordRecoveryRepositoryProvider.overrideWithValue(
          FakePasswordRecovery(),
        ),
        authRepositoryProvider.overrideWithValue(auth),
        accessRepositoryProvider.overrideWithValue(FakeAccess()),
        registrationRepositoryProvider.overrideWithValue(FakeRegistration()),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await auth.controller.close();
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const EntreHuellasApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Crear cuenta'));
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, -1500),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
