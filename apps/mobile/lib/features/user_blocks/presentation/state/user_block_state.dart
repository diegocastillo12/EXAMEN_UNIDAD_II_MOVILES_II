import '../../domain/entities/user_block.dart';

class UserBlockState {
  const UserBlockState({
    required this.actor,
    this.items = const [],
    this.target,
    this.next,
    this.busy = false,
    this.refreshing = false,
    this.pending,
    this.issue,
    this.notice = 0,
    this.confirmed = false,
  });
  final String actor;
  final List<UserBlock> items;
  final UserBlock? target;
  final String? next;
  final bool busy, refreshing, confirmed;
  final BlockChange? pending;
  final BlockIssue? issue;
  final int notice;
  UserBlockState copy({
    List<UserBlock>? items,
    UserBlock? target,
    String? next,
    bool? busy,
    bool? refreshing,
    BlockChange? pending,
    BlockIssue? issue,
    bool confirmed = false,
    bool clearPending = false,
    bool replaceNext = false,
  }) => UserBlockState(
    actor: actor,
    items: items ?? this.items,
    target: target ?? this.target,
    next: replaceNext ? next : this.next,
    busy: busy ?? false,
    refreshing: refreshing ?? false,
    pending: clearPending ? null : pending ?? this.pending,
    issue: issue,
    notice: notice + 1,
    confirmed: confirmed,
  );
}
