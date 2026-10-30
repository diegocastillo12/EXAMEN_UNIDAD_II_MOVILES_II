import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/failures/pet_failure.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_list_view_model.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_deletion_view_model.dart';
import 'app_test.dart' show FakeAuthRepository;
import 'support/fake_pets.dart';

void main() {
  for (final switchAccount in [false, true]) {
    test(
      'Deletion retains failed row, blocks duplicates, retries lost ack and guards account; switch=$switchAccount',
      () async {
        final auth = FakeAuthRepository()
          ..current = const AuthSession(userId: 'one');
        const pet = Pet(
          id: 'pet',
          ownerId: 'one',
          fields: PetFields(name: 'Luna', species: PetSpecies.cat),
          version: 1,
        );
        final pets = FakePets()..pets[pet.id] = pet;
        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            petRepositoryProvider.overrideWithValue(pets),
          ],
        );
        addTearDown(() async {
          container.dispose();
          await auth.controller.close();
        });
        final sub = container.listen(petDeletionViewModelProvider, (_, __) {});
        final list = container.listen(petListViewModelProvider, (_, __) {});
        addTearDown(sub.close);
        addTearDown(list.close);
        await container.read(petListViewModelProvider.future);
        final model = container.read(petDeletionViewModelProvider.notifier);
        pets.pending = Completer<void>();
        pets.ambiguousDelete = true;
        final deleting = model.delete(pet);
        await model.delete(pet);
        expect(pets.deletes, 1);
        if (switchAccount) {
          auth.emit(const AuthSession(userId: 'two'));
          await Future<void>.delayed(Duration.zero);
        }
        pets.pending!.complete();
        await deleting;
        expect(container.read(petDeletionViewModelProvider).confirmed, false);
        if (!switchAccount) {
          expect(
            container.read(petDeletionViewModelProvider).issue,
            PetFailureKind.unavailable,
          );
          expect(container.read(petListViewModelProvider).requireValue, [pet]);
          await model.delete(pet);
          expect(container.read(petDeletionViewModelProvider).confirmed, true);
          expect(
            await container.read(petListViewModelProvider.future),
            isEmpty,
          );
        } else {
          expect(container.read(petDeletionViewModelProvider).issue, isNull);
        }
      },
    );
  }
}
