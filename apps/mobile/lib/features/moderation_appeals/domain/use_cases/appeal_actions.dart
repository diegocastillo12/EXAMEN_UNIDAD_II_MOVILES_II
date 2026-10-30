import '../entities/moderation_appeal.dart';
import '../repositories/appeals_repository.dart';

class ReadAppeals {
  const ReadAppeals(this.repository);
  final AppealsRepository repository;
  Future<AppealPage> call(String actor, [AppealCursor? cursor]) =>
      repository.list(actor, cursor);
}

class SubmitAppeal {
  const SubmitAppeal(this.repository);
  final AppealsRepository repository;
  void validate(String reason) {
    if (reason.trim().isEmpty || reason.trim().runes.length > 1000) {
      throw const AppealFailure(AppealIssue.invalid);
    }
  }

  Future<ModeratedDecision> call(String actor, AppealCommand command) {
    validate(command.reason);
    final uuid = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    if (!uuid.hasMatch(command.id) ||
        !RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        ).hasMatch(command.decision)) {
      throw const AppealFailure(AppealIssue.invalid);
    }
    return repository.submit(
      actor,
      AppealCommand(
        id: command.id,
        decision: command.decision,
        reason: command.reason.trim(),
      ),
    );
  }
}
