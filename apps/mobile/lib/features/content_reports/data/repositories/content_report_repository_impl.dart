import '../../domain/entities/content_report.dart';
import '../../domain/repositories/content_report_repository.dart';
import '../data_sources/content_report_source.dart';
import '../models/content_report_dto.dart';

class ContentReportRepositoryImpl implements ContentReportRepository {
  const ContentReportRepositoryImpl(this.source);
  final ContentReportSource source;
  @override
  Future<ReportReceipt> submit(String actor, ReportCommand command) async {
    try {
      final receipt = ContentReportDto.receipt(
        await source.submit(actor, {
          'p_command': command.id,
          'p_kind': command.target.kind,
          'p_resource': command.target.id,
          'p_reason': command.reason.trim(),
          'p_evidence_note': command.evidence.trim().isEmpty
              ? null
              : command.evidence.trim(),
        }),
      );
      if (receipt.id != command.id ||
          receipt.actor != actor ||
          receipt.target != command.target ||
          receipt.reason != command.reason.trim() ||
          (receipt.evidence ?? '') != command.evidence.trim()) {
        throw const FormatException();
      }
      return receipt;
    } on ReportSourceFailure catch (error) {
      throw ReportFailure(switch (error.code) {
        'invalid' => ReportIssue.invalid,
        'forbidden' => ReportIssue.forbidden,
        'conflict' => ReportIssue.conflict,
        _ => ReportIssue.unavailable,
      });
    } catch (_) {
      throw const ReportFailure(ReportIssue.unavailable);
    }
  }
}

class UnavailableContentReportRepository implements ContentReportRepository {
  const UnavailableContentReportRepository();
  @override
  Future<ReportReceipt> submit(String actor, ReportCommand command) async =>
      throw const ReportFailure(ReportIssue.unavailable);
}
