import '../../domain/entities/moderation_appeal.dart';

class AppealsState {
  const AppealsState({
    required this.actor,
    required this.items,
    this.next,
    this.selected,
    this.reason = '',
    this.frozen,
    this.busy = false,
    this.issue,
    this.notice = 0,
    this.saved = false,
    this.refreshRequired = false,
    this.retrying = false,
  });
  final String actor, reason;
  final List<ModeratedDecision> items;
  final AppealCursor? next;
  final ModeratedDecision? selected;
  final AppealCommand? frozen;
  final bool busy, saved, refreshRequired, retrying;
  final AppealIssue? issue;
  final int notice;
  bool get dirty => reason.isNotEmpty || frozen != null;
  AppealsState copy({
    List<ModeratedDecision>? items,
    AppealCursor? next,
    bool clearNext = false,
    ModeratedDecision? selected,
    bool clearSelected = false,
    String? reason,
    AppealCommand? frozen,
    bool clearFrozen = false,
    bool busy = false,
    AppealIssue? issue,
    bool saved = false,
    bool? refreshRequired,
    bool? retrying,
  }) => AppealsState(
    actor: actor,
    items: items ?? this.items,
    next: clearNext ? null : next ?? this.next,
    selected: clearSelected ? null : selected ?? this.selected,
    reason: reason ?? this.reason,
    frozen: clearFrozen ? null : frozen ?? this.frozen,
    busy: busy,
    issue: issue,
    saved: saved,
    refreshRequired: refreshRequired ?? this.refreshRequired,
    retrying: retrying ?? this.retrying,
    notice: notice + 1,
  );
}
