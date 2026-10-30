import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet_photo.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_photos_view_model.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pet_photo_gallery.dart';

class _FailedPhotos extends PetPhotosViewModel {
  _FailedPhotos(super.petId, this.operation);
  final PetPhotosOperation operation;
  @override
  PetPhotosState build() => PetPhotosState(
    issue: PetPhotoFailureKind.unavailable,
    failedOperation: operation,
    errorId: 1,
  );
  @override
  Future<void> ensureInitialized(bool existing) async {}
}

void main() {
  for (final operation in [PetPhotosOperation.save, PetPhotosOperation.load]) {
    testWidgets('Photo $operation failure uses its operation, with no drafts', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            petPhotosViewModelProvider(
              'pet',
            ).overrideWith(() => _FailedPhotos('pet', operation)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PetPhotoGallery(
                petId: 'pet',
                existing: true,
                editable: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      final saving = operation == PetPhotosOperation.save;
      expect(
        find.text(
          saving
              ? 'No se pudieron guardar las fotos. Reintenta al guardar.'
              : 'No se pudieron consultar las fotos.',
        ),
        findsOneWidget,
      );
      expect(find.text('Reintentar'), saving ? findsNothing : findsOneWidget);
      expect(find.text('Reintentar consulta'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 10));
    });
  }
}
