import 'dart:typed_data';
import '../../domain/entities/case_timeline.dart';

class CaseTimelineState {
  const CaseTimelineState({
    required this.owner,
    required this.page,
    this.busy = false,
    this.failure,
    this.notice = 0,
  });
  final String owner;
  final TimelinePage page;
  final bool busy;
  final TimelineIssue? failure;
  final int notice;
}

enum ReviewWork { save, refresh, photo, history }

class SightingReviewState {
  const SightingReviewState({
    required this.owner,
    required this.detail,
    this.selected = '',
    this.reason = '',
    this.frozen,
    this.photo,
    this.work,
    this.failure,
    this.saved = false,
    this.conflicted = false,
    this.closed = false,
    this.notice = 0,
  });
  final String owner, selected, reason;
  final SightingReview detail;
  final ReviewCommand? frozen;
  final Uint8List? photo;
  final ReviewWork? work;
  final TimelineIssue? failure;
  final bool saved;
  final bool conflicted, closed;
  final int notice;
  bool get busy => work != null;
  bool get editable => !busy && frozen == null && detail.canReview && !closed;
  SightingReviewState copy({
    SightingReview? detail,
    String? selected,
    String? reason,
    ReviewCommand? frozen,
    bool clearFrozen = false,
    Uint8List? photo,
    ReviewWork? work,
    TimelineIssue? failure,
    bool saved = false,
    bool? conflicted,
    bool? closed,
  }) => SightingReviewState(
    owner: owner,
    detail: detail ?? this.detail,
    selected: selected ?? this.selected,
    reason: reason ?? this.reason,
    frozen: clearFrozen ? null : frozen ?? this.frozen,
    photo: photo ?? this.photo,
    work: work,
    failure: failure,
    saved: saved,
    conflicted: conflicted ?? this.conflicted,
    closed: closed ?? this.closed,
    notice: notice + (failure != null || saved ? 1 : 0),
  );
}

String timelineStateLabel(String state) => switch (state) {
  'useful' => 'Útil',
  'doubtful' => 'Dudoso',
  'rejected' => 'Rechazado',
  'confirmed' => 'Confirmado',
  _ => 'Sin revisar',
};
String timelineFailureLabel(TimelineIssue issue) => switch (issue) {
  TimelineIssue.forbidden => 'No tienes acceso a la cronología de este caso.',
  TimelineIssue.invalid =>
    'Selecciona una clasificación y escribe un motivo de hasta 500 caracteres.',
  TimelineIssue.transition =>
    'Elige una clasificación distinta de la revisión actual.',
  TimelineIssue.conflict =>
    'El avistamiento cambió. Actualiza y revisa la información antes de guardar.',
  TimelineIssue.closed =>
    'El caso está cerrado. Puedes consultar su historial, pero no añadir revisiones.',
  TimelineIssue.unavailable =>
    'No pudimos confirmar la operación. Conservamos los datos para reintentar.',
};
