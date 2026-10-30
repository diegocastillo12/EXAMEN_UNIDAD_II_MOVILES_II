import 'dart:typed_data';
import '../entities/case_timeline.dart';

abstract interface class CaseTimelineRepository {
  Future<bool> canRead(String owner, TimelineTarget target);
  Future<TimelinePage> read(
    String owner,
    TimelineTarget target,
    TimelineCursor? cursor,
  );
  Future<SightingReview> detail(String owner, String id, int? before);
  Future<Uint8List?> evidence(String owner, String id);
  Future<SightingDecision> review(String owner, ReviewCommand command);
}
