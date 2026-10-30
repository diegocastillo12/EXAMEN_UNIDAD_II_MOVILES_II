import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pet.dart';
import '../../domain/failures/pet_failure.dart';
import '../../domain/use_cases/validate_pet.dart';
import '../../providers/pet_providers.dart';
import '../state/pet_editor_state.dart';
import 'pet_list_view_model.dart';
import 'pet_photos_view_model.dart';

final petEditorViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<PetEditorViewModel, PetEditorState, String>(
      PetEditorViewModel.new,
      retry: (_, _) => null,
    );

class PetEditorViewModel extends AsyncNotifier<PetEditorState> {
  PetEditorViewModel(this.petId);
  final String petId;
  int _generation = 0;
  int _errorId = 0;
  @override
  Future<PetEditorState> build() async {
    _generation++;
    final read = ref.watch(readPetProvider);
    final session = await ref.watch(petSessionProvider.future);
    if (session == null) throw const PetFailure(PetFailureKind.signedOut);
    if (petId == 'new') {
      return PetEditorState(id: newPetId(), ownerId: session.userId);
    }
    final photos = ref.watch(petPhotosViewModelProvider(petId).notifier);
    final results = await Future.wait<Object?>([
      read(session.userId, petId),
      photos.ensureInitialized(true),
    ]);
    return PetEditorState.fromPet(results.first as Pet);
  }

  void reload() => ref.invalidateSelf();
  void refreshDetail() {
    final current = state.asData?.value;
    if (current != null && !current.busy) {
      ref.invalidate(petDetailViewModelProvider(current.id));
    }
  }

  void edit({
    String? name,
    PetSpecies? species,
    PetSex? sex,
    bool clearSex = false,
    String? age,
    String? traits,
    String? speciesDetail,
    PetSize? size,
    bool clearSize = false,
  }) {
    final current = state.asData?.value;
    if (current == null || current.busy) return;
    state = AsyncData(
      current.copy(
        name: name,
        species: species,
        sex: sex,
        clearSex: clearSex,
        age: age,
        traits: traits,
        speciesDetail: speciesDetail,
        size: size,
        clearSize: clearSize,
        invalidFields: Set.unmodifiable(
          current.invalidFields.where(
            (field) => switch (field) {
              PetFailureKind.invalidName => name == null,
              PetFailureKind.invalidSpecies => species == null,
              PetFailureKind.invalidSpeciesDetail =>
                speciesDetail == null && species == null,
              PetFailureKind.invalidSize => size == null && !clearSize,
              PetFailureKind.invalidAge => age == null,
              PetFailureKind.invalidTraits => traits == null,
              _ => false,
            },
          ),
        ),
      ),
    );
  }

  Future<void> save() async {
    final current = state.asData?.value;
    if (current == null || current.busy) return;
    final photos = ref.read(petPhotosViewModelProvider(current.id));
    if (photos.busy ||
        photos.loading ||
        (!current.dirty && !photos.hasPendingChanges)) {
      return;
    }
    final age = current.age.trim();
    final ageValid = RegExp(r'^\d{1,3}$').hasMatch(age);
    final fields = PetFields(
      speciesDetail: current.speciesDetail,
      size: current.size,
      name: current.name,
      species: current.species,
      sex: current.sex,
      ageMonths: ageValid ? int.tryParse(age) : null,
      traits: current.traits,
    );
    final invalid = petValidationIssues(fields);
    if (invalid.isNotEmpty) {
      state = AsyncData(
        current.copy(
          issue: invalid.first,
          invalidFields: invalid,
          errorId: ++_errorId,
        ),
      );
      return;
    }
    final generation = _generation;
    final lifetime = ref.keepAlive();
    final create = ref.read(createPetProvider);
    final update = ref.read(updatePetProvider);
    state = AsyncData(current.copy(busy: true, invalidFields: const {}));
    try {
      final saved = current.original == null
          ? await create(current.ownerId, current.id, fields)
          : !current.dirty
          ? current.original!
          : await update(
              current.ownerId,
              current.id,
              current.original!.version,
              fields,
            );
      if (!ref.mounted || generation != _generation) return;
      final session = ref.read(petSessionProvider).asData?.value;
      if (session?.userId != current.ownerId) return;
      ref.invalidate(petListViewModelProvider);
      ref.invalidate(archivedPetListViewModelProvider);
      ref.invalidate(petDetailViewModelProvider(saved.id));
      state = AsyncData(PetEditorState.fromPet(saved).copy(busy: true));
      if (!await ref
          .read(petPhotosViewModelProvider(saved.id).notifier)
          .savePendingChanges()) {
        if (ref.mounted && generation == _generation) {
          state = AsyncData(PetEditorState.fromPet(saved));
        }
        return;
      }
      if (!ref.mounted || generation != _generation) return;
      ref.invalidate(petListViewModelProvider);
      ref.invalidate(archivedPetListViewModelProvider);
      ref.invalidate(petDetailViewModelProvider(saved.id));
      state = AsyncData(current.copy(saved: saved));
    } catch (error) {
      if (ref.mounted && generation == _generation) {
        final kind = error is PetFailure
            ? error.kind
            : PetFailureKind.unavailable;
        state = AsyncData(
          current.copy(
            issue: kind,
            errorId: ++_errorId,
            invalidFields:
                const {
                  PetFailureKind.invalidName,
                  PetFailureKind.invalidSpecies,
                  PetFailureKind.invalidSpeciesDetail,
                  PetFailureKind.invalidSize,
                  PetFailureKind.invalidAge,
                  PetFailureKind.invalidTraits,
                }.contains(kind)
                ? {kind}
                : const {},
          ),
        );
      }
    } finally {
      lifetime.close();
    }
  }
}
