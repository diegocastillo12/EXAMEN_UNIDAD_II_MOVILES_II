import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pet.dart';
import '../../domain/failures/pet_failure.dart';
import '../../providers/pet_providers.dart';
import '../state/pet_deletion_state.dart';
import 'pet_list_view_model.dart';
import 'pet_editor_view_model.dart';
import 'pet_photos_view_model.dart';

final petDeletionViewModelProvider =
    NotifierProvider.autoDispose<PetDeletionViewModel, PetDeletionState>(
      PetDeletionViewModel.new,
    );

class PetDeletionViewModel extends Notifier<PetDeletionState> {
  int _generation = 0;
  int _noticeId = 0;
  @override
  PetDeletionState build() {
    _generation++;
    ref.watch(petSessionProvider);
    return const PetDeletionState();
  }

  Future<void> delete(Pet pet) async {
    if (state.busyId != null) return;
    final owner = ref.read(petSessionProvider).asData?.value?.userId;
    if (owner == null || owner != pet.ownerId) return;
    final generation = _generation;
    final lifetime = ref.keepAlive();
    state = PetDeletionState(busyId: pet.id);
    try {
      await ref.read(deletePetProvider)(owner, pet);
      if (!ref.mounted || generation != _generation) return;
      ref.invalidate(petListViewModelProvider);
      ref.invalidate(archivedPetListViewModelProvider);
      ref.invalidate(petDetailViewModelProvider(pet.id));
      ref.invalidate(petEditorViewModelProvider(pet.id));
      ref.invalidate(petPhotosViewModelProvider(pet.id));
      state = PetDeletionState(confirmed: true, noticeId: ++_noticeId);
    } catch (error) {
      if (!ref.mounted || generation != _generation) return;
      state = PetDeletionState(
        noticeId: ++_noticeId,
        issueId: pet.id,
        issue: error is PetFailure ? error.kind : PetFailureKind.unavailable,
      );
    } finally {
      lifetime.close();
    }
  }
}
