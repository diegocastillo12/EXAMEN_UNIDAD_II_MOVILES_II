import '../../../offline_drafts/domain/entities/queued_report.dart';
import 'dart:typed_data';
import '../../../../core/presentation/state/event_date_time_draft.dart';
import '../../domain/entities/sighting.dart';

class SightingState {
  const SightingState({
    required this.owner,
    required this.id,
    this.dateTime = const EventDateTimeDraft(),
    this.point,
    this.comment = '',
    this.photo,
    this.busy = false,
    this.dirty = false,
    this.frozen,
    this.receipt,
    this.submissionStatus,
    this.issue,
    this.fields = const {},
    this.notice = 0,
  });
  final SubmissionStatus? submissionStatus;
  final String owner, id, comment;
  final EventDateTimeDraft dateTime;
  final SightingPoint? point;
  final Uint8List? photo;
  final bool busy, dirty;
  final SightingDraft? frozen;
  final SightingReceipt? receipt;
  final SightingIssue? issue;
  final Set<String> fields;
  final int notice;
  bool get editable =>
      !busy &&
      !{
        SubmissionStatus.pending,
        SubmissionStatus.sending,
      }.contains(submissionStatus) &&
      frozen == null &&
      receipt == null &&
      issue != SightingIssue.closed;
  SightingState copy({
    EventDateTimeDraft? dateTime,
    SightingPoint? point,
    String? comment,
    Uint8List? photo,
    bool removePhoto = false,
    bool? busy,
    bool? dirty,
    SightingDraft? frozen,
    bool unfreeze = false,
    SightingReceipt? receipt,
    bool clearSubmissionStatus = false,
    SubmissionStatus? submissionStatus,
    SightingFailure? failure,
  }) => SightingState(
    submissionStatus: clearSubmissionStatus
        ? null
        : submissionStatus ?? this.submissionStatus,
    owner: owner,
    id: id,
    dateTime: dateTime ?? this.dateTime,
    point: point ?? this.point,
    comment: comment ?? this.comment,
    photo: removePhoto ? null : photo ?? this.photo,
    busy: busy ?? this.busy,
    dirty: dirty ?? this.dirty,
    frozen: unfreeze ? null : frozen ?? this.frozen,
    receipt: receipt ?? this.receipt,
    issue: failure?.issue,
    fields: failure == null ? const {} : Set.unmodifiable(failure.fields),
    notice: notice + (failure == null ? 0 : 1),
  );
}

String sightingIssueLabel(SightingIssue issue) => switch (issue) {
  SightingIssue.blocked =>
    'Un bloqueo entre estas cuentas impide enviar nuevos avistamientos. Puedes revisar tus cuentas bloqueadas desde Perfil.',
  SightingIssue.localStorage =>
    'No pudimos guardar el borrador en este dispositivo. Libera espacio y reintenta antes de salir.',
  SightingIssue.invalid => 'Revisa la fecha, ubicación y los campos marcados.',
  SightingIssue.location =>
    'No pudimos obtener tu ubicación. Puedes marcar el punto en el mapa.',
  SightingIssue.photo =>
    'No pudimos preparar la foto. Puedes elegir otra desde la galería o enviar sin foto.',
  SightingIssue.forbidden =>
    'Revisa tu sesión antes de enviar el avistamiento.',
  SightingIssue.closed =>
    'Este caso ya no admite avistamientos. Conservamos los datos hasta que salgas.',
  SightingIssue.conflict =>
    'La clave de este envío ya fue utilizada. Reintenta el envío original.',
  SightingIssue.rateLimited =>
    'Se alcanzó el límite de avistamientos. Espera unos minutos antes de reintentar.',
  SightingIssue.unavailable =>
    'No pudimos confirmar el envío. Conservamos los datos; reintenta el mismo avistamiento.',
};
