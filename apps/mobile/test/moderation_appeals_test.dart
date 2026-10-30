import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/moderation_appeals/domain/entities/moderation_appeal.dart';
import 'package:flutter_application_entrehuellas/features/moderation_appeals/domain/repositories/appeals_repository.dart';
import 'package:flutter_application_entrehuellas/features/moderation_appeals/domain/use_cases/appeal_actions.dart';
import 'package:flutter_application_entrehuellas/features/moderation_appeals/data/data_sources/appeals_source.dart';
import 'package:flutter_application_entrehuellas/features/moderation_appeals/data/repositories/appeals_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/moderation_appeals/providers/appeals_providers.dart';
import 'package:flutter_application_entrehuellas/features/moderation_appeals/presentation/screens/appeals_screen.dart';
import 'package:flutter_application_entrehuellas/features/moderation_appeals/presentation/view_models/appeals_view_model.dart';
import 'alert_preferences_test.dart' show loadFonts;
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'support/fake_password_recovery.dart';
import 'support/fake_profile.dart';

const decisionId = 'cccccccc-cccc-4ccc-8ccc-000000000001';
const commandId = 'cccccccc-cccc-4ccc-8ccc-000000000009';
ModeratedDecision decision([AppealSubmission? appeal]) => ModeratedDecision(
  id: decisionId,
  kind: 'lost',
  resource: decisionId,
  action: 'hide',
  reason: 'La publicación necesita revisión.',
  decidedAt: DateTime.utc(2026, 10, 23, 12),
  appeal: appeal,
);

class FakeAppeals implements AppealsRepository {
  ModeratedDecision item = decision();
  final attempts = <AppealCommand>[];
  AppealIssue? failure, readFailure;
  Completer<void>? pending;
  @override
  Future<AppealPage> list(String actor, AppealCursor? cursor) async {
    if (readFailure != null) throw AppealFailure(readFailure!);
    return AppealPage(items: [item]);
  }

  @override
  Future<ModeratedDecision> submit(String actor, AppealCommand command) async {
    attempts.add(command);
    await pending?.future;
    if (failure != null) throw AppealFailure(failure!);
    item = decision(
      AppealSubmission(
        id: command.id,
        reason: command.reason,
        submittedAt: DateTime.utc(2026, 10, 23, 12, 10),
      ),
    );
    return item;
  }
}

class FakeSource implements AppealsSource {
  Object? value;
  String? failure;
  Map<String, dynamic>? params;
  @override
  Future<Object?> list(String actor, Map<String, dynamic> params) async =>
      value;
  @override
  Future<Object?> submit(String actor, Map<String, dynamic> params) async {
    this.params = params;
    if (failure != null) throw AppealSourceFailure(failure!);
    return value;
  }
}

ProviderContainer container(
  FakeAppeals repo, [
  Stream<AuthSession?>? sessions,
]) => ProviderContainer(
  overrides: [
    appealsRepositoryProvider.overrideWithValue(repo),
    appealsSessionProvider.overrideWith(
      (ref) => sessions ?? Stream.value(const AuthSession(userId: 'actor')),
    ),
  ],
);
void main() {
  for (final authenticated in [false, true]) {
    testWidgets(
      'HU14.4 real router authorizes appeals only after account/onboarding; authenticated=$authenticated',
      (tester) async {
        final auth = FakeAuthRepository();
        if (authenticated) auth.current = const AuthSession(userId: 'actor');
        final onboarding = FakeOnboarding(auth)..completed.add('actor');
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
            appealsRepositoryProvider.overrideWithValue(FakeAppeals()),
          ],
        );
        addTearDown(() async {
          c.dispose();
          await auth.controller.close();
        });
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: c,
            child: const EntreHuellasApp(),
          ),
        );
        await tester.pumpAndSettle();
        c.read(routerProvider).go('/home/appeals');
        await tester.pumpAndSettle();
        expect(
          c.read(routerProvider).routeInformationProvider.value.uri.path,
          authenticated ? '/home/appeals' : '/access',
        );
        expect(
          find.byType(AppealsScreen),
          authenticated ? findsOneWidget : findsNothing,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
  test(
    'HU14.4 validates Unicode reason and stable identifiers before submission',
    () async {
      final repo = FakeAppeals(), action = SubmitAppeal(FakeAppeals());
      for (final reason in ['', '\u00a0\u3000', '🐾' * 1001]) {
        expect(() => action.validate(reason), throwsA(isA<AppealFailure>()));
      }
      action.validate('🐾' * 1000);
      await SubmitAppeal(repo)(
        'actor',
        const AppealCommand(
          id: commandId,
          decision: decisionId,
          reason: ' Motivo ',
        ),
      );
      expect(repo.attempts.single.reason, 'Motivo');
      expect(
        () => action(
          'actor',
          const AppealCommand(
            id: 'bad',
            decision: decisionId,
            reason: 'Motivo',
          ),
        ),
        throwsA(isA<AppealFailure>()),
      );
    },
  );
  test(
    'HU14.4 repository rejects mismatched receipts and maps infrastructure failures',
    () async {
      final source = FakeSource(), repo = AppealsRepositoryImpl(FakeSource());
      final actual = AppealsRepositoryImpl(source);
      const command = AppealCommand(
        id: commandId,
        decision: decisionId,
        reason: 'Motivo',
      );
      final row = {
        'decision': decisionId,
        'resource': decisionId,
        'kind': 'lost',
        'action': 'hide',
        'reason': 'Decisión',
        'decidedAt': '2026-10-23T12:00:00Z',
        'appeal': {
          'id': commandId,
          'reason': 'Motivo',
          'submittedAt': '2026-10-23T12:10:00Z',
          'answer': null,
        },
      };
      source.value = row;
      expect((await actual.submit('actor', command)).appeal!.id, commandId);
      expect(source.params!['p_decision'], decisionId);
      source.value = {...row, 'decision': commandId};
      await expectLater(
        actual.submit('actor', command),
        throwsA(
          isA<AppealFailure>().having(
            (e) => e.issue,
            'issue',
            AppealIssue.unavailable,
          ),
        ),
      );
      for (final issue in AppealIssue.values) {
        source.failure = issue.name;
        await expectLater(
          actual.submit('actor', command),
          throwsA(isA<AppealFailure>().having((e) => e.issue, 'issue', issue)),
        );
      }
      await expectLater(
        repo.list('actor', null),
        throwsA(isA<AppealFailure>()),
      );
    },
  );
  test(
    'HU14.4 ambiguous retry freezes payload, prevents duplicates and recovers after conflict refresh failure',
    () async {
      final repo = FakeAppeals();
      final c = container(repo);
      addTearDown(c.dispose);
      final subscription = c.listen(appealsViewModelProvider, (_, _) {});
      addTearDown(subscription.close);
      await c.read(appealsViewModelProvider.future);
      final model = c.read(appealsViewModelProvider.notifier);
      model.select(repo.item);
      model.edit('Motivo propio');
      repo.failure = AppealIssue.unavailable;
      repo.pending = Completer<void>();
      final first = model.submit();
      await model.submit();
      expect(repo.attempts.length, 1);
      repo.pending!.complete();
      await first;
      model.edit('Cambio');
      expect(
        c.read(appealsViewModelProvider).requireValue.reason,
        'Motivo propio',
      );
      repo.failure = AppealIssue.conflict;
      await model.submit();
      expect(repo.attempts[0].id, repo.attempts[1].id);
      repo.readFailure = AppealIssue.unavailable;
      await model.load();
      expect(
        c.read(appealsViewModelProvider).requireValue.refreshRequired,
        true,
      );
      await model.submit();
      expect(repo.attempts.length, 2);
      repo.readFailure = null;
      await model.load();
      expect(
        c.read(appealsViewModelProvider).requireValue.reason,
        'Motivo propio',
      );
      expect(c.read(appealsViewModelProvider).requireValue.frozen, isNull);
      repo.failure = null;
      await model.submit();
      expect(c.read(appealsViewModelProvider).requireValue.saved, true);
    },
  );
  test(
    'HU14.4 account changes and disposal discard late private submissions',
    () async {
      final sessions = StreamController<AuthSession?>(), repo = FakeAppeals();
      final c = container(repo, sessions.stream);
      addTearDown(sessions.close);
      final subscription = c.listen(appealsViewModelProvider, (_, _) {});
      sessions.add(const AuthSession(userId: 'actor'));
      await c.read(appealsViewModelProvider.future);
      final model = c.read(appealsViewModelProvider.notifier);
      model.select(repo.item);
      model.edit('Privado');
      repo.pending = Completer<void>();
      final pending = model.submit();
      sessions.add(const AuthSession(userId: 'other'));
      await Future<void>.delayed(Duration.zero);
      await c.read(appealsViewModelProvider.future);
      repo.pending!.complete();
      await pending;
      expect(c.read(appealsViewModelProvider).requireValue.actor, 'other');
      expect(c.read(appealsViewModelProvider).requireValue.selected, isNull);
      model.select(repo.item);
      model.edit('Otro');
      repo.pending = Completer<void>();
      final disposed = model.submit();
      subscription.close();
      c.dispose();
      repo.pending!.complete();
      await disposed;
    },
  );
  for (final small in [false, true]) {
    testWidgets(
      'HU14.4 own appeal form, validation, response and ${small ? '320px text 200%' : '390px'} layout',
      (tester) async {
        await tester.runAsync(loadFonts);
        tester.view.physicalSize = small
            ? const Size(320, 700)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = FakeAppeals();
        final scope = container(repo);
        addTearDown(scope.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: scope,
            child: MaterialApp(
              theme: AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(small ? 2 : 1),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: const RepaintBoundary(
                key: ValueKey('capture-appeals'),
                child: AppealsScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Apelar decisión'));
        await tester.tap(find.text('Apelar decisión'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Enviar apelación'));
        await tester.tap(find.text('Enviar apelación'));
        await tester.pumpAndSettle();
        expect(
          find.text('Escribe un motivo de hasta 1000 caracteres.'),
          findsOneWidget,
        );
        await tester.enterText(
          find.byType(TextField),
          'Solicito revisar mi publicación.',
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final image = await tester
              .renderObject<RenderRepaintBoundary>(
                find.byKey(const ValueKey('capture-appeals')),
              )
              .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            'build/ui-preview/appeals-mobile/${small ? 'small-text' : 'normal'}-form.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.ensureVisible(find.text('Enviar apelación'));
        await tester.tap(find.text('Enviar apelación'));
        await tester.pumpAndSettle();
        expect(find.text('Pendiente de respuesta'), findsOneWidget);
        expect(repo.attempts.length, 1);
        repo.item = decision(
          AppealSubmission(
            id: repo.attempts.single.id,
            reason: 'Solicito revisar mi publicación.',
            submittedAt: DateTime.utc(2026, 10, 23),
            answer: AppealAnswer(
              id: commandId,
              actor: decisionId,
              reason: 'La apelación fue revisada.',
              answeredAt: DateTime.utc(2026, 10, 23, 13),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 7));
        await Scrollable.ensureVisible(
          tester.element(find.text('Actualizar consulta')),
          alignment: .5,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Actualizar consulta'));
        await tester.pumpAndSettle();
        expect(find.text('La apelación fue revisada.'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
