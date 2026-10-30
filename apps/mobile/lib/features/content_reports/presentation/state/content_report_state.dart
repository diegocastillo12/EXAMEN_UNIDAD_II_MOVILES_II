import '../../domain/entities/content_report.dart';

class ContentReportState {
  const ContentReportState({
    required this.actor,
    this.reason = '',
    this.evidence = '',
    this.busy = false,
    this.frozen,
    this.receipt,
    this.issue,
    this.notice = 0,
  });
  final String actor, reason, evidence;
  final bool busy;
  final ReportCommand? frozen;
  final ReportReceipt? receipt;
  final ReportIssue? issue;
  final int notice;
  bool get editable => !busy && frozen == null && receipt == null;
  bool get dirty =>
      receipt == null &&
      (reason.isNotEmpty || evidence.isNotEmpty || frozen != null);
  ContentReportState copy({
    String? reason,
    String? evidence,
    bool busy = false,
    ReportCommand? frozen,
    ReportReceipt? receipt,
    ReportIssue? issue,
    bool clearFrozen = false,
  }) => ContentReportState(
    actor: actor,
    reason: reason ?? this.reason,
    evidence: evidence ?? this.evidence,
    busy: busy,
    frozen: clearFrozen ? null : frozen ?? this.frozen,
    receipt: receipt ?? this.receipt,
    issue: issue,
    notice: notice + 1,
  );
}

String reportFailureLabel(ReportIssue issue) => switch (issue) {
  ReportIssue.invalid =>
    'Escribe un motivo de hasta 500 caracteres y evidencia de hasta 1000.',
  ReportIssue.forbidden =>
    'No tienes acceso a este contenido. Comprueba tu sesión.',
  ReportIssue.conflict =>
    'Este envío no coincide con la denuncia registrada. Sal y vuelve a abrir el formulario.',
  ReportIssue.unavailable =>
    'No pudimos confirmar la denuncia. Reintenta el mismo envío.',
};
