import '../../../../core/domain/entities/public_case_card.dart';

class SavedCaseListState {
  SavedCaseListState({
    required this.owner,
    required List<PublicCaseCard> items,
    this.cursor,
    this.refreshing = false,
    this.appending = false,
    this.failed = false,
    this.notice,
    this.noticeId = 0,
    this.offline = false,
    this.localUnavailable = false,
    this.saving = false,
    this.noticeIsError = true,
  }) : items = List.unmodifiable(items);
  final String owner;
  final bool offline, localUnavailable;
  final bool saving, noticeIsError;
  final List<PublicCaseCard> items;
  final String? cursor, notice;
  final bool refreshing, appending, failed;
  final int noticeId;
  bool get busy => refreshing || appending || saving;

  SavedCaseListState savingNotice({
    required bool saving,
    String? notice,
    bool noticeIsError = true,
  }) => SavedCaseListState(
    owner: owner,
    items: items,
    cursor: cursor,
    refreshing: refreshing,
    appending: appending,
    failed: failed,
    offline: offline,
    localUnavailable: localUnavailable,
    saving: saving,
    notice: notice,
    noticeId: notice == null ? noticeId : noticeId + 1,
    noticeIsError: noticeIsError,
  );
}
