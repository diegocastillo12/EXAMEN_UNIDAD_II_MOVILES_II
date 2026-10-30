import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/local_draft_providers.dart';
import '../../providers/submission_queue_providers.dart';

class SubmissionSyncState {
  const SubmissionSyncState({
    this.owner,
    this.busy = false,
    this.storageFailed = false,
  });
  final String? owner;
  final bool busy, storageFailed;
}

final submissionSyncViewModelProvider =
    NotifierProvider.autoDispose<SubmissionSyncViewModel, SubmissionSyncState>(
      SubmissionSyncViewModel.new,
    );

/// Foreground-only synchronization; timer availability is never proof of connectivity.
class SubmissionSyncViewModel extends Notifier<SubmissionSyncState> {
  Timer? _timer;
  bool _enabled = false;
  String? _allowedOwner;
  int _generation = 0;
  @override
  SubmissionSyncState build() {
    final generation = ++_generation;
    _timer?.cancel();
    final session = ref.watch(localDraftSessionProvider);
    final owner = session.isLoading || session.hasError
        ? null
        : session.asData?.value?.userId;
    ref.onDispose(() {
      _timer?.cancel();
    });
    if (_enabled && owner != null && owner == _allowedOwner) {
      _timer = Timer.periodic(
        const Duration(seconds: 15),
        (_) => unawaited(sync()),
      );
      scheduleMicrotask(() {
        if (ref.mounted && generation == _generation) unawaited(sync());
      });
    }
    return SubmissionSyncState(owner: owner);
  }

  /// Immediate lifecycle cleanup without notifying widgets being unmounted.
  void stop() {
    _enabled = false;
    _allowedOwner = null;
    _generation++;
    _timer?.cancel();
  }

  void setEnabled(bool enabled, {String? owner}) {
    final allowed = enabled ? owner ?? state.owner : null;
    if (_enabled == enabled && _allowedOwner == allowed) return;
    _allowedOwner = allowed;
    _enabled = enabled;
    _generation++;
    _timer?.cancel();
    state = SubmissionSyncState(
      owner: state.owner,
      storageFailed: state.storageFailed,
    );
    if (!enabled) return;
    _timer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => unawaited(sync()),
    );
    unawaited(sync());
  }

  Future<void> sync() async {
    final owner = state.owner;
    if (!_enabled || owner == null || owner != _allowedOwner || state.busy) {
      return;
    }
    final generation = _generation;
    bool current() =>
        ref.mounted &&
        _enabled &&
        generation == _generation &&
        state.owner == owner &&
        _allowedOwner == owner;
    state = SubmissionSyncState(owner: owner, busy: true);
    try {
      await ref
          .read(dispatchQueuedReportsProvider)
          .drain(owner, isCurrent: current);
      if (current()) state = SubmissionSyncState(owner: owner);
    } catch (_) {
      if (current()) {
        state = SubmissionSyncState(owner: owner, storageFailed: true);
      }
    } finally {
      // Resume may have interrupted the old generation while keeping the same owner.
      if (ref.mounted &&
          generation == _generation &&
          state.owner == owner &&
          state.busy) {
        state = SubmissionSyncState(
          owner: owner,
          storageFailed: state.storageFailed,
        );
      }
    }
  }
}
