import '../../domain/entities/case_closure.dart';

class CaseClosureState {
  const CaseClosureState({
    required this.owner,
    required this.detail,
    this.reason = '',
    this.evidence = '',
    this.busy = false,
    this.saved = false,
    this.requiresRead = false,
    this.refreshing = false,
    this.frozen,
    this.issue,
    this.notice = 0,
  });
  final String owner, reason, evidence;
  final ClosureDetail detail;
  final bool busy, saved, requiresRead, refreshing;
  final ClosureCommand? frozen;
  final ClosureIssue? issue;
  final int notice;
  bool get editable => !busy && !detail.closed && frozen == null;
  CaseClosureState copy({
    String? reason,
    String? evidence,
    bool busy = false,
    bool saved = false,
    bool? requiresRead,
    bool refreshing = false,
    ClosureCommand? frozen,
    bool clearFrozen = false,
    ClosureIssue? issue,
    ClosureDetail? detail,
  }) => CaseClosureState(
    owner: owner,
    detail: detail ?? this.detail,
    reason: reason ?? this.reason,
    evidence: evidence ?? this.evidence,
    busy: busy,
    saved: saved,
    requiresRead: requiresRead ?? this.requiresRead,
    refreshing: refreshing,
    frozen: clearFrozen ? null : frozen ?? this.frozen,
    issue: issue,
    notice: notice + 1,
  );
}

String closureFailureLabel(ClosureIssue issue) => switch (issue) {
  ClosureIssue.invalid =>
    'Escribe el motivo y usa hasta 500 caracteres por campo.',
  ClosureIssue.forbidden => 'No tienes acceso al cierre de este caso.',
  ClosureIssue.closed =>
    'Este caso ya fue cerrado. Consulta el cierre registrado.',
  ClosureIssue.conflict =>
    'La operación no coincide con el cierre registrado. Consulta el estado del caso.',
  ClosureIssue.unavailable =>
    'No pudimos confirmar el cierre. Reintenta la misma operación.',
};
