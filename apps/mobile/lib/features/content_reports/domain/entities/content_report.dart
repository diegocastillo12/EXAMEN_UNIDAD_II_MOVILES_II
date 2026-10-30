typedef ReportTarget = ({String kind, String id});

enum ReportIssue { invalid, forbidden, conflict, unavailable }

class ReportFailure implements Exception {
  const ReportFailure(this.issue);
  final ReportIssue issue;
}

class ReportCommand {
  const ReportCommand({
    required this.id,
    required this.target,
    required this.reason,
    required this.evidence,
  });
  final String id, reason, evidence;
  final ReportTarget target;
}

class ReportReceipt {
  const ReportReceipt({
    required this.id,
    required this.actor,
    required this.target,
    required this.reason,
    required this.evidence,
    required this.submittedAt,
  });
  final String id, actor, reason;
  final String? evidence;
  final ReportTarget target;
  final DateTime submittedAt;
}
