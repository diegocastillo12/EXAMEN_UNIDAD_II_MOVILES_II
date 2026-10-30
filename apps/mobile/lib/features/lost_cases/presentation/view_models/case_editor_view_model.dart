import '../../../offline_drafts/domain/entities/local_report_draft.dart';
import '../../../offline_drafts/providers/submission_queue_providers.dart';
import '../../../offline_drafts/domain/entities/queued_report.dart';
import 'dart:async';
import '../../../offline_drafts/providers/local_draft_providers.dart';
import '../state/case_local_draft.dart';
import '../../../../core/presentation/state/event_date_time_draft.dart';
import '../../../../core/domain/utils/new_entity_id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/use_cases/publish_lost_case.dart';
import '../../../pets/providers/pet_providers.dart';
import '../../domain/entities/lost_case.dart';
import '../../providers/lost_case_providers.dart';
import '../state/case_editor_state.dart';
import 'case_read_view_model.dart';

final caseEditorViewModelProvider =
    AsyncNotifierProvider.autoDispose<CaseEditorViewModel, CaseEditorState>(
      CaseEditorViewModel.new,
      retry: (_, _) => null,
    );

class CaseEditorViewModel extends AsyncNotifier<CaseEditorState> {
  CaseEditorViewModel({Duration? publicationTimeout})
    : _publicationTimeout = publicationTimeout;
  final Duration? _publicationTimeout;
  Duration get publicationTimeout =>
      _publicationTimeout ?? const Duration(seconds: 35);
  int _generation = 0;
  List<QueuedReport> _queueSnapshot = const [];
  void _observeQueue(String owner) {
    _queueSnapshot = const [];
    final generation = _generation;
    ref.listen(queuedReportsProvider(owner), (previous, next) {
      if (generation != _generation || next.isLoading || next.hasError) return;
      _queueSnapshot = next.asData?.value ?? const [];
      _applyQueue(generation, owner);
    });
  }

  void _applyQueue(int generation, String owner) {
    if (!_current(generation, owner)) return;
    final v = state.requireValue;
    if (v.busy || v.published != null) return;
    final entry = _queueSnapshot
        .where((e) => e.command.id == v.draftId)
        .firstOrNull;
    if (entry == null) {
      if (v.submissionStatus != null) {
        state = AsyncData(v.copyWith(clearSubmissionStatus: true));
      }
      return;
    }
    final receipt = entry.receipt;
    if (receipt != null) {
      state = AsyncData(
        v.copyWith(
          stage: CaseEditorStage.confirmed,
          published: receipt.lost,
          dirty: false,
          busy: false,
          submissionStatus: entry.status,
          clearIssue: true,
        ),
      );
    } else if (v.submissionStatus != entry.status) {
      state = AsyncData(v.copyWith(submissionStatus: entry.status));
    }
  }

  Object? _checkpointKey;
  void Function()? _stopObserving;

  Future<bool> discardLocalDraft(String expectedId) async {
    final value = state.asData?.value;
    if (value == null ||
        value.draftId != expectedId ||
        value.busy ||
        value.lockedDraft != null) {
      return false;
    }
    final generation = _generation;
    final remove = ref.read(removeLocalDraftProvider);
    final cancel = ref.read(cancelLocalSubmissionProvider);
    final slot = 'lost';
    final keep = ref.keepAlive();
    state = AsyncData(value.copyWith(busy: true));
    try {
      await cancel(value.ownerId, value.draftId);
      if (!_current(generation, value.ownerId)) return false;
      await remove(value.ownerId, slot, value.draftId);
      if (!_current(generation, value.ownerId)) return false;
      ref.invalidateSelf();
      return true;
    } catch (error) {
      if (_current(generation, value.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            busy: false,
            issue: error is SubmissionFailure
                ? CaseFailureKind.conflict
                : CaseFailureKind.localStorage,
          ),
        );
      }
      return false;
    } finally {
      keep.close();
    }
  }

  Future<bool> saveForLater() async {
    final value = state.asData?.value;
    if (value == null || state.isLoading) return false;
    final generation = _generation;
    final saved = await _saveLocal(value);
    if (saved &&
        _current(generation, value.ownerId) &&
        state.requireValue.issue == CaseFailureKind.localStorage) {
      state = AsyncData(state.requireValue.copyWith(clearIssue: true));
    }
    return saved;
  }

  Future<bool> _saveLocal(CaseEditorState value) async {
    if (!value.dirty && value.lockedDraft == null) return true;
    final generation = _generation;
    final save = ref.read(saveLocalDraftProvider);
    final keep = ref.keepAlive();
    try {
      await save(caseLocalDraft(value));
      return true;
    } catch (_) {
      if (_current(generation, value.ownerId) &&
          caseCheckpointKey(state.requireValue) == caseCheckpointKey(value)) {
        state = AsyncData(
          state.requireValue.copyWith(issue: CaseFailureKind.localStorage),
        );
      }
      return false;
    } finally {
      keep.close();
    }
  }

  void _observeDraft() {
    _checkpointKey = null;
    _stopObserving?.call();
    final generation = _generation;
    _stopObserving = listenSelf((previous, next) {
      if (generation != _generation) return;
      scheduleMicrotask(() {
        if (ref.mounted) {
          _applyQueue(generation, next.asData?.value.ownerId ?? '');
        }
      });
      final value = next.asData?.value;
      if (next.isLoading || value == null) return;
      final key = caseCheckpointKey(value);
      if (_checkpointKey == key) return;
      _checkpointKey = key;
      if (value.stage == CaseEditorStage.confirmed) {
        final remove = ref.read(removeLocalDraftProvider);
        unawaited(
          remove(value.ownerId, 'lost', value.draftId).catchError((Object _) {
            // The receipt remains confirmed. An undeleted exact command is safe to replay.
          }),
        );
      } else {
        unawaited(_saveLocal(value));
      }
    });
  }

  @override
  Future<CaseEditorState> build() async {
    final generation = ++_generation;
    final session = await ref.watch(caseSessionProvider.future);
    if (!ref.mounted || generation != _generation) {
      throw const CaseFailure(CaseFailureKind.forbidden);
    }
    if (session == null) throw const CaseFailure(CaseFailureKind.forbidden);
    _observeDraft();
    _observeQueue(session.userId);
    final local = await ref.read(readLocalDraftProvider)(
      session.userId,
      'lost',
    );
    if (local != null) return restoreCaseLocalDraft(local);
    final pets = await ref.read(listMyPetsProvider)(session.userId);
    return CaseEditorState(
      ownerId: session.userId,
      draftId: newEntityId(),
      pets: pets.where((p) => !p.isArchived).toList(),
    );
  }

  void retry() => ref.invalidateSelf();
  bool _current(int generation, String owner) =>
      ref.mounted &&
      generation == _generation &&
      !state.isLoading &&
      state.asData?.value.ownerId == owner;
  bool _editable(CaseEditorState? value) =>
      value != null &&
      !state.isLoading &&
      !value.busy &&
      !{
        SubmissionStatus.pending,
        SubmissionStatus.sending,
      }.contains(value.submissionStatus) &&
      !value.loadingPhotos &&
      value.lockedDraft == null &&
      value.stage != CaseEditorStage.confirmed;
  Future<void> selectPet(String id) async {
    final current = state.asData?.value;
    if (!_editable(current)) return;
    final pet = current!.pets.where((p) => p.id == id).firstOrNull;
    if (pet == null) return;
    final generation = _generation;
    state = AsyncData(
      current.copyWith(
        pet: pet,
        photos: [],
        selectedPhotos: {},
        loadingPhotos: true,
        dirty: true,
        clearIssue: true,
      ),
    );
    try {
      final updatedPet = await ref.read(readPetProvider)(current.ownerId, id);
      final photos = await ref
          .read(managePetPhotosProvider)
          .list(current.ownerId, id);
      if (!_current(generation, current.ownerId)) return;
      state = AsyncData(
        state.requireValue.copyWith(
          pet: updatedPet,
          photos: photos.where((p) => p.ready).toList(),
          loadingPhotos: false,
        ),
      );
    } catch (_) {
      if (_current(generation, current.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            loadingPhotos: false,
            issue: CaseFailureKind.unavailable,
          ),
        );
      }
    }
  }

  /// Restores report fields without changing animal data or photos.
  void restoreReportDetails({
    required String ownerId,
    required EventDateTimeDraft dateTime,
    required double? latitude,
    required double? longitude,
    required String placeReference,
  }) {
    final current = state.asData?.value;
    if (!_editable(current) || current!.ownerId != ownerId) return;
    final hasDetails =
        dateTime.date != null ||
        dateTime.hour != null ||
        latitude != null ||
        longitude != null ||
        placeReference.isNotEmpty;
    state = AsyncData(
      current.copyWith(
        dateTimeDraft: dateTime,
        latitude: latitude,
        longitude: longitude,
        clearPoint: latitude == null && longitude == null,
        placeReference: placeReference,
        dirty: current.dirty || hasDetails,
        clearIssue: true,
      ),
    );
  }

  void chooseDate(DateTime date) {
    final current = state.asData?.value;
    if (!_editable(current)) return;
    state = AsyncData(
      current!.copyWith(
        dateTimeDraft: current.dateTimeDraft.withDate(date),
        dirty: true,
        clearIssue: true,
      ),
    );
  }

  void chooseTime(int hour, int minute) {
    final current = state.asData?.value;
    if (!_editable(current)) return;
    state = AsyncData(
      current!.copyWith(
        dateTimeDraft: current.dateTimeDraft.withTime(hour, minute),
        dirty: true,
        clearIssue: true,
      ),
    );
  }

  void edit({
    DateTime? occurredAt,
    double? latitude,
    double? longitude,
    String? placeReference,
  }) {
    final current = state.asData?.value;
    if (!_editable(current)) return;
    state = AsyncData(
      current!.copyWith(
        occurredAt: occurredAt,
        latitude: latitude,
        longitude: longitude,
        placeReference: placeReference,
        dirty: true,
        clearIssue: true,
      ),
    );
  }

  void togglePhoto(String id) {
    final current = state.asData?.value;
    if (!_editable(current) || !current!.photos.any((p) => p.id == id)) return;
    final selected = {...current.selectedPhotos};
    if (!selected.remove(id)) selected.add(id);
    state = AsyncData(
      current.copyWith(selectedPhotos: selected, dirty: true, clearIssue: true),
    );
  }

  LostCaseDraft _draft(CaseEditorState current) {
    return LostCaseDraft(
      id: current.draftId,
      petId: current.pet?.id ?? '',
      petVersion: current.pet?.version ?? 0,
      occurredAt: current.occurredAt ?? DateTime.utc(1999),
      latitude: current.latitude ?? double.nan,
      longitude: current.longitude ?? double.nan,
      placeReference: current.placeReference,
      photoIds: current.selectedPhotos.toList(),
    );
  }

  void preview() {
    final current = state.asData?.value;
    if (!_editable(current)) return;
    try {
      validateLostCasePet(current!.pet);
      final draft = _draft(current);
      ref.read(publishLostCaseProvider).validate(draft, DateTime.now());
      state = AsyncData(
        current.copyWith(stage: CaseEditorStage.preview, clearIssue: true),
      );
    } catch (e) {
      state = AsyncData(
        current!.copyWith(
          issue: e is CaseFailure ? e.kind : CaseFailureKind.invalid,
          invalidFields: e is CaseFailure ? e.fields : {},
        ),
      );
    }
  }

  void backToForm() {
    final current = state.asData?.value;
    if (!_editable(current)) return;
    state = AsyncData(
      current!.copyWith(stage: CaseEditorStage.form, clearIssue: true),
    );
  }

  Future<void> publish() async {
    final current = state.asData?.value;
    if (current == null ||
        state.isLoading ||
        current.busy ||
        current.stage != CaseEditorStage.preview) {
      return;
    }
    final generation = _generation;
    final keep = ref.keepAlive();
    try {
      final draft = current.lockedDraft ?? _draft(current);
      state = AsyncData(
        current.copyWith(busy: true, lockedDraft: draft, clearIssue: true),
      );
      if (!await _saveLocal(state.requireValue)) {
        if (_current(generation, current.ownerId)) {
          state = AsyncData(state.requireValue.copyWith(busy: false));
        }
        return;
      }
      if (!_current(generation, current.ownerId)) return;
      final result = await ref
          .read(dispatchQueuedReportsProvider)
          .send(
            caseLocalDraft(state.requireValue),
            isCurrent: () => _current(generation, current.ownerId),
            resolveRejected: current.lockedDraft == null,
          )
          .timeout(
            publicationTimeout,
            onTimeout: () => throw const CaseFailure(CaseFailureKind.timedOut),
          );
      if (!_current(generation, current.ownerId)) return;
      final published = result.lost!;
      state = AsyncData(
        state.requireValue.copyWith(
          busy: false,
          published: published,
          stage: CaseEditorStage.confirmed,
          dirty: false,
          clearIssue: true,
        ),
      );
      ref.read(notifyPetChangedProvider)(current.ownerId, draft.petId);
      ref.invalidate(myCasesViewModelProvider);
    } catch (error) {
      final e = error is LocalDraftFailure
          ? const CaseFailure(CaseFailureKind.localStorage)
          : error is SubmissionFailure
          ? CaseFailure(
              error.issue == SubmissionIssue.conflict
                  ? CaseFailureKind.conflict
                  : CaseFailureKind.unavailable,
            )
          : error;
      if (_current(generation, current.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            busy: false,
            clearLockedDraft:
                e is CaseFailure &&
                e.kind != CaseFailureKind.unavailable &&
                e.kind != CaseFailureKind.timedOut,
            issue: e is CaseFailure ? e.kind : CaseFailureKind.unavailable,
            invalidFields: e is CaseFailure ? e.fields : {},
          ),
        );
      }
    } finally {
      keep.close();
    }
  }
}
