import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/cover_reveal.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/screens/pet_detail_screen.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/screens/pet_editor_screen.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pet_skeleton.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pet_photo_gallery.dart';
import 'app_test.dart' show FakeAuthRepository;
import 'support/fake_pets.dart';
import 'support/fake_pet_photos.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet_photo.dart';

void main() {
  for (final edit in [false, true]) {
    for (final small in [false, true]) {
      for (final hasPhoto in [false, true]) {
        testWidgets(
          'One stable skeleton awaits metadata and photos; edit=$edit, small=$small, photo=$hasPhoto',
          (tester) async {
            tester.view.physicalSize = small
                ? const Size(320, 350)
                : const Size(390, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final auth = FakeAuthRepository()
              ..current = const AuthSession(userId: 'one');
            final pets = FakePets()..pendingRead = Completer<void>();
            pets.pets['pet'] = const Pet(
              id: 'pet',
              ownerId: 'one',
              fields: PetFields(name: 'Luna', species: PetSpecies.dog),
              version: 1,
            );
            final photos = FakePetPhotos()..pendingList = Completer<void>();
            if (hasPhoto) {
              photos.photos['photo'] = const PetPhoto(
                id: 'photo',
                petId: 'pet',
                ownerId: 'one',
                ready: true,
              );
            }
            final container = ProviderContainer(
              overrides: [
                authRepositoryProvider.overrideWithValue(auth),
                petRepositoryProvider.overrideWithValue(pets),
                petPhotoRepositoryProvider.overrideWithValue(photos),
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
                  home: MediaQuery(
                    data: MediaQueryData(
                      textScaler: TextScaler.linear(small ? 2 : 1),
                    ),
                    child: edit
                        ? const PetEditorScreen(petId: 'pet')
                        : const PetDetailScreen(petId: 'pet'),
                  ),
                ),
              ),
            );
            await tester.pump();
            final skeleton = tester.element(find.byType(PetSkeleton));
            for (var i = 0; i < 20; i++) {
              await tester.pump(const Duration(milliseconds: 50));
              expect(tester.element(find.byType(PetSkeleton)), same(skeleton));
              expect(find.byType(CoverReveal), findsNothing);
            }
            expect(photos.lists, 1);
            pets.pendingRead!.complete();
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
            expect(tester.element(find.byType(PetSkeleton)), same(skeleton));
            expect(find.byType(PetPhotoGallery), findsNothing);
            photos.pendingList!.complete();
            await tester.pump();
            await tester.pump();
            expect(find.byType(PetSkeleton), findsNothing);
            expect(find.byType(PetPhotoGallery), findsOneWidget);
            expect(find.byType(CoverReveal), findsNothing);
            await tester.pumpAndSettle();
            expect(
              photos.lists,
              1,
              reason: 'Mounting the gallery must reuse the completed load.',
            );
            if (!edit) {
              expect(find.text('Ficha de mascota'), findsNothing);
              expect(
                find.byIcon(Icons.pets_outlined),
                hasPhoto ? findsNothing : findsOneWidget,
              );
              if (hasPhoto) {
                expect(
                  tester.getBottomLeft(find.byType(PetPhotoGallery)).dy,
                  lessThan(tester.getTopLeft(find.text('Luna')).dy),
                );
              }
            }
            if (!edit && hasPhoto) {
              final back = find.byTooltip('Volver a mis mascotas');
              final backRect = tester.getRect(back);
              final verticalScroll = find.byWidgetPredicate(
                (widget) =>
                    widget is SingleChildScrollView &&
                    widget.scrollDirection == Axis.vertical,
              );
              final scrollable = find
                  .descendant(
                    of: verticalScroll,
                    matching: find.byType(Scrollable),
                  )
                  .first;
              tester.state<ScrollableState>(scrollable).position.jumpTo(80);
              await tester.pump();
              final galleryRect = tester.getRect(find.byType(PetPhotoGallery));
              expect(tester.getRect(back), backRect);
              expect(galleryRect.top, lessThan(backRect.top));
              expect(galleryRect.bottom, greaterThan(backRect.bottom));
              expect(
                tester.getRect(verticalScroll).top,
                lessThan(backRect.top),
              );
            }
            expect(pets.reads, 1);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
