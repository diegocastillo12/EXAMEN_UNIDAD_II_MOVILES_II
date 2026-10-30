import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/utils/new_entity_id.dart';
import '../../domain/entities/notification.dart';
import '../../providers/notification_providers.dart';
import '../state/notification_state.dart';

final followingViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<FollowingViewModel, FollowingState, AlertTarget>(
      FollowingViewModel.new,
      retry: (_, _) => null,
    );

class FollowingViewModel extends AsyncNotifier<FollowingState> {
  FollowingViewModel(this.target);
  final AlertTarget target;
  int _generation = 0;
  ({String command, bool following, int version})? _pending;
  @override
  Future<FollowingState> build() async {
    final generation = ++_generation;
    _pending = null;
    ref.onDispose(() => _generation++);
    final session = await ref.watch(notificationSessionProvider.future);
    if (session == null || !ref.mounted || generation != _generation) {
      throw const NotificationFailure(NotificationIssue.forbidden);
    }
    final subscription = await ref.read(readAlertSubscriptionProvider)(
      session.userId,
      target,
    );
    return FollowingState(owner: session.userId, subscription: subscription);
  }

  void retry() => ref.invalidateSelf();
  Future<void> toggle() async {
    final old = state.isLoading ? null : state.asData?.value;
    if (old == null || old.busy) return;
    if (old.reload) {
      retry();
      return;
    }
    final pending =
        _pending ??
        (
          command: newEntityId(),
          following: !old.subscription.following,
          version: old.subscription.version,
        );
    _pending = pending;
    final generation = ++_generation;
    state = AsyncData(
      FollowingState(
        owner: old.owner,
        subscription: old.subscription,
        busy: true,
        noticeId: old.noticeId,
      ),
    );
    try {
      final receipt = await ref.read(followAlertTargetProvider)(
        old.owner,
        target,
        pending.command,
        pending.following,
        pending.version,
      );
      if (!ref.mounted || generation != _generation) return;
      _pending = null;
      state = AsyncData(
        FollowingState(
          owner: old.owner,
          subscription: receipt,
          noticeId: old.noticeId + 1,
          notice: receipt.following
              ? 'Seguimiento activado según tus preferencias'
              : 'Seguimiento desactivado',
        ),
      );
    } catch (e) {
      if (!ref.mounted || generation != _generation) return;
      final issue = e is NotificationFailure
          ? e.issue
          : NotificationIssue.unavailable;
      if (issue == NotificationIssue.forbidden) {
        _pending = null;
        state = AsyncError(e, StackTrace.current);
        return;
      }
      final reload = issue != NotificationIssue.unavailable;
      if (reload) _pending = null;
      state = AsyncData(
        FollowingState(
          owner: old.owner,
          subscription: old.subscription,
          failed: true,
          reload: reload,
          noticeId: old.noticeId + 1,
          notice: reload
              ? 'El seguimiento cambió. Consulta de nuevo antes de continuar.'
              : 'No pudimos confirmar el cambio. Reintenta la misma acción.',
        ),
      );
    }
  }
}
