import '../../../offline_drafts/domain/entities/queued_report.dart';
import '../../../../core/presentation/state/event_date_time_draft.dart';
import '../../../../core/domain/use_cases/approximate_case_location.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../../pets/domain/entities/pet_photo.dart';
import '../../domain/entities/lost_case.dart';

enum CaseEditorStage { form, preview, confirmed }

class CaseEditorState {
  CaseEditorState({
    required this.ownerId,
    required this.draftId,
    required List<Pet> pets,
    this.pet,
    List<PetPhoto> photos = const [],
    Set<String> selectedPhotos = const {},
    DateTime? occurredAt,
    EventDateTimeDraft? dateTimeDraft,
    this.latitude,
    this.longitude,
    this.placeReference = '',
    this.submissionStatus,
    this.issue,
    this.errorId = 0,
    Set<CaseField> invalidFields = const {},
    this.busy = false,
    this.loadingPhotos = false,
    this.dirty = false,
    this.lockedDraft,
    this.stage = CaseEditorStage.form,
    this.published,
  }) : dateTimeDraft = dateTimeDraft ?? EventDateTimeDraft.from(occurredAt),
       pets = List.unmodifiable(pets),
       photos = List.unmodifiable(photos),
       selectedPhotos = Set.unmodifiable(selectedPhotos),
       invalidFields = Set.unmodifiable(invalidFields);
  final SubmissionStatus? submissionStatus;
  final String ownerId, draftId, placeReference;
  final List<Pet> pets;
  final Pet? pet;
  final List<PetPhoto> photos;
  final Set<String> selectedPhotos;
  final EventDateTimeDraft dateTimeDraft;
  DateTime? get occurredAt => dateTimeDraft.value;
  final double? latitude, longitude;
  final int errorId;
  final CaseFailureKind? issue;
  final Set<CaseField> invalidFields;
  final bool busy, loadingPhotos, dirty;
  final CaseEditorStage stage;
  final PublishedLostCase? published;
  // Ambiguous response: freeze the exact command until its retry is confirmed.
  final LostCaseDraft? lockedDraft;
  PublicLostCase get preview {
    final location = approximateCaseLocation(latitude!, longitude!);
    return PublicLostCase(
      id: draftId,
      status: 'active',
      occurredAt: occurredAt!,
      latitude: location.latitude,
      longitude: location.longitude,
      fields: pet!.fields,
      photos: photos
          .where((p) => selectedPhotos.contains(p.id))
          .map((p) => CasePhoto(id: p.id, uri: p.uri))
          .toList(),
    );
  }

  CaseEditorState copyWith({
    bool clearSubmissionStatus = false,
    SubmissionStatus? submissionStatus,
    bool clearPoint = false,
    Pet? pet,
    List<PetPhoto>? photos,
    Set<String>? selectedPhotos,
    DateTime? occurredAt,
    EventDateTimeDraft? dateTimeDraft,
    double? latitude,
    double? longitude,
    String? placeReference,
    CaseFailureKind? issue,
    Set<CaseField>? invalidFields,
    bool clearIssue = false,
    bool? busy,
    bool? loadingPhotos,
    bool? dirty,
    CaseEditorStage? stage,
    PublishedLostCase? published,
    LostCaseDraft? lockedDraft,
    bool clearLockedDraft = false,
  }) => CaseEditorState(
    submissionStatus: clearSubmissionStatus
        ? null
        : submissionStatus ?? this.submissionStatus,
    ownerId: ownerId,
    draftId: draftId,
    pets: pets,
    pet: pet ?? this.pet,
    photos: photos ?? this.photos,
    selectedPhotos: selectedPhotos ?? this.selectedPhotos,
    dateTimeDraft:
        dateTimeDraft ??
        (occurredAt == null
            ? this.dateTimeDraft
            : EventDateTimeDraft.from(occurredAt)),
    latitude: clearPoint ? null : latitude ?? this.latitude,
    longitude: clearPoint ? null : longitude ?? this.longitude,
    placeReference: placeReference ?? this.placeReference,
    issue: clearIssue ? null : issue ?? this.issue,
    errorId: issue != null ? errorId + 1 : errorId,
    invalidFields: clearIssue ? {} : invalidFields ?? this.invalidFields,
    busy: busy ?? this.busy,
    loadingPhotos: loadingPhotos ?? this.loadingPhotos,
    dirty: dirty ?? this.dirty,
    stage: stage ?? this.stage,
    published: published ?? this.published,
    lockedDraft: clearLockedDraft ? null : lockedDraft ?? this.lockedDraft,
  );
}
