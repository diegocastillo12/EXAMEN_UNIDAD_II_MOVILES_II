import '../../domain/entities/recovery_report.dart';

class RecoveryReportsState {
  RecoveryReportsState({
    required this.ownerId,
    required List<RecoveryReport> reports,
    this.refreshing = false,
    this.refreshFailed = false,
    this.busyId,
    this.notice,
    this.noticeId = 0,
    this.noticeIsError = false,
  }) : reports = List.unmodifiable(reports);
  final String ownerId;
  final List<RecoveryReport> reports;
  final bool refreshing, refreshFailed, noticeIsError;
  final String? busyId, notice;
  final int noticeId;
}
