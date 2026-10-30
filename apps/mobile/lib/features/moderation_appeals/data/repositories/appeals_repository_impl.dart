import '../../domain/entities/moderation_appeal.dart';
import '../../domain/repositories/appeals_repository.dart';
import '../data_sources/appeals_source.dart';
import '../models/appeal_dto.dart';

class AppealsRepositoryImpl implements AppealsRepository {
  const AppealsRepositoryImpl(this.source);
  final AppealsSource source;
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppealSourceFailure catch (e) {
      throw AppealFailure(switch (e.code) {
        'invalid' => AppealIssue.invalid,
        'conflict' => AppealIssue.conflict,
        'forbidden' => AppealIssue.forbidden,
        _ => AppealIssue.unavailable,
      });
    } catch (_) {
      throw const AppealFailure(AppealIssue.unavailable);
    }
  }

  @override
  Future<AppealPage> list(String actor, AppealCursor? cursor) => _run(
    () async => AppealDto.page(
      await source.list(actor, {
        'p_review': false,
        'p_before_time': cursor?.time,
        'p_before_id': cursor?.id,
      }),
    ),
  );
  @override
  Future<ModeratedDecision> submit(String actor, AppealCommand command) =>
      _run(() async {
        final entry = AppealDto.decision(
          await source.submit(actor, {
            'p_id': command.id,
            'p_decision': command.decision,
            'p_reason': command.reason,
          }),
        );
        if (entry.id != command.decision ||
            entry.appeal?.id != command.id ||
            entry.appeal?.reason != command.reason) {
          throw const FormatException();
        }
        return entry;
      });
}

class UnavailableAppealsRepository implements AppealsRepository {
  const UnavailableAppealsRepository();
  @override
  Future<AppealPage> list(String actor, AppealCursor? cursor) async =>
      throw const AppealFailure(AppealIssue.unavailable);
  @override
  Future<ModeratedDecision> submit(String actor, AppealCommand command) async =>
      throw const AppealFailure(AppealIssue.unavailable);
}
