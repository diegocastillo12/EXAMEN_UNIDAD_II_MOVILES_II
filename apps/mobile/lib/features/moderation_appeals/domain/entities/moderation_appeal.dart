enum AppealIssue { invalid, forbidden, conflict, unavailable }

class AppealFailure implements Exception {
  const AppealFailure(this.issue);
  final AppealIssue issue;
}

typedef AppealCursor = ({String time, String id});

class AppealAnswer {
  const AppealAnswer({
    required this.id,
    required this.actor,
    required this.reason,
    required this.answeredAt,
  });
  final String id, actor, reason;
  final DateTime answeredAt;
}

class AppealSubmission {
  const AppealSubmission({
    required this.id,
    required this.reason,
    required this.submittedAt,
    this.answer,
  });
  final String id, reason;
  final DateTime submittedAt;
  final AppealAnswer? answer;
}

class ModeratedDecision {
  const ModeratedDecision({
    required this.id,
    required this.kind,
    required this.resource,
    required this.action,
    required this.reason,
    required this.decidedAt,
    this.appeal,
  });
  final String id, kind, resource, action, reason;
  final DateTime decidedAt;
  final AppealSubmission? appeal;
}

class AppealPage {
  AppealPage({required List<ModeratedDecision> items, this.next})
    : items = List.unmodifiable(items);
  final List<ModeratedDecision> items;
  final AppealCursor? next;
}

class AppealCommand {
  const AppealCommand({
    required this.id,
    required this.decision,
    required this.reason,
  });
  final String id, decision, reason;
}
