import '../../domain/entities/pet_photo.dart';

// Keep the failing operation even when earlier save steps consumed all drafts.
enum PetPhotosOperation { load, choose, save }

class PetPhotosState {
  PetPhotosState({
    List<PetPhoto> photos = const [],
    List<PetPhotoDraft> pending = const [],
    Set<String> pendingRemovals = const {},
    this.busy = false,
    this.loading = false,
    this.issue,
    this.failedOperation,
    this.errorId = 0,
    this.recovered = false,
    this.pendingPrimaryId,
    this.pendingPrimaryVersion,
  }) : photos = List.unmodifiable(photos),
       pending = List.unmodifiable(pending),
       pendingRemovals = Set.unmodifiable(pendingRemovals);
  final List<PetPhoto> photos;
  final List<PetPhotoDraft> pending;
  final Set<String> pendingRemovals;
  final String? pendingPrimaryId;
  final int? pendingPrimaryVersion;
  String? get visiblePrimaryId =>
      pendingPrimaryId ??
      visiblePhotos.where((p) => p.isPrimary && p.ready).firstOrNull?.id ??
      visiblePhotos.where((p) => p.ready).firstOrNull?.id ??
      pending.firstOrNull?.id;
  List<PetPhoto> get visiblePhotos =>
      photos.where((photo) => !pendingRemovals.contains(photo.id)).toList();
  bool get hasPendingChanges =>
      pending.isNotEmpty ||
      pendingRemovals.isNotEmpty ||
      pendingPrimaryId != null;
  final bool busy;
  final bool loading;
  final PetPhotoFailureKind? issue;
  final PetPhotosOperation? failedOperation;
  final int errorId;
  final bool recovered;
  PetPhotosState copy({
    List<PetPhoto>? photos,
    List<PetPhotoDraft>? pending,
    Set<String>? pendingRemovals,
    bool busy = false,
    bool loading = false,
    PetPhotoFailureKind? issue,
    PetPhotosOperation? failedOperation,
    int? errorId,
    bool? recovered,
    String? pendingPrimaryId,
    int? pendingPrimaryVersion,
    bool clearPrimary = false,
  }) => PetPhotosState(
    photos: photos ?? this.photos,
    pending: pending ?? this.pending,
    pendingRemovals: pendingRemovals ?? this.pendingRemovals,
    busy: busy,
    loading: loading,
    issue: issue,
    failedOperation: failedOperation,
    errorId: errorId ?? this.errorId,
    recovered: recovered ?? this.recovered,
    pendingPrimaryId: clearPrimary
        ? null
        : pendingPrimaryId ?? this.pendingPrimaryId,
    pendingPrimaryVersion: clearPrimary
        ? null
        : pendingPrimaryVersion ?? this.pendingPrimaryVersion,
  );
}
