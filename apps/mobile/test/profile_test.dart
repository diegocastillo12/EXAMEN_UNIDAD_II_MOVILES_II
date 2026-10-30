import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/domain/entities/account_profile.dart';
import 'package:flutter_application_entrehuellas/features/profile/domain/failures/profile_failure.dart';
import 'package:flutter_application_entrehuellas/features/profile/domain/use_cases/update_profile.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/view_models/profile_view_model.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/widgets/profile_editor.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'app_test.dart' show FakeAuthRepository;
import 'support/fake_profile.dart';
import 'alert_preferences_test.dart' show loadFonts;

void main() {
  late FakeProfile repo;
  late FakeAuthRepository auth;
  late ProviderContainer container;
  setUp(() {
    repo = FakeProfile();
    auth = FakeAuthRepository()..current = const AuthSession(userId: 'one');
    container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(repo),
        authRepositoryProvider.overrideWithValue(auth),
      ],
    );
    final sub = container.listen(profileViewModelProvider, (_, _) {});
    addTearDown(sub.close);
  });
  tearDown(() async {
    container.dispose();
    await auth.controller.close();
  });

  test(
    'Update validates code points, trims and clears optional values before persistence',
    () async {
      final update = UpdateProfile(repo);
      await expectLater(
        update('one', displayName: 'x' * 121, city: '', citySelected: true),
        throwsA(
          isA<ProfileFailure>().having(
            (e) => e.kind,
            'kind',
            ProfileFailureKind.invalidName,
          ),
        ),
      );
      await expectLater(
        update('one', displayName: '', city: 'x' * 121, citySelected: true),
        throwsA(
          isA<ProfileFailure>().having(
            (e) => e.kind,
            'kind',
            ProfileFailureKind.invalidCity,
          ),
        ),
      );
      expect(repo.updates, 0);
      final unicode = await update(
        'one',
        displayName: '🐾' * 120,
        city: ' Lima ',
        citySelected: true,
      );
      expect(unicode.city, 'Lima');
      expect(unicode.displayName!.runes.length, 120);
      final clear = await update(
        'one',
        displayName: ' ',
        city: '',
        citySelected: true,
      );
      expect(clear.displayName, isNull);
      expect(clear.city, isNull);
    },
  );

  test(
    'Phone normalization, validation, removal and profile-only edits',
    () async {
      final update = UpdateProfile(repo);
      final saved = await update(
        'one',
        displayName: 'Ana',
        city: '',
        citySelected: true,
        contactPhone: ' +51 (900) 000-000 ',
      );
      expect(saved.contactPhone, '+51900000000');
      for (final phone in [
        '900000000',
        '+012345678',
        '+123',
        '+1234567890123456',
        '+51abc900000000',
      ]) {
        await expectLater(
          update(
            'one',
            displayName: 'Ana',
            city: '',
            citySelected: true,
            contactPhone: phone,
          ),
          throwsA(
            isA<ProfileFailure>().having(
              (e) => e.kind,
              'kind',
              ProfileFailureKind.invalidPhone,
            ),
          ),
        );
      }
      expect(repo.updates, 1);
      await container.read(profileViewModelProvider.future);
      final model = container.read(profileViewModelProvider.notifier);
      model.edit(contactPhone: '+51 911 111 111');
      model.selectCity('Lima');
      model.applyAvatar(const AccountProfile(userId: 'one'));
      expect(
        container.read(profileViewModelProvider).requireValue.contactPhone,
        '+51 911 111 111',
      );
      repo.failUpdate = true;
      await model.save();
      expect(
        container.read(profileViewModelProvider).requireValue.contactPhone,
        '+51 911 111 111',
      );
      repo.failUpdate = false;
      await model.save();
      container.invalidate(profileViewModelProvider);
      expect(
        (await container.read(profileViewModelProvider.future)).contactPhone,
        '+51911111111',
      );
      model.edit(contactPhone: 'invalid');
      await model.save();
      model.selectCity('Cusco');
      expect(
        container.read(profileViewModelProvider).requireValue.issue,
        ProfileFailureKind.invalidPhone,
      );
      model.discard();
      expect(
        container.read(profileViewModelProvider).requireValue.contactPhone,
        '+51911111111',
      );
      model.edit(contactPhone: '');
      await model.save();
      expect(repo.profiles['one']!.contactPhone, isNull);
    },
  );

  test(
    'Save only confirms acknowledgement, blocks duplicates and preserves draft on failure',
    () async {
      await container.read(profileViewModelProvider.future);
      final model = container.read(profileViewModelProvider.notifier);
      model.edit(displayName: ' Ana María ', city: 'Cusco');
      model.selectCity('Cusco');
      repo.pendingUpdate = Completer<void>();
      repo.failUpdate = true;
      final saving = model.save();
      await model.save();
      model.edit(city: 'Ignored');
      expect(repo.updates, 1);
      expect(
        container.read(profileViewModelProvider).requireValue.isBusy,
        true,
      );
      expect(
        container.read(profileViewModelProvider).requireValue.saved,
        false,
      );
      repo.pendingUpdate!.complete();
      await saving;
      final failed = container.read(profileViewModelProvider).requireValue;
      expect(failed.city, 'Cusco');
      expect(failed.displayName, ' Ana María ');
      expect(failed.issue, ProfileFailureKind.unavailable);
      repo.failUpdate = false;
      await model.save();
      expect(container.read(profileViewModelProvider).requireValue.saved, true);
      expect(
        container.read(profileViewModelProvider).requireValue.displayName,
        'Ana María',
      );
      container.invalidate(profileViewModelProvider);
      expect(
        (await container.read(profileViewModelProvider.future)).city,
        'Cusco',
      );
    },
  );

  test(
    'Validation errors recover on edit and discard restores persisted fields',
    () async {
      await container.read(profileViewModelProvider.future);
      final model = container.read(profileViewModelProvider.notifier);
      model.edit(displayName: 'x' * 121);
      await model.save();
      expect(repo.updates, 0);
      expect(
        container.read(profileViewModelProvider).requireValue.issue,
        ProfileFailureKind.invalidName,
      );
      model.edit(city: 'Tacna');
      expect(
        container.read(profileViewModelProvider).requireValue.issue,
        ProfileFailureKind.invalidName,
      );
      model.edit(displayName: 'Valid');
      expect(
        container.read(profileViewModelProvider).requireValue.issue,
        isNull,
      );
      model.discard();
      expect(
        container.read(profileViewModelProvider).requireValue.displayName,
        'Ana',
      );
      expect(
        container.read(profileViewModelProvider).requireValue.isDirty,
        false,
      );
    },
  );

  test(
    'Read failure can retry; stream error recovers even for the same identity',
    () async {
      repo.failRead = true;
      await expectLater(
        container.read(profileViewModelProvider.future),
        throwsA(isA<ProfileFailure>()),
      );
      repo.failRead = false;
      container.read(profileViewModelProvider.notifier).retry();
      expect(
        (await container.read(profileViewModelProvider.future)).profile.userId,
        'one',
      );
      auth.controller.addError(StateError('private token'));
      await Future<void>.delayed(Duration.zero);
      expect(container.read(profileViewModelProvider).hasError, true);
      auth.emit(const AuthSession(userId: 'one'));
      await Future<void>.delayed(Duration.zero);
      expect(
        (await container.read(profileViewModelProvider.future)).profile.userId,
        'one',
      );
    },
  );

  test(
    'Late save from previous account cannot replace the new account profile',
    () async {
      repo.profiles['two'] = const AccountProfile(
        userId: 'two',
        displayName: 'Bea',
      );
      await container.read(profileViewModelProvider.future);
      final model = container.read(profileViewModelProvider.notifier);
      model.edit(displayName: 'Old account');
      repo.pendingUpdate = Completer<void>();
      final saving = model.save();
      auth.emit(const AuthSession(userId: 'two'));
      await Future<void>.delayed(Duration.zero);
      expect(
        (await container.read(profileViewModelProvider.future)).profile.userId,
        'two',
      );
      repo.pendingUpdate!.complete();
      await saving;
      expect(
        container.read(profileViewModelProvider).requireValue.displayName,
        'Bea',
      );
    },
  );

  test('Disposal during save does not write to a disposed notifier', () async {
    await container.read(profileViewModelProvider.future);
    final model = container.read(profileViewModelProvider.notifier);
    model.edit(city: 'Tacna');
    repo.pendingUpdate = Completer<void>();
    final saving = model.save();
    container.dispose();
    repo.pendingUpdate!.complete();
    await saving;
  });

  for (final small in [false, true]) {
    testWidgets(
      'Profile fields persist through save error and remain reachable; small=$small',
      (tester) async {
        await tester.runAsync(() async {
          await loadFonts();
          await const SvgAssetLoader(
            'packages/circle_flags/assets/svg/pe.svg',
          ).loadBytes(null);
        });
        await tester.runAsync(
          () => container.read(profileViewModelProvider.future),
        );
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final capture = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: capture,
            child: UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                theme: AppTheme.light,
                home: MediaQuery(
                  data: MediaQueryData(
                    textScaler: TextScaler.linear(small ? 2 : 1),
                  ),
                  child: const Scaffold(
                    body: SingleChildScrollView(
                      padding: EdgeInsets.all(24),
                      child: ProfileEditor(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsNWidgets(3));
        expect(
          tester.widget<SelectableText>(find.byType(SelectableText)).data,
          'ana@example.invalid',
        );
        await tester.enterText(find.byType(TextField).first, 'María');
        await tester.pump();
        final phone = find.byType(TextField).at(2);
        await tester.ensureVisible(phone);
        await tester.enterText(phone, '900 000 000');
        await tester.pump();
        repo.failUpdate = true;
        await tester.ensureVisible(find.text('Guardar cambios'));
        await tester.tap(find.text('Guardar cambios'));
        await tester.pumpAndSettle();
        expect(
          container.read(profileViewModelProvider).requireValue.displayName,
          'María',
        );
        expect(find.textContaining('Conservamos tus cambios'), findsOneWidget);
        repo.failUpdate = false;
        await tester.ensureVisible(find.text('Guardar cambios'));
        await tester.tap(find.text('Guardar cambios'));
        await tester.pumpAndSettle();
        expect(find.text('Cambios guardados'), findsOneWidget);
        expect(repo.profiles['one']!.contactPhone, '+51900000000');
        await tester.pump(const Duration(seconds: 7));
        await tester.pumpAndSettle();
        expect(find.text('Cambios guardados'), findsNothing);
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.ensureVisible(find.text('Celular de contacto (opcional)'));
        await tester.pumpAndSettle();
        if (Platform.environment['CAPTURE_PROFILE_CONTACT'] == '1') {
          await tester.runAsync(() async {
            final image =
                await (capture.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final folder = Directory('build/ui-preview/profile-contact')
              ..createSync(recursive: true);
            await File(
              '${folder.path}/${small ? 'small' : 'normal'}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
