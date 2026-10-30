import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/failures/pet_failure.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/use_cases/archive_pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/use_cases/restore_pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/use_cases/delete_pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/use_cases/list_my_pets.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_lifecycle_view_model.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_list_view_model.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'access_test.dart' show FakeAccess;
import 'support/fake_password_recovery.dart';
import 'support/fake_profile.dart';
import 'support/fake_profile_photo.dart';
import 'support/fake_pets.dart';
import 'support/fake_pet_photos.dart';

Pet pet({String owner = 'one', DateTime? history, int active = 0}) => Pet(
  id: 'pet',
  ownerId: owner,
  version: 1,
  fields: const PetFields(name: 'Luna', species: PetSpecies.dog),
  caseHistoryAt: history,
  activeCaseCount: active,
  coverUri: Uri.parse('https://example.test/private-photo.jpg'),
);

void main() {
  test(
    'Archive/restore preserves metadata and cover, isolates lists and retries a lost response',
    () async {
      final original = pet(history: DateTime.utc(2026));
      final repo = FakePets()..pets['pet'] = original;
      repo.ambiguousLifecycle = true;
      await expectLater(
        ArchivePet(repo)('one', original),
        throwsA(isA<PetFailure>()),
      );
      final archived = await ArchivePet(repo)('one', original);
      expect(archived.version, 2);
      expect(archived.fields, same(original.fields));
      expect(archived.coverUri, original.coverUri);
      expect(archived.caseHistoryAt, original.caseHistoryAt);
      expect(await ListMyPets(repo)('one'), isEmpty);
      expect((await ListMyPets(repo)('one', archived: true)).single.id, 'pet');
      repo.ambiguousLifecycle = true;
      await expectLater(
        RestorePet(repo)('one', archived),
        throwsA(isA<PetFailure>()),
      );
      final restored = await RestorePet(repo)('one', archived);
      expect(restored.version, 3);
      expect(restored.isArchived, false);
      expect(await ListMyPets(repo)('one', archived: true), isEmpty);
      expect(
        (await ListMyPets(repo)('one')).single.caseHistoryAt,
        original.caseHistoryAt,
      );
    },
  );

  test(
    'Owner, active cases, permanent history and stale versions protect lifecycle operations',
    () async {
      final repo = FakePets()..pets['pet'] = pet();
      for (final operation in [ArchivePet(repo).call, RestorePet(repo).call]) {
        await expectLater(
          operation('two', pet()),
          throwsA(
            isA<PetFailure>().having(
              (e) => e.kind,
              'kind',
              PetFailureKind.forbidden,
            ),
          ),
        );
      }
      await expectLater(
        ArchivePet(repo)('one', pet(active: 1)),
        throwsA(
          isA<PetFailure>().having(
            (e) => e.kind,
            'kind',
            PetFailureKind.activeCase,
          ),
        ),
      );
      await expectLater(
        () => DeletePet(repo)('one', pet(history: DateTime.utc(2026))),
        throwsA(
          isA<PetFailure>().having(
            (e) => e.kind,
            'kind',
            PetFailureKind.caseHistory,
          ),
        ),
      );
      expect(repo.archives, 0);
      expect(repo.restores, 0);
      expect(repo.deletes, 0);
      await ArchivePet(repo)('one', pet());
      await RestorePet(repo)('one', repo.pets['pet']!);
      await expectLater(
        ArchivePet(repo)('one', pet()),
        throwsA(
          isA<PetFailure>().having(
            (e) => e.kind,
            'kind',
            PetFailureKind.conflict,
          ),
        ),
      );
    },
  );

  test(
    'ViewModel blocks duplicates, preserves failed retry and refreshes both lists',
    () async {
      final auth = FakeAuthRepository()
        ..current = const AuthSession(userId: 'one');
      final repo = FakePets()..pets['pet'] = pet();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          petRepositoryProvider.overrideWithValue(repo),
        ],
      );
      final provider = petLifecycleViewModelProvider('pet');
      final subs = [
        container.listen(provider, (_, _) {}),
        container.listen(petListViewModelProvider, (_, _) {}),
        container.listen(archivedPetListViewModelProvider, (_, _) {}),
      ];
      addTearDown(() async {
        for (final sub in subs) {
          sub.close();
        }
        container.dispose();
        await auth.controller.close();
      });
      await container.read(petSessionProvider.future);
      await container.read(petListViewModelProvider.future);
      await container.read(archivedPetListViewModelProvider.future);
      final model = container.read(provider.notifier);
      repo.fail = true;
      await model.change(pet());
      expect(container.read(provider).issue, PetFailureKind.unavailable);
      expect(container.read(provider).confirmed, false);
      repo.fail = false;
      repo.pending = Completer<void>();
      final work = model.change(pet());
      await model.change(pet());
      expect(repo.archives, 2);
      expect(container.read(provider).busy, true);
      repo.pending!.complete();
      await work;
      expect(container.read(provider).confirmed, true);
      expect(await container.read(petListViewModelProvider.future), isEmpty);
      expect(
        (await container.read(
          archivedPetListViewModelProvider.future,
        )).single.isArchived,
        true,
      );
    },
  );

  test(
    'Late completion from an old account cannot announce success for the new one',
    () async {
      final auth = FakeAuthRepository()
        ..current = const AuthSession(userId: 'one');
      final repo = FakePets()..pets['pet'] = pet();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          petRepositoryProvider.overrideWithValue(repo),
        ],
      );
      final provider = petLifecycleViewModelProvider('pet');
      final sub = container.listen(provider, (_, _) {});
      addTearDown(() async {
        sub.close();
        container.dispose();
        await auth.controller.close();
      });
      await container.read(petSessionProvider.future);
      final model = container.read(provider.notifier);
      repo.pending = Completer<void>();
      final work = model.change(pet());
      auth.current = const AuthSession(userId: 'two');
      auth.controller.add(auth.current);
      await container.pump();
      expect(container.read(provider).busy, false);
      repo.pending!.complete();
      await work;
      expect(container.read(provider).confirmed, false);
      expect(container.read(provider).issue, isNull);
    },
  );

  for (final small in [false, true]) {
    testWidgets(
      'Archive, cancel, fail/retry and restore through private lists; small=$small',
      (tester) async {
        if (const bool.fromEnvironment('CAPTURE_PETS')) {
          await tester.runAsync(() async {
            final configFile = File('.dart_tool/package_config.json').absolute;
            final config =
                jsonDecode(await configFile.readAsString())
                    as Map<String, dynamic>;
            final flutterPackage = (config['packages'] as List)
                .cast<Map<String, dynamic>>()
                .firstWhere((p) => p['name'] == 'flutter');
            final fontRoot = configFile.uri
                .resolve('${flutterPackage['rootUri']}/')
                .resolve('../../bin/cache/artifacts/material_fonts/');
            for (final entry in {
              'sans-serif': [
                'roboto-regular.ttf',
                'roboto-medium.ttf',
                'roboto-bold.ttf',
              ],
              'MaterialIcons': ['materialicons-regular.otf'],
            }.entries) {
              final loader = FontLoader(entry.key);
              for (final file in entry.value) {
                loader.addFont(
                  File.fromUri(
                    fontRoot.resolve(file),
                  ).readAsBytes().then(ByteData.sublistView),
                );
              }
              await loader.load();
            }
          });
        }
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = small ? 2 : 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final auth = FakeAuthRepository()
          ..current = const AuthSession(userId: 'one');
        final onboarding = FakeOnboarding(auth)..completed.add('one');
        final repo = FakePets()
          ..pets['pet'] = Pet(
            id: 'pet',
            ownerId: 'one',
            fields: pet().fields,
            version: 1,
          );
        final profiles = FakeProfile();
        final recovery = FakePasswordRecovery();
        final container = ProviderContainer(
          overrides: [
            startupStateProvider.overrideWithValue(
              const StartupState(StartupStatus.ready),
            ),
            authRepositoryProvider.overrideWithValue(auth),
            accessRepositoryProvider.overrideWithValue(FakeAccess()),
            onboardingRepositoryProvider.overrideWithValue(onboarding),
            passwordRecoveryRepositoryProvider.overrideWithValue(recovery),
            profileRepositoryProvider.overrideWithValue(profiles),
            profilePhotoRepositoryProvider.overrideWithValue(
              FakeProfilePhoto(profiles),
            ),
            petRepositoryProvider.overrideWithValue(repo),
            petPhotoRepositoryProvider.overrideWithValue(FakePetPhotos()),
          ],
        );
        addTearDown(() async {
          container.dispose();
          await auth.controller.close();
          await recovery.events.close();
        });
        final boundary = GlobalKey();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: RepaintBoundary(
              key: boundary,
              child: const EntreHuellasApp(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        container.read(routerProvider).go('/home/pets/pet');
        await tester.pumpAndSettle();
        Future<void> capture(String stage) async {
          if (!const bool.fromEnvironment('CAPTURE_PETS')) return;
          await tester.pump();
          await tester.runAsync(() async {
            final image =
                await (boundary.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final folder = Directory('build/ui-preview');
            await folder.create(recursive: true);
            await File(
              '${folder.path}/pets_archive_${stage}_${small ? 'small' : 'normal'}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        Future<void> tap(String text) async {
          await tester.ensureVisible(find.text(text));
          await tester.tap(find.text(text));
          await tester.pumpAndSettle();
        }

        await tester.ensureVisible(find.text('Archivar mascota'));
        await capture('action');
        await tap('Archivar mascota');
        await capture('confirmation');
        await tester.ensureVisible(find.text('Archivar'));
        await capture('confirmation_actions');
        await tap('Cancelar');
        expect(repo.archives, 0);
        await tap('Archivar mascota');
        repo.fail = true;
        await tap('Archivar');
        expect(
          find.text('No se pudo completar la acción. Puedes reintentar.'),
          findsOneWidget,
        );
        await capture('error');
        repo.fail = false;
        await tap('Archivar mascota');
        await tap('Archivar');
        expect(repo.pets['pet']!.isArchived, true);
        expect(find.text('Restaurar mascota'), findsOneWidget);
        await capture('archived_detail');
        container.read(routerProvider).go('/home');
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Mis mascotas'));
        await tester.pumpAndSettle();
        expect(find.text('Luna'), findsNothing);
        Color labelColor(String label) =>
            tester.widget<Text>(find.text(label)).style!.color!;
        final activeColor = labelColor('Activas');
        final archivedColor = labelColor('Archivadas');
        await tester.ensureVisible(find.text('Archivadas'));
        await tester.tap(find.text('Archivadas'));
        await tester.pump();
        expect(labelColor('Activas'), activeColor);
        expect(labelColor('Archivadas'), archivedColor);
        final indicator = find.byKey(
          const ValueKey('pet-list-active-indicator'),
        );
        final initialPosition = tester.getCenter(indicator);
        await tester.pump(const Duration(milliseconds: 160));
        expect(labelColor('Activas'), isNot(activeColor));
        expect(labelColor('Activas'), isNot(archivedColor));
        expect(labelColor('Archivadas'), isNot(activeColor));
        expect(labelColor('Archivadas'), isNot(archivedColor));
        expect(tester.getCenter(indicator), isNot(initialPosition));
        await capture('filter_transition');
        await tester.pumpAndSettle();
        expect(labelColor('Activas'), archivedColor);
        expect(labelColor('Archivadas'), activeColor);
        expect(find.text('Luna'), findsOneWidget);
        await capture('list');
        await tap('Luna');
        await tap('Restaurar mascota');
        expect(repo.pets['pet']!.isArchived, false);
        expect(find.text('Archivar mascota'), findsOneWidget);
        await capture('restored');
        await tester.pump(const Duration(seconds: 7));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Volver a mis mascotas'));
        await tester.pumpAndSettle();
        expect(find.text('No tienes mascotas archivadas'), findsOneWidget);
        await tap('Activas');
        expect(find.text('Luna'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
