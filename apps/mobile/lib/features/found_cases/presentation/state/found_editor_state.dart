import '../../../offline_drafts/domain/entities/queued_report.dart';
import '../../../../core/presentation/state/event_date_time_draft.dart';
import '../../../../core/domain/use_cases/approximate_case_location.dart';
import '../../domain/entities/found_case.dart';

enum FoundStage { form, preview, confirmed }

class FoundEditorState {
  FoundEditorState({
    required this.ownerId,
    this.communitySearch = true,
    this.reportKind = 'possible_loss',
    this.targetId,
    this.communityTarget = false,
    this.target,
    required this.draftId,
    this.species = '',
    this.speciesDetail = '',
    this.size = '',
    this.sex = '',
    this.traits = '',
    this.custody = '',
    this.placeReference = '',
    DateTime? occurredAt,
    EventDateTimeDraft? dateTimeDraft,
    this.latitude,
    this.longitude,
    List<FoundPhotoDraft> photos = const [],
    this.busy = false,
    this.dirty = false,
    this.submissionStatus,
    this.issue,
    this.errorId = 0,
    Set<FoundField> invalidFields = const {},
    this.stage = FoundStage.form,
    this.lockedDraft,
    this.published,
    this.attempted = false,
  }) : dateTimeDraft = dateTimeDraft ?? EventDateTimeDraft.from(occurredAt),
       photos = List.unmodifiable(photos),
       invalidFields = Set.unmodifiable(invalidFields);
  final SubmissionStatus? submissionStatus;
  final bool communitySearch, communityTarget;
  final String reportKind;
  final String? targetId;
  final RecoverySearch? target;
  final String ownerId,
      draftId,
      species,
      speciesDetail,
      size,
      sex,
      traits,
      custody,
      placeReference;
  final EventDateTimeDraft dateTimeDraft;
  DateTime? get occurredAt => dateTimeDraft.value;
  final double? latitude, longitude;
  final List<FoundPhotoDraft> photos;
  final bool busy, dirty, attempted;
  final FoundFailureKind? issue;
  final int errorId;
  final Set<FoundField> invalidFields;
  final FoundStage stage;
  final FoundCaseDraft? lockedDraft;
  final FoundPublication? published;
  PublicFoundCase get preview {
    final location = approximateCaseLocation(latitude!, longitude!);
    return PublicFoundCase(
      id: draftId,
      reportKind: reportKind,
      targetId: targetId,
      communityTarget: communityTarget,
      status: 'active',
      occurredAt: occurredAt!,
      latitude: location.latitude,
      longitude: location.longitude,
      species: species,
      speciesDetail: species == 'other' ? speciesDetail : null,
      size: size.isEmpty ? null : size,
      sex: sex.isEmpty ? null : sex,
      traits: traits,
      custody: custody.isEmpty ? null : custody,
      photos: photos.map((p) => FoundPhoto(p.id, null)).toList(),
    );
  }

  FoundEditorState copyWith({
    bool clearSubmissionStatus = false,
    SubmissionStatus? submissionStatus,
    bool clearPoint = false,
    bool clearTarget = false,
    String? reportKind,
    String? targetId,
    bool? communityTarget,
    String? draftId,
    String? species,
    String? speciesDetail,
    String? size,
    String? sex,
    String? traits,
    String? custody,
    String? placeReference,
    DateTime? occurredAt,
    EventDateTimeDraft? dateTimeDraft,
    double? latitude,
    double? longitude,
    List<FoundPhotoDraft>? photos,
    bool? busy,
    bool? dirty,
    FoundFailureKind? issue,
    Set<FoundField>? invalidFields,
    FoundStage? stage,
    FoundCaseDraft? lockedDraft,
    FoundPublication? published,
    bool clearIssue = false,
    bool clearLock = false,
    bool? attempted,
  }) => FoundEditorState(
    submissionStatus: clearSubmissionStatus
        ? null
        : submissionStatus ?? this.submissionStatus,
    ownerId: ownerId,
    communitySearch: communitySearch,
    target: target,
    reportKind: reportKind ?? this.reportKind,
    targetId: clearTarget ? null : targetId ?? this.targetId,
    communityTarget: communityTarget ?? this.communityTarget,
    draftId: draftId ?? this.draftId,
    species: species ?? this.species,
    speciesDetail: speciesDetail ?? this.speciesDetail,
    size: size ?? this.size,
    sex: sex ?? this.sex,
    traits: traits ?? this.traits,
    custody: custody ?? this.custody,
    placeReference: placeReference ?? this.placeReference,
    dateTimeDraft:
        dateTimeDraft ??
        (occurredAt == null
            ? this.dateTimeDraft
            : EventDateTimeDraft.from(occurredAt)),
    latitude: clearPoint ? null : latitude ?? this.latitude,
    longitude: clearPoint ? null : longitude ?? this.longitude,
    photos: photos ?? this.photos,
    busy: busy ?? this.busy,
    dirty: dirty ?? this.dirty,
    issue: clearIssue ? null : issue ?? this.issue,
    errorId: issue != null ? errorId + 1 : errorId,
    invalidFields: invalidFields ?? (clearIssue ? {} : this.invalidFields),
    stage: stage ?? this.stage,
    lockedDraft: clearLock ? null : lockedDraft ?? this.lockedDraft,
    published: published ?? this.published,
    attempted: attempted ?? this.attempted,
  );
}

String foundFailureLabel(FoundFailureKind? kind) => switch (kind) {
  FoundFailureKind.blocked =>
    'Un bloqueo entre estas cuentas impide enviar nuevos avisos. Puedes revisar tus cuentas bloqueadas desde Perfil.',
  FoundFailureKind.targetClosed =>
    'Esta búsqueda ya no admite avisos. Puedes volver a su ficha; conservamos lo escrito hasta que salgas.',
  FoundFailureKind.localStorage =>
    'No pudimos guardar el borrador en este dispositivo. Libera espacio y reintenta antes de salir.',
  FoundFailureKind.timedOut =>
    'La operación no respondió. Reintenta el mismo envío o consulta Mis búsquedas y avisos.',
  FoundFailureKind.invalid => 'Revisa los campos marcados antes de continuar.',
  FoundFailureKind.photos =>
    'Las fotos aún no están verificadas. Reintenta el mismo envío.',
  FoundFailureKind.photoInvalid =>
    'No pudimos procesar la foto. Usa una imagen válida de menor tamaño.',
  FoundFailureKind.gallery =>
    'No pudimos abrir las fotos. Revisa el acceso y vuelve a intentar.',
  FoundFailureKind.forbidden =>
    'No pudimos autorizar el reporte. Revisa tu sesión.',
  FoundFailureKind.conflict =>
    'El envío cambió o ya fue publicado. Consulta tus reportes antes de volver a enviar.',
  FoundFailureKind.draftLimit =>
    'Tienes varios envíos pendientes. Descártalos desde Mis búsquedas y avisos antes de continuar.',
  _ =>
    'No pudimos confirmar la operación. Conservamos los datos para reintentar.',
};
