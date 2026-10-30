import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/confirmation_toast.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/widgets/profile_photo_editor.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/widgets/profile_editor.dart';
import 'app_test.dart' show FakeAuthRepository;
import 'support/fake_profile.dart';
import 'support/fake_profile_photo.dart';

void main() {
  testWidgets(
    'Avatar chooses and retries without duplicate controls; failure toast expires and success follows acknowledgement',
    (tester) async {
      final repo = FakeProfile();
      final photos = FakeProfilePhoto(repo)
        ..selection = Uint8List.fromList([255, 216, 255, 0])
        ..fail = true;
      final auth = FakeAuthRepository()
        ..current = const AuthSession(userId: 'one');
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(repo),
          profilePhotoRepositoryProvider.overrideWithValue(photos),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await auth.controller.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [ProfilePhotoEditor(), ProfileEditor()],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cambiar foto'), findsNothing);
      expect(find.text('Añadir foto'), findsNothing);
      await tester.tap(find.bySemanticsLabel('Cambiar foto de perfil'));
      await tester.pumpAndSettle();
      const failure = 'No se pudo confirmar la foto. Tócala para reintentar.';
      expect(find.text(failure), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ProfilePhotoEditor),
          matching: find.text(failure),
        ),
        findsNothing,
      );
      expect(find.text('Foto actualizada'), findsNothing);
      expect(photos.choices, 1);
      expect(photos.uploads, 1);
      await tester.pump(const Duration(seconds: 7));
      await tester.pumpAndSettle();
      expect(find.text(failure), findsNothing);
      photos.fail = false;
      photos.pending = Completer<void>();
      await tester.tap(find.bySemanticsLabel('Reintentar foto de perfil'));
      await tester.pump();
      // An active operation cannot be sent a second time from the avatar.
      await tester.tap(
        find
            .descendant(
              of: find.byType(ProfilePhotoEditor),
              matching: find.byType(GestureDetector),
            )
            .first,
        warnIfMissed:
            false, // LoadingShimmer deliberately blocks pointer events.
      );
      await tester.pump();
      expect(photos.choices, 1);
      expect(photos.uploads, 2);
      expect(find.text('Foto actualizada'), findsNothing);
      photos.pending!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Foto actualizada'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsNothing);
      expect(find.byType(ConfirmationToastHost), findsNWidgets(2));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 4));
      expect(tester.takeException(), isNull);
    },
  );
}
