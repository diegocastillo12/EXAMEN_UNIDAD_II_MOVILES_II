import '../entities/content_report.dart';

abstract interface class ContentReportRepository {
  /// The same command returns the original receipt, including after resource removal.
  Future<ReportReceipt> submit(String actor, ReportCommand command);
}
