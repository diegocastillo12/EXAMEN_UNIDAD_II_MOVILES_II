import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/failures/access_failure.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/state/login_view_state.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/view_models/login_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/widgets/login_credentials_form.dart';
import 'access_test.dart' show FakeAccess;

void main() {
  test(
    'Credential rejection marks both fields; confirmation and service failures are distinguished',
    () async {
      final repo = FakeAccess();
      final container = ProviderContainer(
        overrides: [accessRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen(loginViewModelProvider, (_, _) {});
      final vm = container.read(loginViewModelProvider.notifier);
      repo.failure = const AccessFailure(AccessFailureKind.rejected);
      await vm.password('user@example.com', 'wrong');
      var state = container.read(loginViewModelProvider);
      expect(state.emailInvalid && state.passwordInvalid, isTrue);
      final firstId = state.errorId;
      await vm.password('user@example.com', 'wrong');
      expect(
        container.read(loginViewModelProvider).errorId,
        greaterThan(firstId),
      );
      vm.fieldEdited(LoginField.email);
      expect(container.read(loginViewModelProvider).fieldIssue, isNull);
      repo.failure = const AccessFailure(AccessFailureKind.emailNotConfirmed);
      await vm.password('user@example.com', 'password');
      state = container.read(loginViewModelProvider);
      expect(state.emailInvalid, isTrue);
      expect(state.passwordInvalid, isFalse);
      expect(state.emailHint, 'Confirma tu correo');
      repo.failure = const AccessFailure(AccessFailureKind.unavailable);
      await vm.password('user@example.com', 'password');
      state = container.read(loginViewModelProvider);
      expect(state.fieldIssue, isNull);
      expect(state.isError, isTrue);
    },
  );

  for (final reducedMotion in [false, true]) {
    testWidgets(
      'Only the invalid email is outlined and motion respects reducedMotion=$reducedMotion',
      (tester) async {
        final container = ProviderContainer(
          overrides: [accessRepositoryProvider.overrideWithValue(FakeAccess())],
        );
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(disableAnimations: reducedMotion),
                child: child!,
              ),
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, _) => LoginCredentialsForm(
                    isBusy: false,
                    feedback: ref.watch(loginViewModelProvider),
                    onFieldEdited: ref
                        .read(loginViewModelProvider.notifier)
                        .fieldEdited,
                    onSubmit: ref
                        .read(loginViewModelProvider.notifier)
                        .password,
                    onRecover: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );
        final email = find.byKey(const ValueKey('login-email'));
        final password = find.byKey(const ValueKey('login-password'));
        await container
            .read(loginViewModelProvider.notifier)
            .password('invalid', 'password');
        await tester.pump();
        final restingX = tester.getTopLeft(email).dx;
        final emailBorder =
            tester.widget<TextField>(email).decoration!.enabledBorder!
                as OutlineInputBorder;
        final passwordBorder =
            tester.widget<TextField>(password).decoration!.enabledBorder!
                as OutlineInputBorder;
        expect(emailBorder.borderSide.color, const Color(0xFFB53F48));
        expect(emailBorder.borderSide.width, 3.5);
        expect(
          tester.widget<TextField>(email).style!.color,
          const Color(0xFFB53F48),
        );
        expect(
          tester.widget<TextField>(password).style!.color,
          isNot(const Color(0xFFB53F48)),
        );
        expect(
          tester.widget<TextField>(email).decoration!.fillColor,
          tester.widget<TextField>(password).decoration!.fillColor,
        );
        expect(
          passwordBorder.borderSide.color,
          isNot(emailBorder.borderSide.color),
        );
        await tester.pump(const Duration(milliseconds: 45));
        if (reducedMotion) {
          expect(tester.getTopLeft(email).dx, restingX);
        } else {
          expect(tester.getTopLeft(email).dx, isNot(closeTo(restingX, .1)));
        }
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(email).dx, closeTo(restingX, .1));
        await tester.enterText(email, 'user@example.com');
        await tester.pumpAndSettle();
        expect(find.text('Correo no válido'), findsNothing);
        expect(
          tester.widget<TextField>(email).style!.color,
          isNot(const Color(0xFFB53F48)),
        );
      },
    );
  }
}
