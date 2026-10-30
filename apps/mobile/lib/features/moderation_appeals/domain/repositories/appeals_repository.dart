import '../entities/moderation_appeal.dart';

abstract interface class AppealsRepository {
  Future<AppealPage> list(String actor, AppealCursor? cursor);
  Future<ModeratedDecision> submit(String actor, AppealCommand command);
}
