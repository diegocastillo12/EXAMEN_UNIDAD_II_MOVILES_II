import '../../domain/entities/notification.dart';

class FollowingState {
  const FollowingState({
    required this.owner,
    required this.subscription,
    this.busy = false,
    this.reload = false,
    this.notice,
    this.noticeId = 0,
    this.failed = false,
  });
  final String owner;
  final AlertSubscription subscription;
  final bool busy, reload, failed;
  final String? notice;
  final int noticeId;
}

class InboxState {
  InboxState({
    required this.owner,
    required List<InboxNotification> items,
    this.cursor,
    this.busy = false,
    this.appending = false,
    this.notice,
    this.noticeId = 0,
    this.failed = false,
  }) : items = List.unmodifiable(items);
  final String owner;
  final List<InboxNotification> items;
  final String? cursor, notice;
  final bool busy, appending, failed;
  final int noticeId;
}
