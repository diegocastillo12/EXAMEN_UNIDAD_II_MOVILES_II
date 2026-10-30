import '../domain/services/pet_changes.dart';
import '../domain/use_cases/notify_pet_changed.dart';
import '../domain/use_cases/archive_pet.dart';
import '../domain/use_cases/restore_pet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/pet_repository.dart';
import '../domain/use_cases/list_my_pets.dart';
import '../domain/use_cases/read_pet.dart';
import '../domain/use_cases/create_pet.dart';
import '../domain/use_cases/update_pet.dart';
import '../domain/repositories/pet_photo_repository.dart';
import '../domain/use_cases/manage_pet_photos.dart';
import '../domain/use_cases/delete_pet.dart';

final deletePetProvider = Provider(
  (ref) => DeletePet(ref.watch(petRepositoryProvider)),
);

final petPhotoRepositoryProvider = Provider<PetPhotoRepository>(
  (ref) => throw StateError('PetPhotoRepository must be injected.'),
);
final managePetPhotosProvider = Provider(
  (ref) => ManagePetPhotos(ref.watch(petPhotoRepositoryProvider)),
);

final petRepositoryProvider = Provider<PetRepository>(
  (ref) => throw StateError('PetRepository must be injected.'),
);
final petSessionProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(watchAuthSessionProvider)(),
);
final listMyPetsProvider = Provider(
  (ref) => ListMyPets(ref.watch(petRepositoryProvider)),
);
final readPetProvider = Provider(
  (ref) => ReadPet(ref.watch(petRepositoryProvider)),
);
final createPetProvider = Provider(
  (ref) => CreatePet(ref.watch(petRepositoryProvider)),
);
final updatePetProvider = Provider(
  (ref) => UpdatePet(ref.watch(petRepositoryProvider)),
);

final archivePetProvider = Provider(
  (ref) => ArchivePet(ref.watch(petRepositoryProvider)),
);
final restorePetProvider = Provider(
  (ref) => RestorePet(ref.watch(petRepositoryProvider)),
);

// Owned by ProviderScope; listeners are released by each screen ViewModel.
final petChangesProvider = Provider((ref) {
  final changes = PetChanges();
  ref.onDispose(changes.dispose);
  return changes;
});
final notifyPetChangedProvider = Provider(
  (ref) => NotifyPetChanged(ref.watch(petChangesProvider)),
);
