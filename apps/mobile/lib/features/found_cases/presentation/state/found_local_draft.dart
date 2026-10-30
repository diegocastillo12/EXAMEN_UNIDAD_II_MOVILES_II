import '../../../offline_drafts/domain/entities/local_report_draft.dart';
import '../../../../core/presentation/state/event_date_time_draft.dart';
import '../../domain/entities/found_case.dart';
import 'found_editor_state.dart';

String foundDraftSlot(FoundEditorContext c) => c.independentFound
    ? 'independent-found'
    : c.communitySearch
    ? 'community-search'
    : 'found:${c.communityTarget}:${c.targetId}';
LocalReportDraft foundLocalDraft(FoundEditorState v, String slot) =>
    LocalReportDraft(
      owner: v.ownerId,
      slot: slot,
      id: v.draftId,
      date: v.dateTimeDraft.date,
      hour: v.dateTimeDraft.hour,
      minute: v.dateTimeDraft.minute,
      instant: v.lockedDraft?.occurredAt ?? v.occurredAt,
      latitude: v.latitude,
      longitude: v.longitude,
      place: v.placeReference,
      species: v.species,
      speciesDetail: v.speciesDetail,
      size: v.size,
      sex: v.sex,
      traits: v.traits,
      custody: v.custody,
      reportKind: v.reportKind,
      photos: v.photos,
      target: v.target,
      frozen: v.lockedDraft != null,
      attempted: v.attempted,
    );
FoundEditorState restoreFoundLocalDraft(
  LocalReportDraft d,
  FoundEditorContext c,
) {
  final dateTime = d.instant == null
      ? EventDateTimeDraft(date: d.date, hour: d.hour, minute: d.minute)
      : EventDateTimeDraft.from(d.instant);
  return FoundEditorState(
    ownerId: d.owner,
    draftId: d.id,
    communitySearch: c.communitySearch,
    target: d.target,
    targetId: c.targetId,
    communityTarget: c.communityTarget,
    reportKind: d.reportKind,
    dateTimeDraft: dateTime,
    latitude: d.latitude,
    longitude: d.longitude,
    placeReference: d.place,
    species: d.species,
    speciesDetail: d.speciesDetail,
    size: d.size,
    sex: d.sex,
    traits: d.traits,
    custody: d.custody,
    photos: d.photos,
    dirty: true,
    attempted: d.attempted,
    stage: d.frozen ? FoundStage.preview : FoundStage.form,
    lockedDraft: !d.frozen
        ? null
        : FoundCaseDraft(
            id: d.id,
            reportKind: d.reportKind,
            targetId: c.targetId,
            communityTarget: c.communityTarget,
            occurredAt: d.instant!,
            latitude: d.latitude!,
            longitude: d.longitude!,
            placeReference: d.place,
            species: d.species,
            speciesDetail: d.species == 'other' ? d.speciesDetail : null,
            size: d.size.isEmpty ? null : d.size,
            sex: d.sex.isEmpty ? null : d.sex,
            traits: d.traits,
            custody: d.custody.isEmpty ? null : d.custody,
            photos: d.photos,
          ),
  );
}

Object foundCheckpointKey(FoundEditorState v) => (
  v.draftId,
  v.dateTimeDraft,
  v.latitude,
  v.longitude,
  v.placeReference,
  v.species,
  v.speciesDetail,
  v.size,
  v.sex,
  v.traits,
  v.custody,
  v.photos.map((p) => p.id).join(','),
  v.target,
  v.reportKind,
  v.lockedDraft,
  v.attempted,
  v.stage == FoundStage.confirmed,
);
