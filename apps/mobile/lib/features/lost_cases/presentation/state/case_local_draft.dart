import '../../../offline_drafts/domain/entities/local_report_draft.dart';
import '../../../../core/presentation/state/event_date_time_draft.dart';
import '../../domain/entities/lost_case.dart';
import 'case_editor_state.dart';

// Presentation maps its editor state to the persistent domain contract.
LocalReportDraft caseLocalDraft(CaseEditorState v) => LocalReportDraft(
  owner: v.ownerId,
  slot: 'lost',
  id: v.draftId,
  date: v.dateTimeDraft.date,
  hour: v.dateTimeDraft.hour,
  minute: v.dateTimeDraft.minute,
  instant: v.lockedDraft?.occurredAt ?? v.occurredAt,
  latitude: v.latitude,
  longitude: v.longitude,
  place: v.placeReference,
  pet: v.pet,
  pets: v.pets,
  petPhotos: v.photos,
  selectedPhotos: v.selectedPhotos.toList(),
  frozen: v.lockedDraft != null,
);
CaseEditorState restoreCaseLocalDraft(LocalReportDraft d) {
  final dateTime = d.instant == null
      ? EventDateTimeDraft(date: d.date, hour: d.hour, minute: d.minute)
      : EventDateTimeDraft.from(d.instant);
  return CaseEditorState(
    ownerId: d.owner,
    draftId: d.id,
    pets: d.pets,
    pet: d.pet,
    photos: d.petPhotos,
    selectedPhotos: d.selectedPhotos.toSet(),
    dateTimeDraft: dateTime,
    latitude: d.latitude,
    longitude: d.longitude,
    placeReference: d.place,
    dirty: true,
    stage: d.frozen ? CaseEditorStage.preview : CaseEditorStage.form,
    lockedDraft: !d.frozen
        ? null
        : LostCaseDraft(
            id: d.id,
            petId: d.pet!.id,
            petVersion: d.pet!.version,
            occurredAt: d.instant!,
            latitude: d.latitude!,
            longitude: d.longitude!,
            placeReference: d.place,
            photoIds: d.selectedPhotos,
          ),
  );
}

Object caseCheckpointKey(CaseEditorState v) => (
  v.draftId,
  v.pet,
  v.pets.map((p) => '${p.id}:${p.version}').join(','),
  v.photos.map((p) => p.id).join(','),
  (v.selectedPhotos.toList()..sort()).join(','),
  v.dateTimeDraft,
  v.latitude,
  v.longitude,
  v.placeReference,
  v.lockedDraft,
  v.stage == CaseEditorStage.confirmed,
);
