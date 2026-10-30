typedef TimelineTarget = ({String id, bool community});

enum TimelineIssue {
  unavailable,
  forbidden,
  invalid,
  conflict,
  closed,
  transition,
}

class TimelineFailure implements Exception {
  const TimelineFailure(this.issue);
  final TimelineIssue issue;
}

class TimelineCursor {
  const TimelineCursor(this.time, this.key);
  final DateTime time;
  final String key;
}

class TimelineEvent {
  const TimelineEvent({
    required this.key,
    required this.id,
    required this.kind,
    required this.observedAt,
    required this.receivedAt,
    required this.late,
    required this.comment,
    required this.hasPhoto,
    required this.reviewState,
    required this.revision,
  });
  final String key, id, kind, comment, reviewState;
  final DateTime observedAt, receivedAt;
  final bool late, hasPhoto;
  final int revision;
}

class TimelinePage {
  TimelinePage(this.caseStatus, List<TimelineEvent> items, this.next)
    : items = List.unmodifiable(items);
  final String caseStatus;
  final List<TimelineEvent> items;
  final TimelineCursor? next;
}

class SightingDecision {
  const SightingDecision({
    required this.commandId,
    required this.sightingId,
    required this.revision,
    required this.previousState,
    required this.state,
    required this.reason,
    required this.actorId,
    required this.reviewedAt,
  });
  final String commandId, sightingId, previousState, state, reason, actorId;
  final int revision;
  final DateTime reviewedAt;
}

class ReviewCommand {
  const ReviewCommand({
    required this.id,
    required this.sightingId,
    required this.expectedRevision,
    required this.state,
    required this.reason,
  });
  final String id, sightingId, state, reason;
  final int expectedRevision;
}

class SightingReview {
  SightingReview({
    required this.id,
    required this.target,
    required this.canReview,
    required this.observedAt,
    required this.receivedAt,
    required this.late,
    required this.comment,
    required this.latitude,
    required this.longitude,
    required this.locationSource,
    required this.accuracy,
    required this.hasPhoto,
    required this.state,
    required this.revision,
    required List<SightingDecision> history,
    required this.nextRevision,
  }) : history = List.unmodifiable(history);
  final String id, comment, locationSource, state;
  final TimelineTarget target;
  final bool canReview, late, hasPhoto;
  final DateTime observedAt, receivedAt;
  final double latitude, longitude;
  final double? accuracy;
  final int revision;
  final List<SightingDecision> history;
  final int? nextRevision;
  SightingReview withHistory(List<SightingDecision> rows, int? next) =>
      SightingReview(
        id: id,
        target: target,
        canReview: canReview,
        observedAt: observedAt,
        receivedAt: receivedAt,
        late: late,
        comment: comment,
        latitude: latitude,
        longitude: longitude,
        locationSource: locationSource,
        accuracy: accuracy,
        hasPhoto: hasPhoto,
        state: state,
        revision: revision,
        history: rows,
        nextRevision: next,
      );
  SightingReview withDecision(SightingDecision decision) => SightingReview(
    id: id,
    target: target,
    canReview: canReview,
    observedAt: observedAt,
    receivedAt: receivedAt,
    late: late,
    comment: comment,
    latitude: latitude,
    longitude: longitude,
    locationSource: locationSource,
    accuracy: accuracy,
    hasPhoto: hasPhoto,
    state: decision.state,
    revision: decision.revision,
    history: [
      decision,
      ...history.where((r) => r.commandId != decision.commandId),
    ],
    nextRevision: nextRevision,
  );
}
