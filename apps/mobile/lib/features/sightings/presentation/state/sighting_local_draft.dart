import '../../../offline_drafts/domain/entities/local_report_draft.dart';
import '../../../../core/presentation/state/event_date_time_draft.dart';
import '../../domain/entities/sighting.dart';
import 'sighting_state.dart';

String sightingDraftSlot(SightingTarget t) => 'sighting:${t.community}:${t.id}';
LocalReportDraft sightingLocalDraft(SightingState v, String slot) =>
    LocalReportDraft(
      owner: v.owner,
      slot: slot,
      id: v.id,
      date: v.dateTime.date,
      hour: v.dateTime.hour,
      minute: v.dateTime.minute,
      instant: v.frozen?.observedAt ?? v.dateTime.value,
      latitude: v.point?.latitude,
      longitude: v.point?.longitude,
      accuracy: v.point?.accuracy,
      comment: v.comment,
      photo: v.photo,
      frozen: v.frozen != null,
    );
SightingState restoreSightingLocalDraft(LocalReportDraft d, SightingTarget t) {
  final dateTime = d.instant == null
      ? EventDateTimeDraft(date: d.date, hour: d.hour, minute: d.minute)
      : EventDateTimeDraft.from(d.instant);
  final point = d.latitude == null
      ? null
      : SightingPoint(d.latitude!, d.longitude!, accuracy: d.accuracy);
  return SightingState(
    owner: d.owner,
    id: d.id,
    dateTime: dateTime,
    point: point,
    comment: d.comment,
    photo: d.photo,
    dirty: true,
    frozen: !d.frozen
        ? null
        : SightingDraft(
            id: d.id,
            target: t,
            observedAt: d.instant!,
            point: point!,
            comment: d.comment,
            photo: d.photo,
          ),
  );
}

Object sightingCheckpointKey(SightingState v) =>
    (v.id, v.dateTime, v.point, v.comment, v.photo, v.frozen, v.receipt);
