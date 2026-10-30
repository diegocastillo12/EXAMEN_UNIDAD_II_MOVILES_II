import '../../domain/entities/case_closure.dart';

class CaseClosureDto {
  static ClosureReceipt receipt(Object? raw) {
    final r = Map<String, dynamic>.from(raw as Map);
    final source = r['case_source'] as String;
    if (!{'lost', 'found'}.contains(source)) throw const FormatException();
    return ClosureReceipt(
      commandId: r['command_id'] as String,
      target: (id: r['case_id'] as String, community: source == 'found'),
      actor: r['actor_id'] as String,
      closedAt: DateTime.parse(r['closed_at'] as String),
      reason: r['reason'] as String,
      evidence: r['evidence_note'] as String?,
    );
  }

  static ClosureDetail detail(Object? raw) {
    final r = Map<String, dynamic>.from(raw as Map);
    if (!{'active', 'resolved'}.contains(r['status'])) {
      throw const FormatException();
    }
    return ClosureDetail(
      closed: r['status'] == 'resolved',
      receipt: r['receipt'] == null ? null : receipt(r['receipt']),
    );
  }
}
