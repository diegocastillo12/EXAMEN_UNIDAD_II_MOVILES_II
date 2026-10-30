import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pet.dart';
import '../../domain/failures/pet_failure.dart';
import '../../providers/pet_providers.dart';
import '../state/pet_lifecycle_state.dart';
import 'pet_list_view_model.dart';
import 'pet_editor_view_model.dart';

final petLifecycleViewModelProvider = NotifierProvider.autoDispose
    .family<PetLifecycleViewModel, PetLifecycleState, String>(
      PetLifecycleViewModel.new,
    );

class PetLifecycleViewModel extends Notifier<PetLifecycleState> {
  PetLifecycleViewModel(this.petId);
  final String petId;
  int _generation = 0;
  int _noticeId = 0;

  @override
  PetLifecycleState build() {
    _generation++;
    ref.watch(petSessionProvider);
    return const PetLifecycleState();
  }

  void clearFeedback() {
    if (!state.busy) state = const PetLifecycleState();
  }

  Future<void> change(Pet pet) async {
    if (state.busy || pet.id != petId) return;
    final owner = ref.read(petSessionProvider).asData?.value?.userId;
    if (owner == null || owner != pet.ownerId) return;
    final generation = _generation;
    final lifetime = ref.keepAlive();
    state = const PetLifecycleState(busy: true);
    try {
      final saved = pet.isArchived
          ? await ref.read(restorePetProvider)(owner, pet)
          : await ref.read(archivePetProvider)(owner, pet);
      if (!ref.mounted || generation != _generation) return;
      ref.invalidate(petListViewModelProvider);
      ref.invalidate(archivedPetListViewModelProvider);
      ref.invalidate(petDetailViewModelProvider(petId));
      ref.invalidate(petEditorViewModelProvider(petId));
      state = PetLifecycleState(
        confirmed: true,
        archived: saved.isArchived,
        noticeId: ++_noticeId,
      );
    } catch (error) {
      if (!ref.mounted || generation != _generation) return;
      state = PetLifecycleState(
        noticeId: ++_noticeId,
        issue: error is PetFailure ? error.kind : PetFailureKind.unavailable,
      );
    } finally {
      lifetime.close();
    }
  }
}
