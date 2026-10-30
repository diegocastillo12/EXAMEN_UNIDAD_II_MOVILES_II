import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import '../test/support/fake_password_recovery.dart';
import '../test/support/fake_profile.dart';
import '../test/support/fake_profile_photo.dart';
import '../test/support/fake_pets.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/view_models/profile_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/view_models/password_recovery_view_model.dart';

import '../test/access_test.dart' show FakeAccess;
import '../test/registration_test.dart' show FakeRegistration;
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/registration_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/view_models/registration_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/failures/access_failure.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/view_models/login_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/state/login_view_state.dart';
// Visual QA harness, invoked explicitly with flutter test. No golden baselines.
import 'dart:convert';
import 'package:flutter_application_entrehuellas/features/profile/presentation/view_models/profile_photo_view_model.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import '../test/app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';

void main() {
  testWidgets('Render login and onboarding for visual inspection', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => Directory.systemTemp.path,
        );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    await tester.runAsync(() async {
      // Widget tests normally use Ahem. Load real SDK fonts for visual QA.
      final configFile = File('.dart_tool/package_config.json').absolute;
      final config =
          jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
      final flutterPackage = (config['packages'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((package) => package['name'] == 'flutter');
      final packageRoot = configFile.uri.resolve(
        '${flutterPackage['rootUri']}/',
      );
      final fontRoot = packageRoot.resolve(
        '../../bin/cache/artifacts/material_fonts/',
      );
      for (final entry in {
        'sans-serif': [
          'roboto-regular.ttf',
          'roboto-medium.ttf',
          'roboto-bold.ttf',
        ],
        'MaterialIcons': ['materialicons-regular.otf'],
      }.entries) {
        final loader = FontLoader(entry.key);
        for (final fileName in entry.value) {
          loader.addFont(
            File.fromUri(
              fontRoot.resolve(fileName),
            ).readAsBytes().then(ByteData.sublistView),
          );
        }
        await loader.load();
      }
    });
    final auth = FakeAuthRepository();
    final recovery = FakePasswordRecovery()..onEnd = () => auth.emit(null);
    addTearDown(recovery.events.close);
    final onboarding = FakeOnboarding(auth);
    addTearDown(auth.controller.close);
    final profile = FakeProfile();
    final profilePhotos = FakeProfilePhoto(profile);
    final container = ProviderContainer(
      overrides: [
        petRepositoryProvider.overrideWithValue(FakePets()),
        profileRepositoryProvider.overrideWithValue(profile),
        profilePhotoRepositoryProvider.overrideWithValue(profilePhotos),
        startupStateProvider.overrideWithValue(
          const StartupState(StartupStatus.ready),
        ),
        passwordRecoveryRepositoryProvider.overrideWithValue(recovery),
        authRepositoryProvider.overrideWithValue(auth),
        onboardingRepositoryProvider.overrideWithValue(onboarding),
        accessRepositoryProvider.overrideWithValue(
          FakeAccess()
            ..failure = const AccessFailure(AccessFailureKind.rejected),
        ),
        registrationRepositoryProvider.overrideWithValue(FakeRegistration()),
      ],
    );
    addTearDown(container.dispose);
    final previewKey = GlobalKey();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(key: previewKey, child: const EntreHuellasApp()),
      ),
    );
    await tester.runAsync(() async {
      final context = tester.element(find.byType(EntreHuellasApp));
      await precacheImage(
        const AssetImage('assets/illustrations/community_pets.png'),
        context,
      );
      await precacheImage(
        const AssetImage('assets/illustrations/dog_with_envelope.png'),
        context,
      );
      await precacheImage(
        const AssetImage('assets/branding/app_icon.png'),
        context,
      );
      for (final asset in [
        'dog_waving.png',
        'dog_with_map.png',
        'dog_and_cat.png',
      ]) {
        await precacheImage(AssetImage('assets/onboarding/$asset'), context);
      }
      await precacheImage(
        const AssetImage('assets/branding/google_g.png'),
        context,
      );
    });
    Future<void> capture(String name) async {
      await tester.runAsync(() async {
        final boundary =
            previewKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final rendered = await boundary.toImage(pixelRatio: 2);
        try {
          final pixels = await rendered.toByteData(
            format: ui.ImageByteFormat.png,
          );
          final directory = Directory('build/ui-preview');
          await directory.create(recursive: true);
          await File(
            '${directory.path}/$name.png',
          ).writeAsBytes(pixels!.buffer.asUint8List());
        } finally {
          rendered.dispose();
        }
      });
    }

    await tester.pump();
    await capture('startup_icon');
    await tester.pump(const Duration(milliseconds: 550));
    await capture('startup_brand_reveal');
    await tester.pump(const Duration(milliseconds: 440));
    await capture('startup_brand');
    await tester.pump(const Duration(milliseconds: 111));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump(const Duration(milliseconds: 350));
    await capture('access_startup_reveal');
    await tester.pumpAndSettle();
    await capture('access');
    await container
        .read(loginViewModelProvider.notifier)
        .password('preview@example.com', 'fake-password');
    await tester.pumpAndSettle();
    await capture('access_error');
    await tester.ensureVisible(find.widgetWithText(TextButton, 'Crear cuenta'));
    await tester.tap(find.widgetWithText(TextButton, 'Crear cuenta'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    await capture('register_origin_open');
    await tester.pump(const Duration(milliseconds: 340));
    await capture('register_reveal');
    await tester.pumpAndSettle();
    await capture('register');
    await container
        .read(registrationViewModelProvider.notifier)
        .submit('Ana', 'preview@example.com', 'fake-password', 'fake-password');
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    await capture('register_confirmation_cover');
    await tester.pump(const Duration(milliseconds: 160));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 340));
    await tester.pump(const Duration(milliseconds: 250));
    await capture('register_confirmation_reveal');
    await tester.pumpAndSettle();
    await capture('register_confirmation');
    tester.view.physicalSize = const Size(320, 350);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('email-code')));
    await tester.pumpAndSettle();
    await capture('register_confirmation_code_small');
    await tester.ensureVisible(find.textContaining('Reenviar código'));
    await tester.pumpAndSettle();
    await capture('register_confirmation_small');
    expect(tester.takeException(), isNull);
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    container.read(routerProvider).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 130));
    await capture('register_origin_close');
    await tester.pumpAndSettle();
    container
        .read(loginViewModelProvider.notifier)
        .fieldEdited(LoginField.email);
    await tester.pumpAndSettle();
    final pendingCheck = Completer<bool>();
    await tester.ensureVisible(find.text('¿Olvidaste tu contraseña?'));
    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await capture('recover_reveal');
    await tester.pumpAndSettle();
    await capture('recover_password');
    tester.view.physicalSize = const Size(320, 350);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enviar código'));
    await tester.pumpAndSettle();
    await capture('recover_password_small');
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(390, 844);
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('recovery-email')),
      'preview@example.com',
    );
    recovery.pending = Completer<void>();
    final send = container
        .read(passwordRecoveryViewModelProvider.notifier)
        .request('preview@example.com');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 350));
    await capture('recover_password_loading');
    recovery.pending!.complete();
    await send;
    recovery.pending = null;
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    await capture('recover_confirmation_cover');
    await tester.pump(const Duration(milliseconds: 160));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 340));
    await tester.pump(const Duration(milliseconds: 250));
    await capture('recover_confirmation_reveal');
    await tester.pumpAndSettle();
    await capture('recover_confirmation');
    auth.emit(const AuthSession(userId: 'preview-user'));
    await container
        .read(passwordRecoveryViewModelProvider.notifier)
        .verify('012345');
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    await capture('reset_password_cover');
    await tester.pumpAndSettle();
    await capture('reset_password');
    tester.view.physicalSize = const Size(320, 350);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Guardar contraseña'));
    await tester.pumpAndSettle();
    await capture('reset_password_small');
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(390, 844);
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('recovery-password')),
      'new-password',
    );
    await tester.enterText(
      find.byKey(const ValueKey('recovery-confirmation')),
      'new-password',
    );
    recovery.pending = Completer<void>();
    final save = container
        .read(passwordRecoveryViewModelProvider.notifier)
        .reset('new-password', 'new-password');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 350));
    await capture('reset_password_loading');
    recovery.pending!.complete();
    await save;
    recovery.pending = null;
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    await capture('reset_password_success_cover');
    await tester.pump(const Duration(milliseconds: 160));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 590));
    await tester.pump(const Duration(milliseconds: 350));
    await capture('reset_password_success_reveal');
    await tester.pumpAndSettle();
    await capture('reset_password_success');
    await tester.tap(find.text('Volver a iniciar sesión'));
    await tester.pumpAndSettle();
    onboarding.pendingRead = pendingCheck;
    auth.emit(const AuthSession(userId: 'preview-user'));
    await tester.pumpAndSettle();
    await capture('entry_check');
    pendingCheck.complete(false);
    onboarding.pendingRead = null;
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));
    await capture('onboarding_reveal');
    await tester.pumpAndSettle();
    await capture('onboarding_1');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await capture('onboarding_2');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await capture('onboarding_3');
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();
    await capture('home');
    final reunion = find.image(
      const AssetImage('assets/illustrations/reunion.png'),
    );
    await tester.ensureVisible(reunion);
    await tester.pumpAndSettle();
    await capture('home_reunion');
    Scrollable.of(tester.element(reunion)).position.jumpTo(0);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Explorar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    await capture('home_navigation_slide');
    await tester.pumpAndSettle();
    await capture('home_explore');
    await tester.tap(find.byTooltip('Inicio'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reportar'));
    await tester.pumpAndSettle();
    await capture('home_report');
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    profile.pendingRead = Completer<void>();
    container.invalidate(profileViewModelProvider);
    await tester.tap(find.byTooltip('Abrir perfil'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await capture('profile_origin_start');
    await tester.pump(const Duration(milliseconds: 160));
    await capture('profile_origin_middle');
    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await capture('profile_loading');
    profile.pendingRead!.complete();
    await tester.pumpAndSettle();
    await capture('profile');
    profilePhotos.selection = Uint8List.fromList([255, 216, 255, 0]);
    profilePhotos.fail = true;
    await tester.tap(find.bySemanticsLabel('Cambiar foto de perfil'));
    await tester.pumpAndSettle();
    await capture('profile_photo_error');
    container.read(profilePhotoViewModelProvider.notifier).discard();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Ana María');
    await tester.pump();
    profile.pendingUpdate = Completer<void>();
    await tester.ensureVisible(find.text('Guardar cambios'));
    await tester.tap(find.text('Guardar cambios'));
    await tester.pump(const Duration(milliseconds: 280));
    await capture('profile_saving');
    profile.failUpdate = true;
    profile.pendingUpdate!.complete();
    await tester.pumpAndSettle();
    await capture('profile_error');
    profile.failUpdate = false;
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();
    await capture('profile_saved');
    profile.failRead = true;
    container.read(profileViewModelProvider.notifier).retry();
    await tester.pumpAndSettle();
    await capture('profile_load_error');
    profile.failRead = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cerrar perfil'));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(320, 350);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpAndSettle();
    await capture('home_small');
    await tester.tap(find.byTooltip('Abrir perfil'));
    await tester.pumpAndSettle();
    await capture('profile_small');
    await tester.ensureVisible(find.text('Nombre'));
    await tester.pumpAndSettle();
    await capture('profile_fields_small');
    await tester.ensureVisible(find.text('Guardar cambios'));
    await tester.pumpAndSettle();
    await capture('profile_actions_small');
    container.read(profileViewModelProvider.notifier).edit(city: 'Cusco');
    await container.read(profileViewModelProvider.notifier).save();
    await tester.pumpAndSettle();
    await capture('profile_toast_small');
    await tester.pump(const Duration(seconds: 4));
    await tester.ensureVisible(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    await capture('home_profile_small');
    expect(tester.takeException(), isNull);
  });
}
