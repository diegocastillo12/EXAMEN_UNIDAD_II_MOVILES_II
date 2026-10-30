import '../../domain/entities/content_report.dart';

class ContentReportDto {
  static ReportReceipt receipt(Object? raw) {
    final row = Map<String, dynamic>.from(raw as Map);
    final kind = row['resource_kind'] as String;
    if (!{'lost', 'found', 'sighting'}.contains(kind)) {
      throw const FormatException();
    }
    return ReportReceipt(
      id: row['id'] as String,
      actor: row['reporter_id'] as String,
      target: (kind: kind, id: row['resource_id'] as String),
      reason: row['reason'] as String,
      evidence: row['evidence_note'] as String?,
      submittedAt: DateTime.parse(row['submitted_at'] as String),
    );
  }
}
