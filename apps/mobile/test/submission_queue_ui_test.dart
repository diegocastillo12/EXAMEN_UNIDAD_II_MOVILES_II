import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/entities/queued_report.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/providers/local_draft_providers.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/providers/submission_queue_providers.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/presentation/screens/submission_queue_screen.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/presentation/view_models/submission_sync_view_model.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/entities/lost_case.dart';
import 'support/fake_local_drafts.dart';
import 'support/fake_password_recovery.dart';
import 'support/fake_profile.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'submission_queue_test.dart' show command, transport, IdempotentCases;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final e in {
      'Poppins': 'assets/fonts/Poppins-Regular.ttf',
      'sans-serif': 'assets/fonts/Roboto-Regular.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(e.key)..addFont(rootBundle.load(e.value))).load();
    }
  });
  for (final stage in ['guest', 'onboarding', 'ready']) {
    testWidgets('Queue route uses global account stage $stage', (tester) async {
      final auth = FakeAuthRepository();
      if (stage != 'guest') auth.current = const AuthSession(userId: 'A');
      final onboarding = FakeOnboarding(auth);
      if (stage == 'ready') onboarding.completed.add('A');
      final local = FakeLocalDrafts();
      await local.enqueue(command());
      final server = IdempotentCases();
      final container = ProviderContainer(
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
          localDraftRepositoryProvider.overrideWithValue(local),
          submissionTransportProvider.overrideWithValue(transport(server)),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await auth.controller.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const EntreHuellasApp(observeQueue: true),
        ),
      );
      await tester.pumpAndSettle();
      container.read(routerProvider).go('/home/submissions');
      await tester.pumpAndSettle();
      expect(
        container.read(routerProvider).routeInformationProvider.value.uri.path,
        stage == 'ready'
            ? '/home/submissions'
            : stage == 'guest'
            ? '/access'
            : '/onboarding',
      );
      expect(
        find.byType(SubmissionQueueScreen),
        stage == 'ready' ? findsOneWidget : findsNothing,
      );
      expect(server.attempts, hasLength(stage == 'ready' ? 1 : 0));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  for (final small in [false, true]) {
    testWidgets(
      'Queue states, reasons and actions remain accessible small=$small',
      (tester) async {
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.platformDispatcher.textScaleFactorTestValue = small ? 2 : 1;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final local = FakeLocalDrafts(), now = DateTime.now();
        for (final status in [
          SubmissionStatus.pending,
          SubmissionStatus.failed,
          SubmissionStatus.published,
        ]) {
          final d = command(id: status.name);
          local.submissions[('A', d.id)] = QueuedReport(
            command: d,
            status: status,
            attempts: 1,
            createdAt: now,
            nextAttemptAt: now,
            issue: status == SubmissionStatus.failed
                ? SubmissionIssue.conflict
                : null,
            receipt: status == SubmissionStatus.published
                ? SubmissionReceipt.lost(
                    PublishedLostCase(
                      id: d.id,
                      ownerId: 'A',
                      petId: 'pet',
                      status: 'active',
                    ),
                  )
                : null,
          );
        }
        local.submissions[('B', 'private')] = QueuedReport(
          command: command(owner: 'B', id: 'private'),
          status: SubmissionStatus.failed,
          attempts: 0,
          createdAt: now,
          nextAttemptAt: now,
        );
        var opened = 0;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localDraftRepositoryProvider.overrideWithValue(local),
              localDraftSessionProvider.overrideWith(
                (ref) => Stream.value(const AuthSession(userId: 'A')),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: RepaintBoundary(
                key: const ValueKey('capture'),
                child: SubmissionQueueScreen(onOpen: (_) => opened++),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Pendiente de envío'), findsOneWidget);
        expect(find.text('Fallido · Requiere revisión'), findsOneWidget);
        expect(find.text('Publicado'), findsOneWidget);
        Future<void> capture(String frame) async {
          if (Platform.environment['CAPTURE_SUBMISSION_QUEUE'] != '1') return;
          await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const ValueKey('capture')),
            );
            final img = await boundary.toImage();
            final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
            final directory = Directory('build/ui-preview/submission-queue')
              ..createSync(recursive: true);
            File(
              '${directory.path}/${small ? 'small' : 'normal'}-$frame.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            img.dispose();
          });
        }

        await capture('top');
        await tester.ensureVisible(find.text('Ver motivo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ver motivo'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('no coincide con el envío original'),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 6));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Ver resultado'));
        await tester.pumpAndSettle();
        await capture('result');
        await tester.tap(find.text('Ver resultado'));
        expect(opened, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  test(
    'Foreground synchronizer stays quiet when disabled and drains on resume for the current account',
    () async {
      final local = FakeLocalDrafts();
      await local.enqueue(command());
      final server = IdempotentCases();
      final sessions = StreamController<AuthSession?>.broadcast();
      final container = ProviderContainer(
        overrides: [
          localDraftRepositoryProvider.overrideWithValue(local),
          localDraftSessionProvider.overrideWith((ref) => sessions.stream),
          submissionTransportProvider.overrideWithValue(transport(server)),
        ],
      );
      container.listen(submissionSyncViewModelProvider, (_, _) {});
      addTearDown(container.dispose);
      addTearDown(sessions.close);
      sessions.add(const AuthSession(userId: 'A'));
      await Future<void>.delayed(Duration.zero);
      expect(server.attempts, isEmpty);
      container.read(submissionSyncViewModelProvider.notifier).setEnabled(true);
      await server.started.future;
      await Future<void>.delayed(Duration.zero);
      expect(
        (await local.listQueue('A')).single.status,
        SubmissionStatus.published,
      );
      container
          .read(submissionSyncViewModelProvider.notifier)
          .setEnabled(false);
      await local.enqueue(command(id: 'another'));
      sessions.add(const AuthSession(userId: 'B'));
      await Future<void>.delayed(Duration.zero);
      expect(server.attempts, hasLength(1));
      await local.enqueue(command(owner: 'B', id: 'pending-B'));
      container
          .read(submissionSyncViewModelProvider.notifier)
          .setEnabled(true, owner: 'A');
      await Future<void>.delayed(Duration.zero);
      expect(server.attempts, hasLength(1));
      container
          .read(submissionSyncViewModelProvider.notifier)
          .setEnabled(true, owner: 'B');
      await Future<void>.delayed(Duration.zero);
      expect(server.attempts, hasLength(2));
      expect(server.attempts.last.id, 'pending-B');
      expect(container.read(submissionSyncViewModelProvider).owner, 'B');
    },
  );
}
