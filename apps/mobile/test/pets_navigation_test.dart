import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_select_field.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pet_skeleton.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pet_photo_gallery.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pet_size_selector.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/cover_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_dialog_transition.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pets_section.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_text_field.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'access_test.dart' show FakeAccess;
import 'support/fake_password_recovery.dart';
import 'support/fake_profile.dart';
import 'support/fake_profile_photo.dart';
import 'support/fake_pets.dart';
import 'support/fake_pet_photos.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/swipe_pet_card.dart';

void main() {
  for (final small in [false, true]) {
    testWidgets(
      'Register, consult, edit and re-open private pets; small=$small',
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
        tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
        addTearDown(tester.view.resetPadding);
        tester.platformDispatcher.textScaleFactorTestValue = small ? 2 : 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final auth = FakeAuthRepository()
          ..current = const AuthSession(userId: 'one');
        final onboarding = FakeOnboarding(auth)..completed.add('one');
        final recovery = FakePasswordRecovery();
        final profiles = FakeProfile();
        final pets = FakePets();
        final photos = FakePetPhotos();
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
            petRepositoryProvider.overrideWithValue(pets),
            petPhotoRepositoryProvider.overrideWithValue(photos),
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
        Future<void> capture(String name) async {
          if (!const bool.fromEnvironment('CAPTURE_PETS')) return;
          await tester.runAsync(
            () => precacheImage(
              const AssetImage('assets/branding/app_icon.png'),
              boundary.currentContext!,
            ),
          );
          await tester.pump();
          await tester.runAsync(() async {
            final raster =
                await (boundary.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary)
                    .toImage(pixelRatio: 2);
            final bytes = await raster.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final folder = Directory('build/ui-preview');
            await folder.create(recursive: true);
            await File(
              '${folder.path}/pets_${name}_${small ? 'small' : 'normal'}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            raster.dispose();
          });
        }

        await tester.pumpAndSettle();
        if (const bool.fromEnvironment('CAPTURE_PETS')) {
          pets.pendingList = Completer<void>();
        }
        await tester.tap(find.byTooltip('Mis mascotas'));
        if (const bool.fromEnvironment('CAPTURE_PETS')) {
          await tester.pump();
          for (var frame = 0; frame < 30; frame++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          expect(find.byType(PetSkeleton), findsOneWidget);
          await capture('loading');
          pets.pendingList!.complete();
          pets.pendingList = null;
        }
        await tester.pumpAndSettle();
        expect(find.text('Aún no tienes mascotas'), findsOneWidget);
        final emptyTitleOffset =
            tester.getTopLeft(find.text('Mis mascotas')) -
            tester.getTopLeft(find.byType(PetsSection));
        await capture('empty');
        await tester.ensureVisible(find.text('Registrar mascota'));
        final registerButton = find.ancestor(
          of: find.text('Registrar mascota'),
          matching: find.byWidgetPredicate((w) => w is FilledButton),
        );
        final origin = tester.getRect(registerButton);
        expect(
          origin.top,
          greaterThan(
            tester
                .getBottomLeft(
                  find.descendant(
                    of: find.byType(PetsSection),
                    matching: find.byIcon(Icons.pets_outlined),
                  ),
                )
                .dy,
          ),
        );
        await tester.tap(find.text('Registrar mascota'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        expect(
          tester
              .widget<OriginPageTransition>(find.byType(OriginPageTransition))
              .origin,
          origin,
        );
        await capture('register_origin_start');
        await tester.pump(const Duration(milliseconds: 160));
        await capture('register_origin_middle');
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Volver a mis mascotas'));
        await tester.pump();
        // Let the asynchronous exit guard dispatch pop before timing reverse.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 130));
        expect(find.byType(OriginPageTransition), findsOneWidget);
        await capture('register_origin_close');
        await tester.pump(const Duration(milliseconds: 90));
        await capture('register_origin_return');
        await tester.pumpAndSettle();
        expect(find.text('Aún no tienes mascotas'), findsOneWidget);
        await tester.ensureVisible(find.text('Registrar mascota'));
        await tester.tap(find.text('Registrar mascota'));
        await tester.pumpAndSettle();
        await capture('form');
        expect(
          tester.getTopLeft(find.byTooltip('Volver a mis mascotas')).dy,
          lessThan(60),
        );
        await tester.ensureVisible(
          find.byIcon(Icons.add_photo_alternate_outlined),
        );
        await Scrollable.ensureVisible(
          tester.element(find.byType(PetPhotoGallery)),
          alignment: .65,
        );
        await tester.pumpAndSettle();
        await capture('photo_selector');
        await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
        await tester.pumpAndSettle();
        expect(find.byTooltip('Quitar foto'), findsNothing);
        photos.selection = img.encodeJpg(img.Image(width: 24, height: 24));
        await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
        await tester.pumpAndSettle();
        expect(find.byTooltip('Quitar foto'), findsOneWidget);
        await Scrollable.ensureVisible(
          tester.element(find.byType(PetPhotoGallery)),
          alignment: .65,
        );
        await tester.pumpAndSettle();
        await capture('photo_pending');
        await tester.ensureVisible(find.byTooltip('Quitar foto'));
        await tester.tap(find.byTooltip('Quitar foto'));
        await tester.pumpAndSettle();
        expect(find.byTooltip('Quitar foto'), findsNothing);
        await tester.ensureVisible(find.text('Registrar mascota').last);
        await tester.tap(find.text('Registrar mascota').last);
        await tester.pumpAndSettle();
        expect(find.text('Completa los campos obligatorios.'), findsOneWidget);
        await capture('required_fields_error');
        await tester.ensureVisible(find.byType(TextField).first);
        await tester.enterText(find.byType(TextField).first, 'Luna');
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Volver a mis mascotas'));
        await tester.pumpAndSettle();
        expect(find.text('¿Salir sin guardar?'), findsOneWidget);
        await capture('register_discard');
        await tester.ensureVisible(find.text('Seguir editando'));
        await tester.pumpAndSettle();
        await capture('discard_actions');
        await tester.tap(find.text('Seguir editando'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextField>(find.byType(TextField).first)
              .controller!
              .text,
          'Luna',
        );
        await tester.ensureVisible(find.byType(AppSelectField<PetSpecies>));
        await tester.tap(find.byType(AppSelectField<PetSpecies>));
        await tester.pumpAndSettle();
        await capture('options');
        await tester.ensureVisible(find.text('Otra especie').last);
        await tester.tap(find.text('Otra especie').last);
        await tester.pumpAndSettle();
        await capture('species');
        final typeField = find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is AppTextField && w.label == 'Tipo de mascota',
          ),
          matching: find.byType(TextField),
        );
        await tester.ensureVisible(typeField);
        await tester.enterText(typeField, 'Conejo');
        final mediumChip = find.widgetWithText(ChoiceChip, 'Mediano');
        await Scrollable.ensureVisible(
          tester.element(mediumChip),
          alignment: .5,
        );
        await tester.tap(mediumChip);
        await tester.pumpAndSettle();
        final sizeSelector = find.byType(PetSizeSelector);
        await Scrollable.ensureVisible(
          tester.element(sizeSelector),
          alignment: .35,
        );
        await tester.pumpAndSettle();
        final sizeBounds = tester.getRect(sizeSelector);
        final sizeChips = find.descendant(
          of: sizeSelector,
          matching: find.byType(ChoiceChip),
        );
        final firstSize = tester.getRect(sizeChips.at(0));
        final middleSize = tester.getRect(sizeChips.at(1));
        final lastSize = tester.getRect(sizeChips.at(2));
        expect(firstSize.left, closeTo(sizeBounds.left, .01));
        expect(lastSize.right, closeTo(sizeBounds.right, .01));
        expect(firstSize.width, closeTo(middleSize.width, .01));
        expect(firstSize.width, closeTo(lastSize.width, .01));
        await capture('size_selected');
        if (const bool.fromEnvironment('CAPTURE_PETS')) {
          await tester.ensureVisible(find.byType(AppSelectField<PetSpecies>));
          await tester.tap(find.byType(AppSelectField<PetSpecies>));
          await tester.pumpAndSettle();
          await capture('selected_options');
          await tester.tap(find.byTooltip('Cerrar opciones'));
          await tester.pumpAndSettle();
        }
        final ageField = find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is AppTextField && w.label == 'Edad aproximada (meses)',
          ),
          matching: find.byType(TextField),
        );
        await tester.ensureVisible(ageField);
        await tester.enterText(ageField, '24');
        await tester.ensureVisible(find.byType(TextField).last);
        await tester.enterText(find.byType(TextField).last, 'Pelaje blanco');
        await tester.pumpAndSettle();
        await capture('traits_counter');
        await tester.ensureVisible(find.text('Registrar mascota').last);
        if (const bool.fromEnvironment('CAPTURE_PETS')) {
          pets.pending = Completer<void>();
          pets.pendingRead = Completer<void>();
        }
        await tester.tap(find.text('Registrar mascota').last);
        if (const bool.fromEnvironment('CAPTURE_PETS')) {
          await tester.pump(const Duration(milliseconds: 280));
          await capture('saving');
          pets.pending!.complete();
          pets.pending = null;
          for (var frame = 0; frame < 30; frame++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          expect(find.byType(PetSkeleton), findsOneWidget);
          await capture('detail_loading');
          pets.pendingRead!.complete();
          pets.pendingRead = null;
        }
        await tester.pumpAndSettle();
        expect(find.text('Ficha de mascota'), findsNothing);
        expect(find.text('Luna'), findsOneWidget);
        expect(pets.pets.length, 1);
        expect(pets.pets.values.single.fields.sex, PetSex.male);
        expect(pets.pets.values.single.fields.speciesDetail, 'Conejo');
        expect(pets.pets.values.single.fields.size, PetSize.medium);
        if (const bool.fromEnvironment('CAPTURE_PETS')) {
          await tester.pump(const Duration(seconds: 4));
        }
        await capture('detail');
        await tester.pump(const Duration(seconds: 7));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Editar mascota'));
        if (const bool.fromEnvironment('CAPTURE_PETS')) {
          pets.pendingRead = Completer<void>();
        }
        await tester.tap(find.text('Editar mascota'));
        if (const bool.fromEnvironment('CAPTURE_PETS')) {
          await tester.pump();
          for (var frame = 0; frame < 30; frame++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          await capture('editor_loading');
          pets.pendingRead!.complete();
          pets.pendingRead = null;
        }
        await tester.pumpAndSettle();
        if (const bool.fromEnvironment('CAPTURE_PETS')) {
          await tester.ensureVisible(
            find.byWidgetPredicate((w) => w is ChoiceChip && w.selected),
          );
          await tester.pumpAndSettle();
          await capture('edit_size');
        }
        await tester.ensureVisible(find.byType(TextField).last);
        await tester.enterText(
          find.byType(TextField).last,
          'Mancha blanca en el pecho',
        );
        await tester.pump();
        await tester.tap(find.byTooltip('Volver a mis mascotas'));
        await tester.pumpAndSettle();
        expect(find.text('¿Salir sin guardar?'), findsOneWidget);
        await capture('edit_discard');
        await tester.ensureVisible(find.text('Seguir editando'));
        await tester.pumpAndSettle();
        await capture('discard_actions');
        await tester.tap(find.text('Seguir editando'));
        await tester.pumpAndSettle();
        pets.fail = true;
        await tester.pump();
        await tester.ensureVisible(find.text('Guardar cambios'));
        await tester.tap(find.text('Guardar cambios'));
        await tester.pumpAndSettle();
        expect(
          find.text('No se pudo guardar la mascota. Tus cambios siguen aquí.'),
          findsOneWidget,
        );
        await capture('error');
        await tester.tap(find.byKey(const ValueKey('feedback-toast')));
        await tester.pumpAndSettle();
        pets.fail = false;
        await tester.ensureVisible(find.text('Guardar cambios'));
        await tester.tap(find.text('Guardar cambios'));
        await tester.pumpAndSettle();
        expect(find.text('Ficha de mascota'), findsNothing);
        expect(find.text('Luna'), findsOneWidget);
        expect(
          pets.pets.values.single.fields.traits,
          'Mancha blanca en el pecho',
        );
        await tester.pump(const Duration(seconds: 4));
        container.read(routerProvider).pop();
        await tester.pumpAndSettle();
        expect(find.text('Luna'), findsOneWidget);
        expect(
          tester.getTopLeft(find.text('Mis mascotas')) -
              tester.getTopLeft(find.byType(PetsSection)),
          emptyTitleOffset,
        );
        await capture('list');
        expect(find.text('Registrar mascota'), findsNothing);
        expect(find.text('Mascota'), findsNothing);
        final compactButton = find.byKey(const ValueKey('pet-add-compact'));
        await tester.ensureVisible(compactButton);
        final compactOrigin = tester.getRect(compactButton);
        expect(
          compactOrigin.right,
          tester.getRect(find.byType(PetsSection)).right,
        );
        await capture('add_compact');
        await tester.tap(compactButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        expect(
          tester
              .widget<OriginPageTransition>(find.byType(OriginPageTransition))
              .origin,
          compactOrigin,
        );
        expect(
          tester
              .widget<OriginPageTransition>(find.byType(OriginPageTransition))
              .source
              ?.radius,
          28,
        );
        await capture('compact_origin_start');
        await tester.pump(const Duration(milliseconds: 70));
        await capture('compact_origin_morph');
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Volver a mis mascotas'));
        await tester.pumpAndSettle();
        expect(pets.pets.length, 1);
        await tester.ensureVisible(find.text('Luna'));
        await tester.pumpAndSettle();
        final cardOrigin = tester.getRect(find.byType(SwipePetCard));
        await tester.tap(find.text('Luna'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        expect(
          tester
              .widget<OriginPageTransition>(find.byType(OriginPageTransition))
              .origin,
          cardOrigin,
        );
        await capture('detail_origin_start');
        await tester.pump(const Duration(milliseconds: 160));
        await capture('detail_origin_middle');
        await tester.pumpAndSettle();
        expect(find.text('Mancha blanca en el pecho'), findsOneWidget);
        container.read(routerProvider).pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 130));
        expect(find.byType(OriginPageTransition), findsOneWidget);
        await capture('detail_origin_close');
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(SwipePetCard));
        final swipe = await tester.startGesture(
          tester.getCenter(find.byType(SwipePetCard)),
        );
        await swipe.moveBy(const Offset(-60, 0));
        await tester.pump();
        await capture('swipe_partial');
        await swipe.moveBy(const Offset(-140, 0));
        await tester.pump();
        await capture('swipe');
        expect(find.text('¿Eliminar mascota?'), findsNothing);
        await swipe.up();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 220));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 16));
        await capture('delete_origin_start');
        await tester.pump(const Duration(milliseconds: 160));
        await capture('delete_origin_middle');
        await tester.pumpAndSettle();
        expect(find.text('¿Eliminar mascota?'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(OriginDialogTransition),
            matching: find.byType(StaggerReveal),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byType(OriginDialogTransition),
            matching: find.byType(CoverReveal),
          ),
          findsNothing,
        );
        expect(
          tester
              .widget<OriginDialogTransition>(
                find.byType(OriginDialogTransition),
              )
              .origin,
          tester.getRect(find.byType(SwipePetCard)),
        );
        expect(pets.deletes, 0);
        final cancelButton = find.ancestor(
          of: find.text('Cancelar'),
          matching: find.byType(OutlinedButton),
        );
        final deleteButton = find.ancestor(
          of: find.text('Eliminar mascota'),
          matching: find.byWidgetPredicate((w) => w is FilledButton),
        );
        expect(tester.getSize(cancelButton), tester.getSize(deleteButton));
        expect(
          tester.getBottomRight(deleteButton).dx,
          tester
              .getBottomRight(
                find
                    .ancestor(
                      of: find.text('Cancelar'),
                      matching: find.byType(LayoutBuilder),
                    )
                    .first,
              )
              .dx,
        );
        await capture('delete_confirmation');
        await tester.ensureVisible(
          find
              .ancestor(
                of: find.text('Cancelar'),
                matching: find.byType(LayoutBuilder),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await capture('delete_actions');
        await tester.ensureVisible(find.text('Cancelar'));
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(pets.deletes, 0);
        await tester.ensureVisible(find.byType(SwipePetCard));
        await tester.drag(find.byType(SwipePetCard), const Offset(-200, 0));
        await tester.pumpAndSettle();
        pets.fail = true;
        await tester.ensureVisible(find.text('Eliminar mascota'));
        await tester.tap(find.text('Eliminar mascota'));
        await tester.pumpAndSettle();
        expect(pets.pets.length, 1);
        expect(
          find.text('No se pudo eliminar la mascota. Desliza para reintentar.'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text(
              'No se pudo eliminar la mascota. Desliza para reintentar.',
            ),
            matching: find.byType(SwipePetCard),
          ),
          findsNothing,
        );
        await capture('delete_error_toast');
        await tester.tap(find.byKey(const ValueKey('feedback-toast')));
        await tester.pumpAndSettle();
        pets.fail = false;
        await tester.ensureVisible(find.byType(SwipePetCard));
        await tester.drag(find.byType(SwipePetCard), const Offset(-200, 0));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Eliminar mascota'));
        await tester.tap(find.text('Eliminar mascota'));
        await tester.pumpAndSettle();
        expect(pets.pets, isEmpty);
        expect(find.text('Aún no tienes mascotas'), findsOneWidget);
        auth.emit(null);
        await tester.pumpAndSettle();
        expect(
          container
              .read(routerProvider)
              .routeInformationProvider
              .value
              .uri
              .path,
          '/access',
        );
        expect(find.text('Luna'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
