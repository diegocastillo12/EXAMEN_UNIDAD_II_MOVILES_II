import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_text_field.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_select_field.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/shake_field.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/unicode_length_limiting_formatter.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet_photo.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/screens/pet_editor_screen.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_editor_view_model.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pet_photo_gallery.dart';
import 'app_test.dart' show FakeAuthRepository;
import 'support/fake_pets.dart';
import 'support/fake_pet_photos.dart';

void main() {
  test(
    'Unicode limiter preserves emoji, cursor and active IME composition',
    () {
      const formatter = UnicodeLengthLimitingFormatter(200);
      final limited = formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(
          text: '🐾' * 201,
          selection: const TextSelection.collapsed(offset: 402),
        ),
      );
      expect(limited.text, '🐾' * 200);
      expect(limited.selection.extentOffset, 400);
      const composing = TextEditingValue(
        text: 'x',
        composing: TextRange(start: 0, end: 1),
      );
      expect(
        const UnicodeLengthLimitingFormatter(
          0,
        ).formatEditUpdate(TextEditingValue.empty, composing),
        composing,
      );
    },
  );
  for (final small in [false, true]) {
    testWidgets(
      'Required fields use danger/shake and toast; counter and photos recover; small=$small',
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
        final photos = _FailingGallery();
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
                  size: small ? const Size(320, 350) : const Size(390, 844),
                  textScaler: TextScaler.linear(small ? 2 : 1),
                  disableAnimations: small,
                ),
                child: const PetEditorScreen(petId: 'new'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.widget<PetPhotoGallery>(find.byType(PetPhotoGallery)).tileSize,
          160,
        );
        expect(find.text('Seleccionar'), findsOneWidget);
        expect(find.text('Macho'), findsOneWidget);
        expect(find.text('0/200'), findsOneWidget);
        await tester.ensureVisible(find.text('Registrar mascota').last);
        await tester.tap(find.text('Registrar mascota').last);
        await tester.pumpAndSettle();
        expect(find.text('Completa los campos obligatorios.'), findsOneWidget);
        expect(pets.creates, 0);
        expect(
          find.byWidgetPredicate((w) => w is ShakeField && w.hasError),
          findsNWidgets(5),
        );
        for (final field in tester.widgetList<InputDecorator>(
          find.byType(InputDecorator),
        )) {
          expect(field.decoration.errorText, isNull);
        }
        final previous = container
            .read(petEditorViewModelProvider('new'))
            .requireValue
            .errorId;
        await tester.tap(find.byKey(const ValueKey('feedback-toast')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Registrar mascota').last);
        await tester.pumpAndSettle();
        expect(
          container
              .read(petEditorViewModelProvider('new'))
              .requireValue
              .errorId,
          greaterThan(previous),
        );
        await tester.tap(find.byKey(const ValueKey('feedback-toast')));
        await tester.pumpAndSettle();
        final traits = find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is AppTextField && w.label == 'Rasgos o descripción',
          ),
          matching: find.byType(TextField),
        );
        await tester.ensureVisible(traits);
        await tester.enterText(traits, '🐾' * 201);
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(traits).controller!.text.runes.length,
          200,
        );
        expect(find.text('200/200'), findsOneWidget);
        expect(
          tester
              .widget<AppTextField>(
                find.ancestor(of: traits, matching: find.byType(AppTextField)),
              )
              .invalid,
          false,
        );
        await tester.enterText(traits, '');
        await tester.pumpAndSettle();
        expect(find.text('0/200'), findsOneWidget);
        FocusManager.instance.primaryFocus?.unfocus();
        final species = find.byType(AppSelectField<PetSpecies>);
        await tester.ensureVisible(species);
        await tester.tap(species);
        await tester.pumpAndSettle();
        // The placeholder belongs to the field, never to a selectable menu row.
        expect(find.text('Seleccionar'), findsOneWidget);
        expect(find.byIcon(Icons.check_rounded), findsNothing);
        await tester.tap(find.byTooltip('Cerrar opciones'));
        await tester.pumpAndSettle();
        expect(
          container
              .read(petEditorViewModelProvider('new'))
              .requireValue
              .species,
          isNull,
        );
        await tester.ensureVisible(
          find.byIcon(Icons.add_photo_alternate_outlined),
        );
        await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
        await tester.pumpAndSettle();
        expect(
          find.text('No se pudo abrir la galería. Inténtalo de nuevo.'),
          findsOneWidget,
        );
        expect(
          find.ancestor(
            of: find.text('No se pudo abrir la galería. Inténtalo de nuevo.'),
            matching: find.byType(PetPhotoGallery),
          ),
          findsNothing,
        );
        await tester.tap(find.byKey(const ValueKey('feedback-toast')));
        await tester.pumpAndSettle();
        photos.fail = false;
        await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
        await tester.pumpAndSettle();
        expect(
          find.text('No se pudo abrir la galería. Inténtalo de nuevo.'),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        expect(find.text('Completa los campos obligatorios.'), findsNothing);
      },
    );
  }
}

class _FailingGallery extends FakePetPhotos {
  bool fail = true;
  @override
  Future<Uint8List?> choose(
    String owner,
    String pet,
    bool existing, {
    PetPhotoOrigin origin = PetPhotoOrigin.gallery,
  }) async {
    if (fail) {
      throw const PetPhotoFailure(PetPhotoFailureKind.galleryUnavailable);
    }
    return null;
  }
}
