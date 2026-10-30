import '../entities/content_report.dart';
import '../repositories/content_report_repository.dart';

class SubmitContentReport {
  const SubmitContentReport(this.repository);
  final ContentReportRepository repository;
  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );
  void validate(String reason, String evidence) {
    if (reason.trim().isEmpty ||
        reason.trim().runes.length > 500 ||
        evidence.trim().runes.length > 1000) {
      throw const ReportFailure(ReportIssue.invalid);
    }
  }

  Future<ReportReceipt> call(String actor, ReportCommand command) {
    if (actor.isEmpty) throw const ReportFailure(ReportIssue.forbidden);
    if (!_uuid.hasMatch(command.id) ||
        !{'lost', 'found', 'sighting'}.contains(command.target.kind) ||
        !RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        ).hasMatch(command.target.id)) {
      throw const ReportFailure(ReportIssue.invalid);
    }
    validate(command.reason, command.evidence);
    return repository.submit(actor, command);
  }
}
