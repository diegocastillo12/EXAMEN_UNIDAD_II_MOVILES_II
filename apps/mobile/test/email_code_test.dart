import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/cover_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/loading_shimmer.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/widgets/email_code_confirmation.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/data_sources/supabase_registration_data_source.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/data_sources/supabase_password_recovery_data_source.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/repositories/registration_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/repositories/password_recovery_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/recovery_access.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/failures/registration_failure.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/failures/recovery_failure.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/use_cases/verify_registration_code.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/use_cases/verify_recovery_code.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/widgets/email_code_input.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/view_models/registration_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/view_models/password_recovery_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/registration_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'access_test.dart' show FakeAccess;
import 'registration_test.dart' show FakeRegistration;
import 'support/fake_password_recovery.dart';
import 'supabase_registration_data_source_test.dart' show MemoryPkceStorage;

void main() {
  for (final reduced in [false, true]) {
    testWidgets(
      'Flat cover precedes stagger with stable brand; reduced=$reduced',
      (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            FakeAccessibilityFeatures(disableAnimations: reduced);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        final auth = FakeAuthRepository();
        final recovery = FakePasswordRecovery();
        final container = ProviderContainer(
          overrides: [
            startupStateProvider.overrideWithValue(
              const StartupState(StartupStatus.ready),
            ),
            authRepositoryProvider.overrideWithValue(auth),
            accessRepositoryProvider.overrideWithValue(FakeAccess()),
            passwordRecoveryRepositoryProvider.overrideWithValue(recovery),
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
        container.read(routerProvider).push('/recover-password');
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('recovery-email')),
          'ana@example.com',
        );
        await tester.ensureVisible(find.text('Enviar código'));
        final brandRect = tester.getRect(
          find.byKey(const ValueKey('auth-brand')),
        );
        final brandRender = tester.renderObject(
          find.byKey(const ValueKey('auth-brand')),
        );
        await tester.tap(find.text('Enviar código'));
        await tester.pump();
        await tester.pump();
        if (reduced) {
          expect(find.byType(CoverReveal), findsNothing);
          expect(find.byKey(const ValueKey('recovery-email')), findsNothing);
        } else {
          expect(find.byType(CoverReveal), findsOneWidget);
          final pendingReveal = find
              .ancestor(
                of: find.byType(EmailCodeConfirmation),
                matching: find.byType(StaggerReveal),
              )
              .first;
          expect(tester.widget<StaggerReveal>(pendingReveal).play, false);
          await tester.pump(const Duration(milliseconds: 160));
          expect(tester.widget<StaggerReveal>(pendingReveal).play, false);
          expect(
            tester.getRect(find.byKey(const ValueKey('auth-brand'))),
            brandRect,
          );
          expect(
            tester.renderObject(find.byKey(const ValueKey('auth-brand'))),
            same(brandRender),
          );
          expect(find.byKey(const ValueKey('recovery-email')), findsOneWidget);
          expect(
            tester
                .widget<TextField>(find.byKey(const ValueKey('recovery-email')))
                .controller!
                .text,
            'ana@example.com',
          );
          expect(
            tester
                .widget<Opacity>(
                  find
                      .ancestor(
                        of: find.text('Revisa tu correo'),
                        matching: find.byType(Opacity),
                      )
                      .first,
                )
                .opacity,
            lessThan(1),
          );
        }
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('recovery-email')), findsNothing);
        final timelineFinder = find
            .ancestor(
              of: find.byType(EmailCodeConfirmation),
              matching: find.byType(StaggerReveal),
            )
            .first;
        final timeline = tester.state(timelineFinder);
        expect(tester.widget<StaggerReveal>(timelineFinder).count, 9);
        await tester.pump(const Duration(seconds: 60));
        await tester.pump();
        await tester.ensureVisible(find.text('Reenviar código'));
        await tester.tap(find.text('Reenviar código'));
        await tester.pumpAndSettle();
        expect(tester.state(timelineFinder), same(timeline));
        expect(find.byType(CoverReveal), findsNothing);
        recovery.failure = RecoveryFailureKind.invalidCode;
        await tester.ensureVisible(find.byKey(const ValueKey('email-code')));
        await tester.enterText(
          find.byKey(const ValueKey('email-code')),
          '123456',
        );
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Código incorrecto o vencido'),
          findsOneWidget,
        );
        expect(tester.state(timelineFinder), same(timeline));
        final brandBeforeReset = tester.renderObject(
          find.byKey(const ValueKey('auth-brand')),
        );
        recovery.failure = null;
        recovery.emit(RecoveryAccess.ready);
        await tester.pump();
        await tester.pump();
        expect(
          container
              .read(routerProvider)
              .routerDelegate
              .currentConfiguration
              .lastOrNull!
              .route
              .path,
          '/recover-password',
        );
        expect(
          tester.renderObject(find.byKey(const ValueKey('auth-brand'))),
          same(brandBeforeReset),
        );
        expect(
          container
              .read(routerProvider)
              .routerDelegate
              .currentConfiguration
              .lastOrNull!
              .route
              .path,
          '/recover-password',
        );
        if (!tester
            .platformDispatcher
            .accessibilityFeatures
            .disableAnimations) {
          expect(find.byType(CoverReveal), findsOneWidget);
          final resetTimeline = find
              .ancestor(
                of: find.byKey(const ValueKey('recovery-password')),
                matching: find.byType(StaggerReveal),
              )
              .first;
          expect(tester.widget<StaggerReveal>(resetTimeline).play, false);
        }
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('recovery-password')), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        container.dispose();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
  test('Both use cases reject non-six-digit codes before network', () {
    final registration = FakeRegistration();
    final recovery = FakePasswordRecovery();
    addTearDown(recovery.events.close);
    for (final code in ['12345', '1234567', '123x56', ' 123456']) {
      expect(
        () => VerifyRegistrationCode(registration)('ana@example.com', code),
        throwsA(isA<RegistrationFailure>()),
      );
      expect(
        () => VerifyRecoveryCode(recovery)('ana@example.com', code),
        throwsA(isA<RecoveryFailure>()),
      );
    }
    expect(registration.verifications, 0);
    expect(recovery.verifications, 0);
  });

  for (final recovery in [false, true]) {
    test(
      'SDK verifies ${recovery ? 'recovery' : 'signup'} on a different client without the request PKCE storage',
      () async {
        final user = {
          'id': 'otp-user',
          'aud': 'authenticated',
          'role': 'authenticated',
          'email': 'ana@example.com',
          'created_at': '2026-10-08T00:00:00Z',
        };
        final httpClient = MockClient((request) async {
          if (request.url.path == '/auth/v1/verify') {
            final body = jsonDecode(request.body) as Map;
            expect(body['email'], 'ana@example.com');
            expect(body['token'], '012345');
            expect(body['type'], recovery ? 'recovery' : 'email');
            expect(body.containsKey('code_verifier'), false);
            return http.Response(
              jsonEncode({
                'access_token': 'fake-access-token',
                'refresh_token': 'fake-refresh-token',
                'token_type': 'bearer',
                'expires_in': 3600,
                'user': user,
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response(
            jsonEncode(request.url.path.endsWith('/signup') ? user : {}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        final firstStorage = MemoryPkceStorage();
        final otherStorage = MemoryPkceStorage();
        final first = SupabaseClient(
          'https://example.supabase.co',
          'sb_publishable_test',
          httpClient: httpClient,
          authOptions: AuthClientOptions(
            pkceAsyncStorage: firstStorage,
            autoRefreshToken: false,
          ),
        );
        final second = SupabaseClient(
          'https://example.supabase.co',
          'sb_publishable_test',
          httpClient: httpClient,
          authOptions: AuthClientOptions(
            pkceAsyncStorage: otherStorage,
            autoRefreshToken: false,
          ),
        );
        addTearDown(() async {
          await first.dispose();
          await second.dispose();
          httpClient.close();
        });
        expect(
          await otherStorage.getItem(key: 'supabase.auth.token-code-verifier'),
          isNull,
        );
        if (recovery) {
          await SupabasePasswordRecoveryDataSource(
            first,
          ).sendCode('ana@example.com');
          final repo = PasswordRecoveryRepositoryImpl(
            SupabasePasswordRecoveryDataSource(second),
          );
          final access = repo.watchAccess().firstWhere(
            (status) => status == RecoveryAccess.ready,
          );
          await VerifyRecoveryCode(repo)('ana@example.com', '012345');
          expect(await access, RecoveryAccess.ready);
        } else {
          await SupabaseRegistrationDataSource(first).register(
            name: 'Ana',
            email: 'ana@example.com',
            password: 'new-password',
          );
          await VerifyRegistrationCode(
            RegistrationRepositoryImpl(SupabaseRegistrationDataSource(second)),
          )('ana@example.com', '012345');
        }
        expect(second.auth.currentSession?.user.id, 'otp-user');
        expect(first.auth.currentSession, isNull);
      },
    );

    for (final emptySession in [false, true]) {
      test(
        'Invalid/expired OTP or missing session never confirms ${recovery ? 'recovery' : 'signup'}; empty=$emptySession',
        () async {
          final httpClient = MockClient(
            (_) async => http.Response(
              emptySession
                  ? '{}'
                  : jsonEncode({
                      'error_code': 'otp_expired',
                      'code': 'otp_expired',
                      'msg': 'private detail',
                    }),
              emptySession ? 200 : 403,
              headers: {'content-type': 'application/json'},
            ),
          );
          final sdk = SupabaseClient(
            'https://example.supabase.co',
            'sb_publishable_test',
            httpClient: httpClient,
            authOptions: AuthClientOptions(
              pkceAsyncStorage: MemoryPkceStorage(),
              autoRefreshToken: false,
            ),
          );
          addTearDown(() async {
            await sdk.dispose();
            httpClient.close();
          });
          if (recovery) {
            final repo = PasswordRecoveryRepositoryImpl(
              SupabasePasswordRecoveryDataSource(sdk),
            );
            await expectLater(
              repo.verifyCode('ana@example.com', '123456'),
              throwsA(
                isA<RecoveryFailure>().having(
                  (f) => f.kind,
                  'kind',
                  RecoveryFailureKind.invalidCode,
                ),
              ),
            );
          } else {
            final repo = RegistrationRepositoryImpl(
              SupabaseRegistrationDataSource(sdk),
            );
            await expectLater(
              repo.verifyCode('ana@example.com', '123456'),
              throwsA(
                isA<RegistrationFailure>().having(
                  (f) => f.kind,
                  'kind',
                  RegistrationFailureKind.invalidCode,
                ),
              ),
            );
          }
          expect(sdk.auth.currentSession, isNull);
        },
      );
    }
  }

  testWidgets(
    'Six cells accept paste, preserve leading zero, permit backspace and retry',
    (tester) async {
      final verified = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: EmailCodeInput(
                isBusy: false,
                resendSeconds: 60,
                onVerify: verified.add,
                onEdited: () {},
              ),
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const ValueKey('email-code')),
        '012345',
      );
      await tester.pump();
      expect(verified, ['012345']);
      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('email-code')),
      );
      expect(field.autofillHints, contains(AutofillHints.oneTimeCode));
      await tester.enterText(find.byKey(const ValueKey('email-code')), '01234');
      await tester.pump();
      expect(verified.length, 1);
      await tester.enterText(
        find.byKey(const ValueKey('email-code')),
        '012345',
      );
      await tester.pump();
      await tester.tap(find.text('Verificar código'));
      expect(verified, ['012345', '012345', '012345']);
      expect(tester.takeException(), isNull);
    },
  );

  for (final recovery in [false, true]) {
    testWidgets(
      'OTP form retains wrong code, blocks duplicate calls and goes to ${recovery ? 'reset' : 'onboarding'} only after verification',
      (tester) async {
        final auth = FakeAuthRepository();
        final registration = FakeRegistration()
          ..onVerified = () => auth.emit(const AuthSession(userId: 'otp-user'));
        final passwordRecovery = FakePasswordRecovery();
        final container = ProviderContainer(
          overrides: [
            startupStateProvider.overrideWithValue(
              const StartupState(StartupStatus.ready),
            ),
            authRepositoryProvider.overrideWithValue(auth),
            accessRepositoryProvider.overrideWithValue(FakeAccess()),
            registrationRepositoryProvider.overrideWithValue(registration),
            passwordRecoveryRepositoryProvider.overrideWithValue(
              passwordRecovery,
            ),
            onboardingRepositoryProvider.overrideWithValue(
              FakeOnboarding(auth),
            ),
          ],
        );
        addTearDown(() async {
          container.dispose();
          await auth.controller.close();
          await passwordRecovery.events.close();
        });
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const EntreHuellasApp(),
          ),
        );
        await tester.pumpAndSettle();
        container
            .read(routerProvider)
            .push(recovery ? '/recover-password' : '/register');
        await tester.pumpAndSettle();
        if (recovery) {
          await container
              .read(passwordRecoveryViewModelProvider.notifier)
              .request('ana@example.com');
          passwordRecovery.failure = RecoveryFailureKind.invalidCode;
        } else {
          await container
              .read(registrationViewModelProvider.notifier)
              .submit('Ana', 'ana@example.com', 'new-password', 'new-password');
          registration.failure = const RegistrationFailure(
            RegistrationFailureKind.invalidCode,
          );
        }
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const ValueKey('email-code')));
        await tester.enterText(
          find.byKey(const ValueKey('email-code')),
          '123456',
        );
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Código incorrecto o vencido'),
          findsOneWidget,
        );
        expect(
          tester
              .widget<TextField>(find.byKey(const ValueKey('email-code')))
              .controller!
              .text,
          '123456',
        );
        if (recovery) {
          passwordRecovery.failure = null;
          passwordRecovery.pending = Completer<void>();
        } else {
          registration.failure = null;
        }
        await tester.ensureVisible(find.text('Verificar código'));
        await tester.tap(find.text('Verificar código'));
        if (recovery) {
          await tester.pump(const Duration(milliseconds: 200));
        } else {
          await tester.pumpAndSettle();
        }
        if (recovery) {
          await container
              .read(passwordRecoveryViewModelProvider.notifier)
              .verify('123456');
          expect(passwordRecovery.verifications, 2);
          expect(
            tester
                .widgetList<LoadingShimmer>(find.byType(LoadingShimmer))
                .where((widget) => widget.isLoading)
                .map((widget) => widget.loadingLabel),
            ['Verificando código'],
          );
          passwordRecovery.pending!.complete();
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('recovery-password')),
            findsOneWidget,
          );
          final successBrand = tester.renderObject(
            find.byKey(const ValueKey('auth-brand')),
          );
          await container
              .read(passwordRecoveryViewModelProvider.notifier)
              .reset('new-password', 'new-password');
          await tester.pump();
          await tester.pump();
          if (!tester
              .platformDispatcher
              .accessibilityFeatures
              .disableAnimations) {
            expect(find.byType(CoverReveal), findsOneWidget);
            final successTimeline = find
                .ancestor(
                  of: find.text('Contraseña actualizada'),
                  matching: find.byType(StaggerReveal),
                )
                .first;
            expect(tester.widget<StaggerReveal>(successTimeline).play, false);
          }
          await tester.pumpAndSettle();
          expect(find.text('Contraseña actualizada'), findsOneWidget);
          expect(
            tester.renderObject(find.byKey(const ValueKey('auth-brand'))),
            same(successBrand),
          );
        } else {
          expect(find.text('Cada huella'), findsOneWidget);
        }
        await tester.pumpWidget(const SizedBox());
        container.dispose();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
