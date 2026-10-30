import 'dart:convert';
import 'dart:typed_data';
import '../../domain/entities/case_timeline.dart';
import '../../domain/repositories/case_timeline_repository.dart';
import '../data_sources/case_timeline_source.dart';
import '../models/case_timeline_dto.dart';

class CaseTimelineRepositoryImpl implements CaseTimelineRepository {
  const CaseTimelineRepositoryImpl(this.source);
  final CaseTimelineSource source;
  Future<T> _run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on TimelineFailure {
      rethrow;
    } on TimelineSourceFailure catch (e) {
      throw TimelineFailure(switch (e.code) {
        'forbidden' => TimelineIssue.forbidden,
        'invalid' => TimelineIssue.invalid,
        'conflict' => TimelineIssue.conflict,
        'closed' => TimelineIssue.closed,
        'transition' => TimelineIssue.transition,
        _ => TimelineIssue.unavailable,
      });
    } catch (_) {
      throw const TimelineFailure(TimelineIssue.unavailable);
    }
  }

  Map<String, dynamic> _target(TimelineTarget t) => {
    'p_source': t.community ? 'found' : 'lost',
    'p_case': t.id,
  };
  @override
  Future<bool> canRead(String owner, TimelineTarget target) => _run(
    () async =>
        await source.call(owner, 'can_read_case_timeline', _target(target))
            as bool,
  );
  @override
  Future<TimelinePage> read(
    String owner,
    TimelineTarget target,
    TimelineCursor? cursor,
  ) => _run(
    () async => CaseTimelineDto.page(
      await source.call(owner, 'read_case_timeline', {
        ..._target(target),
        'p_before_time': cursor?.time.toUtc().toIso8601String(),
        'p_before_key': cursor?.key,
        'p_limit': 20,
      }),
    ),
  );
  @override
  Future<SightingReview> detail(String owner, String id, int? before) => _run(
    () async => CaseTimelineDto.detail(
      await source.call(owner, 'read_sighting_review', {
        'p_id': id,
        'p_before_revision': before,
      }),
    ),
  );
  @override
  Future<Uint8List?> evidence(String owner, String id) => _run(() async {
    final value = await source.call(owner, 'read_sighting_evidence', {
      'p_id': id,
    });
    if (value == null) return null;
    if (value is! String || value.length > 1450000) {
      throw const TimelineFailure(TimelineIssue.unavailable);
    }
    final bytes = base64Decode(
      value.replaceAll(RegExp(r'\s'), ''),
    ).asUnmodifiableView();
    if (bytes.length < 4 ||
        bytes.length > 1048576 ||
        bytes[0] != 255 ||
        bytes[1] != 216 ||
        bytes[bytes.length - 2] != 255 ||
        bytes.last != 217) {
      throw const TimelineFailure(TimelineIssue.unavailable);
    }
    return bytes;
  });
  @override
  Future<SightingDecision> review(String owner, ReviewCommand c) => _run(
    () async => CaseTimelineDto.decision(
      await source.call(owner, 'review_sighting', {
        'p_command': c.id,
        'p_id': c.sightingId,
        'p_expected_revision': c.expectedRevision,
        'p_state': c.state,
        'p_reason': c.reason.trim(),
      }),
    ),
  );
}

class UnavailableCaseTimelineRepository implements CaseTimelineRepository {
  const UnavailableCaseTimelineRepository();
  @override
  Future<bool> canRead(String owner, TimelineTarget target) async => false;
  @override
  Future<TimelinePage> read(
    String owner,
    TimelineTarget target,
    TimelineCursor? cursor,
  ) async => throw const TimelineFailure(TimelineIssue.unavailable);
  @override
  Future<SightingReview> detail(String owner, String id, int? before) async =>
      throw const TimelineFailure(TimelineIssue.unavailable);
  @override
  Future<Uint8List?> evidence(String owner, String id) async =>
      throw const TimelineFailure(TimelineIssue.unavailable);
  @override
  Future<SightingDecision> review(String owner, ReviewCommand command) async =>
      throw const TimelineFailure(TimelineIssue.unavailable);
}
