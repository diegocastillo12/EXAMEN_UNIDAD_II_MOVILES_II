import 'dart:typed_data';
import '../entities/case_timeline.dart';
import '../repositories/case_timeline_repository.dart';

class ReadTimelineAccess {
  const ReadTimelineAccess(this.repository);
  final CaseTimelineRepository repository;
  Future<bool> call(String owner, TimelineTarget target) =>
      owner.isEmpty ? Future.value(false) : repository.canRead(owner, target);
}

class ReadCaseTimeline {
  const ReadCaseTimeline(this.repository);
  final CaseTimelineRepository repository;
  Future<TimelinePage> call(
    String owner,
    TimelineTarget target, [
    TimelineCursor? cursor,
  ]) {
    if (owner.isEmpty) throw const TimelineFailure(TimelineIssue.forbidden);
    return repository.read(owner, target, cursor);
  }
}

class ReadSightingReview {
  const ReadSightingReview(this.repository);
  final CaseTimelineRepository repository;
  Future<SightingReview> call(
    String owner,
    TimelineTarget target,
    String id, [
    int? before,
  ]) async {
    if (owner.isEmpty) throw const TimelineFailure(TimelineIssue.forbidden);
    final value = await repository.detail(owner, id, before);
    if (value.id != id || value.target != target) {
      throw const TimelineFailure(TimelineIssue.forbidden);
    }
    return value;
  }
}

class ReadSightingEvidence {
  const ReadSightingEvidence(this.repository);
  final CaseTimelineRepository repository;
  Future<Uint8List?> call(String owner, String id) {
    if (owner.isEmpty) throw const TimelineFailure(TimelineIssue.forbidden);
    return repository.evidence(owner, id);
  }
}

class ReviewSighting {
  const ReviewSighting(this.repository);
  final CaseTimelineRepository repository;
  void validate(SightingReview sighting, String state, String reason) {
    if (!sighting.canReview) throw const TimelineFailure(TimelineIssue.closed);
    if (!{'useful', 'doubtful', 'rejected', 'confirmed'}.contains(state) ||
        reason.trim().isEmpty ||
        reason.trim().runes.length > 500) {
      throw const TimelineFailure(TimelineIssue.invalid);
    }
    if (sighting.state == state) {
      throw const TimelineFailure(TimelineIssue.transition);
    }
  }

  Future<SightingDecision> call(String owner, ReviewCommand command) async {
    if (owner.isEmpty) throw const TimelineFailure(TimelineIssue.forbidden);
    if (!{
          'useful',
          'doubtful',
          'rejected',
          'confirmed',
        }.contains(command.state) ||
        command.reason.trim().isEmpty ||
        command.reason.trim().runes.length > 500 ||
        command.expectedRevision < 0) {
      throw const TimelineFailure(TimelineIssue.invalid);
    }
    final result = await repository.review(owner, command);
    if (result.commandId != command.id ||
        result.sightingId != command.sightingId ||
        result.revision != command.expectedRevision + 1 ||
        result.state != command.state ||
        result.reason != command.reason.trim() ||
        result.actorId != owner) {
      throw const TimelineFailure(TimelineIssue.unavailable);
    }
    return result;
  }
}
