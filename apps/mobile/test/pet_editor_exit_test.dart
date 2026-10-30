import 'dart:async';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/screens/pet_editor_screen.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_editor_view_model.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_photos_view_model.dart';
import 'app_test.dart' show FakeAuthRepository;
import 'support/fake_pets.dart';
import 'support/fake_pet_photos.dart';

void main() {
  for (final edit in [false, true]) {
    for (final small in [false, true]) {
      testWidgets(
        'Exit guards actual edits, back and pending photos; edit=$edit small=$small',
        (tester) async {
          tester.view.physicalSize = small
              ? const Size(320, 350)
              : const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final auth = FakeAuthRepository()
            ..current = const AuthSession(userId: 'one');
          final pets = FakePets();
          pets.pets['pet'] = const Pet(
            id: 'pet',
            ownerId: 'one',
            fields: PetFields(name: 'Luna', species: PetSpecies.dog),
            version: 1,
          );
          final photos = FakePetPhotos()
            ..selection = img.encodeJpg(img.Image(width: 24, height: 24));
          final container = ProviderContainer(
            overrides: [
              authRepositoryProvider.overrideWithValue(auth),
              petRepositoryProvider.overrideWithValue(pets),
              petPhotoRepositoryProvider.overrideWithValue(photos),
            ],
          );
          final editorId = edit ? 'pet' : 'new';
          final router = GoRouter(
            initialLocation: '/home',
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => Scaffold(
                  body: TextButton(
                    onPressed: () => context.push('/home/editor'),
                    child: const Text('Abrir editor'),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'editor',
                    builder: (context, state) =>
                        PetEditorScreen(petId: editorId),
                  ),
                ],
              ),
            ],
          );
          addTearDown(() async {
            router.dispose();
            container.dispose();
            await auth.controller.close();
          });
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp.router(
                theme: AppTheme.light,
                routerConfig: router,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(small ? 2 : 1)),
                  child: child!,
                ),
              ),
            ),
          );
          Future<void> open() async {
            await tester.tap(find.text('Abrir editor'));
            await tester.pumpAndSettle();
          }

          Future<void> choose(String text) async {
            await tester.ensureVisible(find.text(text));
            await tester.tap(find.text(text));
            await tester.pumpAndSettle();
          }

          await open();
          // Loaded edit values and an empty registration leave without a prompt.
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.byType(PetEditorScreen), findsNothing);
          expect(find.text('¿Salir sin guardar?'), findsNothing);
          await open();
          final name = find.byType(TextField).first;
          await tester.ensureVisible(name);
          await tester.enterText(name, 'Cambio');
          await tester.pump();
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.text('¿Salir sin guardar?'), findsOneWidget);
          await choose('Seguir editando');
          expect(tester.widget<TextField>(name).controller!.text, 'Cambio');
          // Restoring the original value removes the guard.
          await tester.ensureVisible(name);
          await tester.enterText(name, edit ? 'Luna' : '');
          await tester.pump();
          await tester.tap(find.byTooltip('Volver a mis mascotas'));
          await tester.pumpAndSettle();
          expect(find.byType(PetEditorScreen), findsNothing);
          expect(find.text('¿Salir sin guardar?'), findsNothing);
          await open();
          final model = container.read(
            petEditorViewModelProvider(editorId).notifier,
          );
          model.edit(size: PetSize.large);
          await tester.pump();
          await tester.tap(find.byTooltip('Volver a mis mascotas'));
          await tester.pumpAndSettle();
          expect(find.text('¿Salir sin guardar?'), findsOneWidget);
          // Android back dismisses the confirmation and keeps the edited screen.
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.byType(PetEditorScreen), findsOneWidget);
          expect(
            container
                .read(petEditorViewModelProvider(editorId))
                .requireValue
                .size,
            PetSize.large,
          );
          await tester.tap(find.byTooltip('Volver a mis mascotas'));
          await tester.pumpAndSettle();
          await choose('Salir sin guardar');
          expect(find.byType(PetEditorScreen), findsNothing);
          expect(pets.pets['pet']!.fields.size, isNull);
          await open();
          final state = container
              .read(petEditorViewModelProvider(editorId))
              .requireValue;
          final photoProvider = petPhotosViewModelProvider(state.id);
          final subscription = container.listen(photoProvider, (_, _) {});
          addTearDown(subscription.close);
          await container.read(photoProvider.notifier).choose(edit);
          await tester.pumpAndSettle();
          expect(container.read(photoProvider).pending, hasLength(1));
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.text('¿Salir sin guardar?'), findsOneWidget);
          await choose('Seguir editando');
          expect(container.read(photoProvider).pending, hasLength(1));
          await tester.tap(find.byTooltip('Volver a mis mascotas'));
          await tester.pumpAndSettle();
          await choose('Salir sin guardar');
          expect(container.read(photoProvider).pending, isEmpty);
          expect(photos.attempts, isEmpty);
          if (edit) {
            photos.photos['confirmed'] = const PetPhoto(
              id: 'confirmed',
              petId: 'pet',
              ownerId: 'one',
              ready: true,
            );
            await container.read(photoProvider.notifier).initialize(true);
            await open();
            await tester.ensureVisible(find.byTooltip('Quitar foto'));
            await tester.tap(find.byTooltip('Quitar foto'));
            await tester.pumpAndSettle();
            expect(photos.removals, isEmpty);
            expect(container.read(photoProvider).pendingRemovals, {
              'confirmed',
            });
            final save = find.widgetWithText(FilledButton, 'Guardar cambios');
            expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
            await tester.binding.handlePopRoute();
            await tester.pumpAndSettle();
            expect(find.text('¿Salir sin guardar?'), findsOneWidget);
            await choose('Seguir editando');
            expect(container.read(photoProvider).pendingRemovals, {
              'confirmed',
            });
            await tester.tap(find.byTooltip('Volver a mis mascotas'));
            await tester.pumpAndSettle();
            await choose('Salir sin guardar');
            expect(container.read(photoProvider).pendingRemovals, isEmpty);
            expect(
              container.read(photoProvider).visiblePhotos.single.id,
              'confirmed',
            );
            expect(photos.photos.containsKey('confirmed'), isTrue);
            expect(photos.removals, isEmpty);
          }
          await open();
          final savingModel = container.read(
            petEditorViewModelProvider(editorId).notifier,
          );
          savingModel.edit(
            name: 'Otra mascota',
            species: PetSpecies.dog,
            size: PetSize.medium,
            age: '24',
            traits: 'Blanca',
          );
          pets.fail = true;
          pets.pending = Completer<void>();
          final saving = savingModel.save();
          await tester.pump();
          await tester.binding.handlePopRoute();
          await tester.tap(find.byTooltip('Volver a mis mascotas'));
          await tester.pump(const Duration(milliseconds: 100));
          expect(find.byType(PetEditorScreen), findsOneWidget);
          expect(find.text('¿Salir sin guardar?'), findsNothing);
          pets.pending!.complete();
          await saving;
          pets.pending = null;
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 7));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Volver a mis mascotas'));
          await tester.pumpAndSettle();
          expect(find.text('¿Salir sin guardar?'), findsOneWidget);
          await choose('Salir sin guardar');
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
