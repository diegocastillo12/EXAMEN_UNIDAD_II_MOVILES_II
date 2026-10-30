import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/skeleton_form_fields.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/widgets/profile_editor.dart';
import 'app_test.dart' show FakeAuthRepository;
import 'support/fake_profile.dart';

void main() {
  testWidgets(
    'Profile awaits data with a static accessible skeleton, then shows real fields',
    (tester) async {
      final auth = FakeAuthRepository()
        ..current = const AuthSession(userId: 'one');
      final repo = FakeProfile()..pendingRead = Completer<void>();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await auth.controller.close();
      });
      tester.view.physicalSize = const Size(320, 350);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MediaQuery(
              data: MediaQueryData(
                size: Size(320, 350),
                disableAnimations: true,
                textScaler: TextScaler.linear(2),
              ),
              child: Scaffold(
                body: SingleChildScrollView(child: ProfileEditor()),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(SkeletonFormFields), findsOneWidget);
      expect(find.textContaining('Cargando'), findsNothing);
      expect(find.byType(TextField), findsNothing);
      repo.pendingRead!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(SkeletonFormFields), findsNothing);
      // Name, email and the optional private phone added in ADR-116.
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
