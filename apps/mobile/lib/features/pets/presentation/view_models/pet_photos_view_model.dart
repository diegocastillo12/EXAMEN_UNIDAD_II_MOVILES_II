import '../state/pet_photos_state.dart';
export '../state/pet_photos_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/utils/new_entity_id.dart';
import '../../domain/entities/pet_photo.dart';
import '../../providers/pet_providers.dart';
import 'pet_list_view_model.dart';

final petPhotosViewModelProvider = NotifierProvider.autoDispose
    .family<PetPhotosViewModel, PetPhotosState, String>(PetPhotosViewModel.new);

class PetPhotosViewModel extends Notifier<PetPhotosState> {
  PetPhotosViewModel(this.petId);
  final String petId;
  int _generation = 0;
  int _errorId = 0;
  Future<void>? _initialization;
  @override
  PetPhotosState build() {
    _generation++;
    _initialization = null;
    ref.watch(petSessionProvider);
    return PetPhotosState();
  }

  String? get _owner => ref.read(petSessionProvider).asData?.value?.userId;
  bool _valid(int generation, String owner) =>
      ref.mounted && generation == _generation && _owner == owner;
  PetPhotoFailureKind _kind(Object e) =>
      e is PetPhotoFailure ? e.kind : PetPhotoFailureKind.unavailable;
  Future<void> ensureInitialized(bool existing) =>
      _initialization ??= initialize(existing);

  Future<void> initialize(bool existing) async {
    if (state.busy || state.loading) return;
    final owner = _owner;
    if (owner == null) return;
    final generation = _generation;
    state = state.copy(loading: existing && state.photos.isEmpty);
    try {
      final useCase = ref.read(managePetPhotosProvider);
      final photos = existing ? await useCase.list(owner, petId) : <PetPhoto>[];
      final recovered = await useCase.recover(owner, petId, existing);
      if (!_valid(generation, owner)) return;
      final drafts = [...state.pending];
      final visibleCount = photos
          .where((photo) => !state.pendingRemovals.contains(photo.id))
          .length;
      if (recovered != null && visibleCount + drafts.length < 3) {
        drafts.add(PetPhotoDraft(id: newEntityId(), bytes: recovered));
      }
      state = state.copy(
        photos: photos,
        pending: drafts,
        recovered: recovered != null,
      );
    } catch (e) {
      if (_valid(generation, owner)) {
        state = state.copy(
          issue: _kind(e),
          failedOperation: PetPhotosOperation.load,
          errorId: ++_errorId,
        );
      }
    }
  }

  Future<void> choose(
    bool existing, {
    PetPhotoOrigin origin = PetPhotoOrigin.gallery,
  }) async {
    if (state.busy || state.loading) return;
    final owner = _owner;
    if (owner == null) return;
    if (state.visiblePhotos.length + state.pending.length >= 3) {
      state = state.copy(
        issue: PetPhotoFailureKind.limit,
        failedOperation: PetPhotosOperation.choose,
        errorId: ++_errorId,
      );
      return;
    }
    final generation = _generation;
    final lifetime = ref.keepAlive();
    state = state.copy(busy: true);
    try {
      final bytes = await ref
          .read(managePetPhotosProvider)
          .choose(owner, petId, existing, origin: origin);
      if (!_valid(generation, owner)) return;
      state = state.copy(
        pending: bytes == null
            ? state.pending
            : [
                ...state.pending,
                PetPhotoDraft(id: newEntityId(), bytes: bytes),
              ],
      );
    } catch (e) {
      if (_valid(generation, owner)) {
        state = state.copy(
          issue: _kind(e),
          failedOperation: PetPhotosOperation.choose,
          errorId: ++_errorId,
        );
      }
    } finally {
      lifetime.close();
    }
  }

  void discardPending() {
    if (state.busy) return;
    state = state.copy(
      pending: const [],
      pendingRemovals: const {},
      recovered: false,
      clearPrimary: true,
    );
  }

  Future<bool> savePendingChanges() async {
    // Detail observes this notifier. The editor refreshes detail after saving;
    // invalidating it here would introduce a circular provider dependency.
    if (!state.hasPendingChanges) return true;
    if (state.busy || state.loading) return false;
    final owner = _owner;
    if (owner == null) return false;
    final generation = _generation;
    final galleryChanged =
        state.pending.isNotEmpty || state.pendingRemovals.isNotEmpty;
    final lifetime = ref.keepAlive();
    state = state.copy(busy: true);
    try {
      final useCase = ref.read(managePetPhotosProvider);
      // Free confirmed slots only after the editor has validated and saved.
      for (final id in Set<String>.of(state.pendingRemovals)) {
        await useCase.remove(owner, petId, id);
        if (!_valid(generation, owner)) return false;
        state = state.copy(
          busy: true,
          photos: state.photos.where((photo) => photo.id != id).toList(),
          pendingRemovals: Set.unmodifiable(
            state.pendingRemovals.where((photoId) => photoId != id),
          ),
        );
        ref.invalidate(petListViewModelProvider);
      }
      for (final draft in List<PetPhotoDraft>.of(state.pending)) {
        final photo = await useCase.upload(owner, petId, draft);
        if (!_valid(generation, owner)) return false;
        state = state.copy(
          busy: true,
          photos: [...state.photos.where((p) => p.id != photo.id), photo],
          pending: state.pending.where((p) => p.id != draft.id).toList(),
        );
      }
      final desiredPrimary = state.pendingPrimaryId;
      if (desiredPrimary != null) {
        // Keep the selection's revision for CAS/retry. Only our confirmed
        // uploads/removals justify reading a newer baseline automatically.
        if (galleryChanged) {
          final current = await useCase.list(owner, petId);
          if (!_valid(generation, owner)) return false;
          state = state.copy(
            photos: current,
            busy: true,
            pendingPrimaryVersion: current.firstOrNull?.selectionVersion ?? 0,
          );
        }
        final version = state.pendingPrimaryVersion ?? 0;
        final selected = await useCase.setPrimary(
          owner,
          petId,
          desiredPrimary,
          version,
        );
        if (!_valid(generation, owner)) return false;
        state = state.copy(photos: selected, busy: true, clearPrimary: true);
        ref.invalidate(petListViewModelProvider);
      }
      if (!_valid(generation, owner)) return false;
      state = state.copy(recovered: false);
      return true;
    } catch (e) {
      if (_valid(generation, owner)) {
        state = state.copy(
          issue: _kind(e),
          failedOperation: PetPhotosOperation.save,
          errorId: ++_errorId,
        );
      }
      return false;
    } finally {
      lifetime.close();
    }
  }

  void stageRemoval(String id) {
    if (state.busy || state.loading || _owner == null) return;
    if (state.pending.any((draft) => draft.id == id)) {
      state = state.copy(
        pending: state.pending.where((draft) => draft.id != id).toList(),
        clearPrimary: state.pendingPrimaryId == id,
      );
    } else if (state.photos.any((photo) => photo.id == id)) {
      state = state.copy(
        pendingRemovals: Set.unmodifiable({...state.pendingRemovals, id}),
        clearPrimary: state.pendingPrimaryId == id,
      );
    }
  }

  void stagePrimary(String id) {
    if (state.busy || state.loading || _owner == null) return;
    if (!state.visiblePhotos.any((p) => p.id == id && p.ready) &&
        !state.pending.any((p) => p.id == id)) {
      return;
    }
    state = state.copy(
      pendingPrimaryId: id,
      pendingPrimaryVersion: state.photos.firstOrNull?.selectionVersion ?? 0,
    );
  }

  Future<void> refreshAfterConflict(bool existing) async {
    await initialize(existing);
    if (!ref.mounted || state.issue != null) return;
    state = state.copy(
      pendingPrimaryVersion: state.photos.firstOrNull?.selectionVersion ?? 0,
    );
  }
}
