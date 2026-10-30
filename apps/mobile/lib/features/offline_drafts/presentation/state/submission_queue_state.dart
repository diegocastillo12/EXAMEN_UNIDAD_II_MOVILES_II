import '../../domain/entities/queued_report.dart';

class SubmissionQueueState {
  SubmissionQueueState({
    required this.owner,
    required List<QueuedReport> entries,
    this.busyId,
    this.issue,
    this.noticeId = 0,
  }) : entries = List.unmodifiable(entries);
  final String owner;
  final List<QueuedReport> entries;
  final String? busyId;
  final SubmissionIssue? issue;
  final int noticeId;
  SubmissionQueueState copy({
    List<QueuedReport>? entries,
    String? busyId,
    bool clearBusy = false,
    SubmissionIssue? issue,
    bool clearIssue = false,
  }) => SubmissionQueueState(
    owner: owner,
    entries: entries ?? this.entries,
    busyId: clearBusy ? null : busyId ?? this.busyId,
    issue: clearIssue ? null : issue ?? this.issue,
    noticeId: issue == null ? noticeId : noticeId + 1,
  );
}

String submissionIssueLabel(SubmissionIssue? issue) => switch (issue) {
  SubmissionIssue.conflict =>
    'El contenido no coincide con el envío original o ya existe otro resultado. Consulta tus reportes antes de cambiar el envío.',
  SubmissionIssue.invalid =>
    'El servidor rechazó los datos. Revisa el reporte y confirma los cambios antes de enviarlo de nuevo.',
  SubmissionIssue.photo =>
    'El servidor rechazó la evidencia. Revisa las fotos y confirma el envío corregido.',
  SubmissionIssue.forbidden =>
    'No pudimos autorizar este envío. Revisa la sesión antes de reintentar.',
  SubmissionIssue.blocked =>
    'Un bloqueo entre cuentas impide este envío. Revisa tus cuentas bloqueadas.',
  SubmissionIssue.closed =>
    'La búsqueda ya no admite este envío. Consulta su ficha.',
  SubmissionIssue.rateLimited =>
    'Se alcanzó un límite de envíos. Espera antes de reintentar.',
  SubmissionIssue.busy =>
    'Este envío ya tiene un intento en curso. Espera su confirmación.',
  _ =>
    'No pudimos confirmar la operación. Revisa el estado del envío y reintenta.',
};
