import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification.dart';
import '../../providers/notification_providers.dart';
import '../state/notification_state.dart';

final inboxViewModelProvider =
    AsyncNotifierProvider.autoDispose<InboxViewModel, InboxState>(
      InboxViewModel.new,
      retry: (_, _) => null,
    );

class InboxViewModel extends AsyncNotifier<InboxState> {
  int _generation = 0;
  bool _appendFailed = false;
  @override
  Future<InboxState> build() async {
    final generation = ++_generation;
    ref.onDispose(() => _generation++);
    final session = await ref.watch(notificationSessionProvider.future);
    if (session == null || !ref.mounted || generation != _generation) {
      throw const NotificationFailure(NotificationIssue.forbidden);
    }
    final page = await ref.read(listNotificationsProvider)(session.userId);
    return InboxState(
      owner: session.userId,
      items: page.items,
      cursor: page.cursor,
    );
  }

  Future<void> refresh() => _load(false);
  Future<void> more() => _load(true);
  Future<void> retry() => _load(_appendFailed);
  Future<void> _load(bool append) async {
    final old = state.isLoading ? null : state.asData?.value;
    if (old == null) {
      ref.invalidateSelf();
      return;
    }
    if (old.busy || (append && old.cursor == null)) return;
    final generation = ++_generation;
    _appendFailed = append;
    state = AsyncData(
      InboxState(
        owner: old.owner,
        items: old.items,
        cursor: old.cursor,
        busy: true,
        appending: append,
        noticeId: old.noticeId,
      ),
    );
    try {
      final page = await ref.read(listNotificationsProvider)(
        old.owner,
        append ? old.cursor : null,
      );
      if (!ref.mounted || generation != _generation) return;
      if (append && page.cursor == old.cursor) {
        throw const NotificationFailure(NotificationIssue.unavailable);
      }
      state = AsyncData(
        InboxState(
          owner: old.owner,
          items: append
              ? [
                  ...old.items,
                  ...page.items.where(
                    (n) => !old.items.any((e) => e.id == n.id),
                  ),
                ]
              : page.items,
          cursor: page.cursor,
          noticeId: old.noticeId,
        ),
      );
    } catch (e) {
      _failure(e, old, generation);
    }
  }

  Future<bool> markRead(InboxNotification notification) async {
    final old = state.isLoading ? null : state.asData?.value;
    if (old == null || old.busy) return false;
    final generation = ++_generation;
    state = AsyncData(
      InboxState(
        owner: old.owner,
        items: old.items,
        cursor: old.cursor,
        busy: true,
        noticeId: old.noticeId,
      ),
    );
    try {
      await ref.read(markNotificationReadProvider)(old.owner, notification.id);
      if (!ref.mounted || generation != _generation) return false;
      state = AsyncData(
        InboxState(
          owner: old.owner,
          items: old.items
              .map((e) => e.id == notification.id ? e.asRead() : e)
              .toList(),
          cursor: old.cursor,
          noticeId: old.noticeId,
        ),
      );
      return true;
    } catch (e) {
      _failure(e, old, generation);
      return false;
    }
  }

  void _failure(Object e, InboxState old, int generation) {
    if (!ref.mounted || generation != _generation) return;
    if (e is NotificationFailure && e.issue == NotificationIssue.forbidden) {
      state = AsyncError(e, StackTrace.current);
      return;
    }
    state = AsyncData(
      InboxState(
        owner: old.owner,
        items: old.items,
        cursor: old.cursor,
        failed: true,
        notice: 'No pudimos completar la consulta. Puedes reintentar.',
        noticeId: old.noticeId + 1,
      ),
    );
  }
}
