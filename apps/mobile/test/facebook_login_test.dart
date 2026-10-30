import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/social_provider.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/failures/access_failure.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/repositories/access_repository.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/screens/access_screen.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'alert_preferences_test.dart' show loadFonts;

class PendingSocialAccess implements AccessRepository {
  final requests = <SocialProvider>[];
  Completer<void> request = Completer<void>();

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signInWithProvider(SocialProvider provider) {
    requests.add(provider);
    return request.future;
  }
}

void main() {
  for (final compact in [false, true]) {
    testWidgets('Facebook login, retry and layout compact=$compact', (
      tester,
    ) async {
      tester.view.physicalSize = compact
          ? const Size(320, 350)
          : const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(loadFonts);
      final repository = PendingSocialAccess();
      final boundary = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [accessRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(compact ? 2 : 1),
                disableAnimations: compact,
              ),
              child: RepaintBoundary(key: boundary, child: child!),
            ),
            home: const AccessScreen(),
          ),
        ),
      );
      await tester.runAsync(() async {
        for (final asset in [
          'assets/branding/app_icon.png',
          'assets/branding/google_g.png',
        ]) {
          await precacheImage(AssetImage(asset), boundary.currentContext!);
        }
      });
      await tester.pumpAndSettle();
      final facebook = find.text('Continuar con Facebook');
      await tester.ensureVisible(facebook);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // Local review artifact; no production data or live OAuth.
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final snapshot = await render.toImage();
        final bytes = await snapshot.toByteData(format: ui.ImageByteFormat.png);
        final file = File(
          'build/ui-preview/facebook/login-${compact ? 'small' : 'normal'}.png',
        );
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        snapshot.dispose();
      });
      await tester.tap(facebook);
      await tester.pump();
      await tester.tap(facebook, warnIfMissed: false);
      await tester.pump();
      expect(repository.requests, [SocialProvider.facebook]);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Continuar con Google'),
            )
            .onPressed,
        isNull,
      );
      repository.request.completeError(
        const AccessFailure(AccessFailureKind.unavailable),
      );
      await tester.pumpAndSettle();
      expect(find.text('Acceso no disponible. Reintenta.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 7));
      await tester.pumpAndSettle();
      repository.request = Completer<void>();
      await tester.ensureVisible(facebook);
      await tester.pumpAndSettle();
      await tester.tap(facebook);
      await tester.pump();
      expect(repository.requests, [
        SocialProvider.facebook,
        SocialProvider.facebook,
      ]);
      repository.request.complete();
      await tester.pumpAndSettle();
      expect(find.byType(AccessScreen), findsOneWidget);
      expect(find.text('Sesión iniciada.'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
