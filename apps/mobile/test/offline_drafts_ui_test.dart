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
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/report_draft_status.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/domain/entities/local_report_draft.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/providers/local_draft_providers.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/presentation/screens/local_drafts_screen.dart';
import 'support/fake_local_drafts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final entry in {
      'Poppins': 'assets/fonts/Poppins-Regular.ttf',
      'sans-serif': 'assets/fonts/Roboto-Regular.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(
        entry.key,
      )..addFont(rootBundle.load(entry.value))).load();
    }
  });
  for (final stage in ['guest', 'onboarding', 'ready']) {
    testWidgets('Real router gates local drafts by account stage: $stage', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      if (stage != 'guest') auth.current = const AuthSession(userId: 'A');
      final onboarding = FakeOnboarding(auth);
      if (stage == 'ready') onboarding.completed.add('A');
      final local = FakeLocalDrafts();
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
          localDraftRepositoryProvider.overrideWithValue(local),
        ],
      );
      addTearDown(() async {
        c.dispose();
        await auth.controller.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(container: c, child: const EntreHuellasApp()),
      );
      await tester.pumpAndSettle();
      c.read(routerProvider).go('/home/drafts');
      await tester.pumpAndSettle();
      expect(
        c.read(routerProvider).routeInformationProvider.value.uri.path,
        stage == 'guest'
            ? '/access'
            : stage == 'onboarding'
            ? '/onboarding'
            : '/home/drafts',
      );
      expect(
        find.byType(LocalDraftsScreen),
        stage == 'ready' ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  for (final small in [false, true]) {
    testWidgets('Draft list fits small=$small and opens one editor at a time', (
      tester,
    ) async {
      tester.view.physicalSize = small
          ? const Size(320, 350)
          : const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = small ? 2 : 1;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final capture = Platform.environment['CAPTURE_OFFLINE_DRAFTS'] == '1';
      final local = FakeLocalDrafts();
      await local.save(
        LocalReportDraft(
          owner: 'A',
          slot: 'community-search',
          id: 'id',
          frozen: true,
        ),
      );
      await local.save(
        LocalReportDraft(owner: 'B', slot: 'lost', id: 'private-B'),
      );
      var opens = 0;
      final pending = Completer<void>();
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
              child: LocalDraftsScreen(
                onOpen: (draft) async {
                  opens++;
                  await pending.future;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Borradores'), findsOneWidget);
      expect(find.text('Búsqueda de mascota'), findsOneWidget);
      expect(find.textContaining('Mascota perdida'), findsNothing);
      if (capture) {
        await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('capture')),
          );
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final directory = Directory('build/ui-preview/offline-drafts')
            ..createSync(recursive: true);
          File(
            '${directory.path}/list-${small ? 'small' : 'normal'}.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.ensureVisible(find.text('Retomar borrador'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retomar borrador'));
      await tester.pump();
      await tester.tap(find.text('Retomar borrador'));
      expect(opens, 1);
      pending.complete();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'Local save retry keeps its label, blocks duplicates, discard requires confirmation',
    (tester) async {
      final pending = Completer<bool>();
      var saves = 0, discards = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReportDraftStatus(
                onRetry: () {
                  saves++;
                  return pending.future;
                },
                onDiscard: () async {
                  discards++;
                  return true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Reintentar guardado local'));
      await tester.pump();
      expect(
        tester
            .widget<TextButton>(
              find.widgetWithText(TextButton, 'Reintentar guardado local'),
            )
            .onPressed,
        isNull,
      );
      expect(saves, 1);
      expect(find.text('Reintentar guardado local'), findsOneWidget);
      pending.complete(true);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descartar borrador'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(discards, 0);
      await tester.tap(find.text('Descartar borrador'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      expect(discards, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
