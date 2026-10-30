import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pet.dart';
import '../../domain/failures/pet_failure.dart';
import '../../providers/pet_providers.dart';
import 'pet_photos_view_model.dart';

final petListViewModelProvider =
    AsyncNotifierProvider.autoDispose<PetListViewModel, List<Pet>>(
      PetListViewModel.new,
      retry: (_, _) => null,
    );

class PetListViewModel extends AsyncNotifier<List<Pet>> {
  PetListViewModel({this.archived = false});
  final bool archived;
  @override
  Future<List<Pet>> build() async {
    final useCase = ref.watch(listMyPetsProvider);
    final session = await ref.watch(petSessionProvider.future);
    if (session == null) throw const PetFailure(PetFailureKind.signedOut);
    final changes = ref
        .watch(petChangesProvider)
        .watch(session.userId)
        .listen((_) => ref.invalidateSelf());
    ref.onDispose(changes.cancel);
    return useCase(session.userId, archived: archived);
  }

  void reload() => ref.invalidateSelf();
}

final petDetailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<PetDetailViewModel, Pet, String>(
      PetDetailViewModel.new,
      retry: (_, _) => null,
    );

class PetDetailViewModel extends AsyncNotifier<Pet> {
  PetDetailViewModel(this.petId);
  final String petId;
  @override
  Future<Pet> build() async {
    final useCase = ref.watch(readPetProvider);
    final session = await ref.watch(petSessionProvider.future);
    if (session == null) throw const PetFailure(PetFailureKind.signedOut);
    final changes = ref
        .watch(petChangesProvider)
        .watch(session.userId, petId: petId)
        .listen((_) => ref.invalidateSelf());
    ref.onDispose(changes.cancel);
    final photos = ref.watch(petPhotosViewModelProvider(petId).notifier);
    final results = await Future.wait<Object?>([
      useCase(session.userId, petId),
      photos.ensureInitialized(true),
    ]);
    return results.first as Pet;
  }

  void reload() => ref.invalidateSelf();
}

final archivedPetListViewModelProvider =
    AsyncNotifierProvider.autoDispose<PetListViewModel, List<Pet>>(
      () => PetListViewModel(archived: true),
      retry: (_, _) => null,
    );
