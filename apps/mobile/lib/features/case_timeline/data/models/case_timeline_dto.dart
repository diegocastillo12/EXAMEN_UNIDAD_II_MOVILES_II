import '../../domain/entities/case_timeline.dart';

class CaseTimelineDto {
  static DateTime date(Object? value) => DateTime.parse(value as String);
  static Map<String, dynamic> row(Object? value) =>
      Map<String, dynamic>.from(value as Map);
  static SightingDecision decision(Object? value) {
    final r = row(value);
    return SightingDecision(
      commandId: r['command_id'] as String,
      sightingId: r['sighting_id'] as String,
      revision: r['revision'] as int,
      previousState: r['previous_state'] as String,
      state: r['state'] as String,
      reason: r['reason'] as String,
      actorId: r['actor_id'] as String,
      reviewedAt: date(r['reviewed_at']),
    );
  }

  static TimelinePage page(Object? value) {
    final r = row(value);
    final next = r['next'] == null ? null : row(r['next']);
    return TimelinePage(
      r['case_status'] as String,
      (r['items'] as List).map((value) {
        final e = row(value);
        return TimelineEvent(
          key: e['key'] as String,
          id: e['id'] as String,
          kind: e['kind'] as String,
          observedAt: date(e['observed_at']),
          receivedAt: date(e['received_at']),
          late: e['is_late'] as bool,
          comment: e['comment'] as String,
          hasPhoto: e['has_photo'] as bool,
          reviewState: e['review_state'] as String,
          revision: e['revision'] as int,
        );
      }).toList(),
      next == null
          ? null
          : TimelineCursor(date(next['time']), next['key'] as String),
    );
  }

  static SightingReview detail(Object? value) {
    final r = row(value);
    return SightingReview(
      id: r['id'] as String,
      target: (
        id: r['case_id'] as String,
        community: r['case_source'] == 'found',
      ),
      canReview: r['can_review'] as bool,
      observedAt: date(r['observed_at']),
      receivedAt: date(r['received_at']),
      late: r['is_late'] as bool,
      comment: r['comment'] as String,
      latitude: (r['latitude'] as num).toDouble(),
      longitude: (r['longitude'] as num).toDouble(),
      locationSource: r['location_source'] as String,
      accuracy: (r['accuracy_meters'] as num?)?.toDouble(),
      hasPhoto: r['has_photo'] as bool,
      state: r['review_state'] as String,
      revision: r['revision'] as int,
      history: (r['history'] as List).map(decision).toList(),
      nextRevision: r['next_revision'] as int?,
    );
  }
}
