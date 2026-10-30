import '../../../offline_drafts/domain/entities/local_report_draft.dart';
import '../../../offline_drafts/providers/submission_queue_providers.dart';
import '../../../offline_drafts/domain/entities/queued_report.dart';
import 'dart:async';
import '../../../offline_drafts/providers/local_draft_providers.dart';
import '../state/found_local_draft.dart';
import '../../../../core/presentation/state/event_date_time_draft.dart';
import 'recovery_case_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/utils/new_entity_id.dart';
import '../../domain/entities/found_case.dart';
import '../../providers/found_case_providers.dart';
import '../state/found_editor_state.dart';
import 'found_read_view_model.dart';

final foundEditorViewModelProvider =
    AsyncNotifierProvider.autoDispose<FoundEditorViewModel, FoundEditorState>(
      FoundEditorViewModel.new,
      dependencies: [foundEditorContextProvider],
      retry: (_, _) => null,
    );

class FoundEditorViewModel extends AsyncNotifier<FoundEditorState> {
  FoundEditorViewModel({Duration? operationTimeout})
    : _operationTimeout = operationTimeout ?? const Duration(seconds: 90);
  final Duration _operationTimeout;
  bool get communitySearch =>
      ref.read(foundEditorContextProvider).communitySearch;
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
          stage: FoundStage.confirmed,
          published: receipt.found,
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
  String _slot = "";
  Future<bool> discardLocalDraft(String expectedId) async {
    final value = state.asData?.value;
    if (value == null || value.draftId != expectedId || value.busy) {
      return false;
    }
    final generation = _generation;
    final remove = ref.read(removeLocalDraftProvider);
    final cancel = ref.read(cancelLocalSubmissionProvider);
    final slot = _slot;
    final keep = ref.keepAlive();
    state = AsyncData(value.copyWith(busy: true));
    try {
      await cancel(value.ownerId, value.draftId);
      if (!_current(generation, value.ownerId)) return false;
      if (value.attempted && !await _performDiscard(alreadyBusy: true)) {
        return false;
      }
      if (!_current(generation, value.ownerId)) return false;
      state = AsyncData(state.requireValue.copyWith(busy: true));
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
                ? FoundFailureKind.conflict
                : FoundFailureKind.localStorage,
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
        state.requireValue.issue == FoundFailureKind.localStorage) {
      state = AsyncData(state.requireValue.copyWith(clearIssue: true));
    }
    return saved;
  }

  Future<bool> _saveLocal(FoundEditorState value) async {
    if (!value.dirty && value.lockedDraft == null) return true;
    final generation = _generation;
    final slot = _slot;
    final save = ref.read(saveLocalDraftProvider);
    final keep = ref.keepAlive();
    try {
      await save(foundLocalDraft(value, slot));
      return true;
    } catch (_) {
      if (_current(generation, value.ownerId) &&
          foundCheckpointKey(state.requireValue) == foundCheckpointKey(value)) {
        state = AsyncData(
          state.requireValue.copyWith(issue: FoundFailureKind.localStorage),
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
      final key = foundCheckpointKey(value);
      if (_checkpointKey == key) return;
      _checkpointKey = key;
      if (value.stage == FoundStage.confirmed) {
        final remove = ref.read(removeLocalDraftProvider);
        unawaited(
          remove(value.ownerId, _slot, value.draftId).catchError((Object _) {
            // The receipt remains confirmed. An undeleted exact command is safe to replay.
          }),
        );
      } else {
        unawaited(_saveLocal(value));
      }
    });
  }

  @override
  Future<FoundEditorState> build() async {
    final generation = ++_generation;
    final session = await ref.watch(foundSessionProvider.future);
    if (!ref.mounted || generation != _generation) {
      throw const FoundFailure(FoundFailureKind.forbidden);
    }
    if (session == null) throw const FoundFailure(FoundFailureKind.forbidden);
    final context = ref.watch(foundEditorContextProvider);
    _slot = foundDraftSlot(context);
    _observeDraft();
    _observeQueue(session.userId);
    final local = await ref.read(readLocalDraftProvider)(session.userId, _slot);
    if (local != null) return restoreFoundLocalDraft(local, context);
    final target = context.communitySearch
        ? null
        : await ref.watch(readRecoverySearchProvider)(
            context.targetId ?? '',
            context.communityTarget,
          );
    final value = FoundEditorState(
      ownerId: session.userId,
      draftId: newEntityId(),
      communitySearch: context.communitySearch,
      reportKind: context.independentFound
          ? 'independent_found'
          : context.communitySearch
          ? 'possible_loss'
          : 'sighting',
      target: target,
    );
    return target == null
        ? value
        : value.copyWith(
            targetId: target.id,
            communityTarget: target.community,
            species: target.species,
            speciesDetail: target.speciesDetail,
            size: target.size,
            sex: target.sex,
          );
  }

  void retry() => ref.invalidateSelf();
  bool _current(int g, String owner) =>
      ref.mounted &&
      g == _generation &&
      !state.isLoading &&
      state.asData?.value.ownerId == owner;
  bool _editable(FoundEditorState? v) =>
      v != null &&
      !state.isLoading &&
      !v.busy &&
      !{
        SubmissionStatus.pending,
        SubmissionStatus.sending,
      }.contains(v.submissionStatus) &&
      v.lockedDraft == null &&
      v.issue != FoundFailureKind.targetClosed &&
      v.stage != FoundStage.confirmed;
  void chooseObservation(String kind) {
    final value = state.asData?.value;
    if (!_editable(value) ||
        value!.communitySearch ||
        !{'sighting', 'with_reporter'}.contains(kind)) {
      return;
    }
    state = AsyncData(
      value.copyWith(
        reportKind: kind,
        custody: kind == 'with_reporter' ? 'with_me' : 'not_with_me',
        dirty: true,
        clearIssue: true,
      ),
    );
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
    String? species,
    String? speciesDetail,
    String? size,
    String? sex,
    String? traits,
    String? custody,
    String? placeReference,
    DateTime? occurredAt,
    double? latitude,
    double? longitude,
  }) {
    final v = state.asData?.value;
    if (!_editable(v)) return;
    state = AsyncData(
      v!.copyWith(
        species: species,
        speciesDetail: species != null && species != 'other'
            ? ''
            : speciesDetail,
        size: size,
        sex: sex,
        traits: traits,
        custody: custody,
        placeReference: placeReference,
        occurredAt: occurredAt,
        latitude: latitude,
        longitude: longitude,
        dirty: true,
        clearIssue: true,
      ),
    );
  }

  Future<void> choosePhoto({bool camera = false, bool recover = false}) async {
    final v = state.asData?.value;
    if (!_editable(v) || v!.photos.length >= 3) return;
    final g = _generation;
    state = AsyncData(v.copyWith(busy: true, clearIssue: true));
    try {
      final action = ref.read(chooseFoundPhotoProvider);
      final bytes = recover
          ? await action.recover(v.ownerId, v.draftId)
          : await action(v.ownerId, v.draftId, camera: camera);
      if (!_current(g, v.ownerId)) return;
      state = AsyncData(
        state.requireValue.copyWith(
          busy: false,
          photos: bytes == null
              ? v.photos
              : [...v.photos, FoundPhotoDraft(newEntityId(), bytes)],
          dirty: v.dirty || bytes != null,
        ),
      );
    } catch (e) {
      if (_current(g, v.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            busy: false,
            issue: e is FoundFailure ? e.kind : FoundFailureKind.gallery,
          ),
        );
      }
    }
  }

  void removePhoto(String id) {
    final v = state.asData?.value;
    if (!_editable(v)) return;
    state = AsyncData(
      v!.copyWith(
        photos: v.photos.where((p) => p.id != id).toList(),
        dirty: true,
        clearIssue: true,
      ),
    );
  }

  FoundCaseDraft _draft(FoundEditorState v) => FoundCaseDraft(
    id: v.draftId,
    reportKind: v.reportKind,
    targetId: v.targetId,
    communityTarget: v.communityTarget,
    occurredAt: v.occurredAt ?? DateTime.utc(1999),
    latitude: v.latitude ?? double.nan,
    longitude: v.longitude ?? double.nan,
    placeReference: v.placeReference,
    species: v.species,
    speciesDetail: v.species == 'other' ? v.speciesDetail : null,
    size: v.size.isEmpty ? null : v.size,
    sex: v.sex.isEmpty ? null : v.sex,
    traits: v.traits,
    custody: v.custody.isEmpty ? null : v.custody,
    photos: v.photos,
  );
  void preview() {
    final v = state.asData?.value;
    if (!_editable(v)) return;
    try {
      ref.read(publishFoundCaseProvider).validate(_draft(v!), DateTime.now());
      state = AsyncData(
        v.copyWith(stage: FoundStage.preview, clearIssue: true),
      );
    } catch (e) {
      state = AsyncData(
        v!.copyWith(
          issue: e is FoundFailure ? e.kind : FoundFailureKind.invalid,
          invalidFields: e is FoundFailure ? e.fields : {},
        ),
      );
    }
  }

  void backToForm() {
    final v = state.asData?.value;
    if (!_editable(v)) return;
    state = AsyncData(v!.copyWith(stage: FoundStage.form, clearIssue: true));
  }

  Future<void> publish() async {
    final v = state.asData?.value;
    if (v == null ||
        state.isLoading ||
        v.busy ||
        v.issue == FoundFailureKind.targetClosed ||
        v.stage != FoundStage.preview) {
      return;
    }
    final g = _generation, keep = ref.keepAlive();
    final d = v.lockedDraft ?? _draft(v);
    state = AsyncData(
      v.copyWith(busy: true, lockedDraft: d, attempted: true, clearIssue: true),
    );
    try {
      if (!await _saveLocal(state.requireValue)) {
        if (_current(g, v.ownerId)) {
          state = AsyncData(state.requireValue.copyWith(busy: false));
        }
        return;
      }
      if (!_current(g, v.ownerId)) return;
      final result = await ref
          .read(dispatchQueuedReportsProvider)
          .send(
            foundLocalDraft(state.requireValue, _slot),
            isCurrent: () => _current(g, v.ownerId),
            resolveRejected: v.lockedDraft == null,
          )
          .timeout(
            _operationTimeout,
            onTimeout: () =>
                throw const FoundFailure(FoundFailureKind.timedOut),
          );
      if (!_current(g, v.ownerId)) return;
      final published = result.found!;
      state = AsyncData(
        state.requireValue.copyWith(
          busy: false,
          stage: FoundStage.confirmed,
          published: published,
          dirty: false,
          clearIssue: true,
        ),
      );
      ref.invalidate(myFoundCasesViewModelProvider);
      if (d.targetId != null) {
        ref.invalidate(
          recoveryCaseViewModelProvider((d.targetId!, d.communityTarget)),
        );
      }
    } catch (error) {
      final e = error is LocalDraftFailure
          ? const FoundFailure(FoundFailureKind.localStorage)
          : error is SubmissionFailure
          ? FoundFailure(
              error.issue == SubmissionIssue.conflict
                  ? FoundFailureKind.conflict
                  : FoundFailureKind.unavailable,
            )
          : error;
      if (_current(g, v.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            busy: false,
            issue: e is FoundFailure ? e.kind : FoundFailureKind.unavailable,
            clearLock:
                e is FoundFailure &&
                {
                  FoundFailureKind.invalid,
                  FoundFailureKind.photoInvalid,
                  FoundFailureKind.photos,
                  FoundFailureKind.draftLimit,
                  FoundFailureKind.targetClosed,
                  FoundFailureKind.blocked,
                }.contains(e.kind),
          ),
        );
      }
    } finally {
      keep.close();
    }
  }

  // The frozen request can only be released after the server confirms no active case exists.
  Future<bool> discard() => _performDiscard();

  Future<bool> _performDiscard({bool alreadyBusy = false}) async {
    final v = state.asData?.value;
    if (v == null ||
        (v.busy && !alreadyBusy) ||
        v.stage == FoundStage.confirmed) {
      return false;
    }
    if (!v.attempted) return true;
    final cancel = ref.read(cancelLocalSubmissionProvider);
    final g = _generation, keep = ref.keepAlive();
    state = AsyncData(v.copyWith(busy: true, clearIssue: true));
    try {
      await cancel(v.ownerId, v.draftId);
      if (!_current(g, v.ownerId)) return false;
      await ref
          .read(discardFoundDraftProvider)(v.ownerId, v.draftId)
          .timeout(
            _operationTimeout,
            onTimeout: () =>
                throw const FoundFailure(FoundFailureKind.timedOut),
          );
      if (!_current(g, v.ownerId)) return false;
      state = AsyncData(state.requireValue.copyWith(busy: false, dirty: false));
      ref.invalidate(myFoundCasesViewModelProvider);
      return true;
    } catch (e) {
      if (_current(g, v.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            busy: false,
            issue: e is SubmissionFailure
                ? FoundFailureKind.conflict
                : e is FoundFailure
                ? e.kind
                : FoundFailureKind.unavailable,
          ),
        );
      }
      return false;
    } finally {
      keep.close();
    }
  }
}
