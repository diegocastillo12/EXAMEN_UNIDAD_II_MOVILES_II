typedef ClosureTarget = ({String id, bool community});

enum ClosureIssue { forbidden, invalid, conflict, closed, unavailable }

class ClosureFailure implements Exception {
  const ClosureFailure(this.issue);
  final ClosureIssue issue;
}

class ClosureCommand {
  const ClosureCommand({
    required this.id,
    required this.target,
    required this.reason,
    required this.evidence,
  });
  final String id, reason, evidence;
  final ClosureTarget target;
}

class ClosureReceipt {
  const ClosureReceipt({
    required this.commandId,
    required this.target,
    required this.actor,
    required this.closedAt,
    required this.reason,
    this.evidence,
  });
  final String commandId, actor, reason;
  final ClosureTarget target;
  final DateTime closedAt;
  final String? evidence;
}

class ClosureDetail {
  const ClosureDetail({required this.closed, this.receipt});
  final bool closed;
  final ClosureReceipt? receipt;
}
