import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/data/data_sources/case_timeline_source.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/data/repositories/case_timeline_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/domain/entities/case_timeline.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/domain/use_cases/timeline_actions.dart';

class _Source implements CaseTimelineSource {
  Object? value;
  TimelineSourceFailure? error;
  String? function;
  Map<String, dynamic>? params;
  @override
  Future<Object?> call(
    String owner,
    String function,
    Map<String, dynamic> params,
  ) async {
    this.function = function;
    this.params = params;
    if (error != null) throw error!;
    return value;
  }
}

void main() {
  test(
    'Repository maps only safe failures and bounds private evidence',
    () async {
      final source = _Source(),
          repository = CaseTimelineRepositoryImpl(_Source());
      final repo = CaseTimelineRepositoryImpl(source);
      for (final issue in TimelineIssue.values) {
        source.error = TimelineSourceFailure(issue.name);
        await expectLater(
          repo.canRead('owner', (id: 'case', community: false)),
          throwsA(
            isA<TimelineFailure>().having((e) => e.issue, 'issue', issue),
          ),
        );
      }
      source.error = null;
      source.value = base64Encode([255, 216, 255, 217]);
      final photo = await repo.evidence('owner', 'sighting');
      expect(photo, [255, 216, 255, 217]);
      expect(() => photo![0] = 0, throwsUnsupportedError);
      expect(source.function, 'read_sighting_evidence');
      expect(source.params, {'p_id': 'sighting'});
      for (final invalid in [
        'bad-base64',
        base64Encode([1, 2, 3, 4]),
        'x' * 1450001,
      ]) {
        source.value = invalid;
        await expectLater(
          repo.evidence('owner', 'sighting'),
          throwsA(isA<TimelineFailure>()),
        );
      }
      await expectLater(
        repository.detail('owner', 'sighting', null),
        throwsA(isA<TimelineFailure>()),
      );
    },
  );
  test(
    'Detail DTO preserves timestamps/audit and domain rejects a different case',
    () async {
      final source = _Source()
        ..value = {
          'id': 'sighting',
          'case_source': 'lost',
          'case_id': 'case',
          'can_review': true,
          'observed_at': '2026-10-10T10:30:00Z',
          'received_at': '2026-10-12T10:30:00Z',
          'is_late': true,
          'comment': 'Evidence',
          'latitude': -12.123,
          'longitude': -77.123,
          'location_source': 'gps',
          'accuracy_meters': 25,
          'has_photo': false,
          'review_state': 'confirmed',
          'revision': 1,
          'next_revision': null,
          'history': [
            {
              'command_id': 'command',
              'sighting_id': 'sighting',
              'revision': 1,
              'previous_state': 'unreviewed',
              'state': 'confirmed',
              'reason': 'Same collar',
              'actor_id': 'owner',
              'reviewed_at': '2026-10-13T10:30:00Z',
            },
          ],
        };
      final action = ReadSightingReview(CaseTimelineRepositoryImpl(source));
      final value = await action('owner', (
        id: 'case',
        community: false,
      ), 'sighting');
      expect(value.receivedAt.difference(value.observedAt).inDays, 2);
      expect(value.history.single.actorId, 'owner');
      expect(value.accuracy, 25);
      expect(value.canReview, true);
      await expectLater(
        action('owner', (id: 'other', community: false), 'sighting'),
        throwsA(
          isA<TimelineFailure>().having(
            (e) => e.issue,
            'issue',
            TimelineIssue.forbidden,
          ),
        ),
      );
    },
  );
}
