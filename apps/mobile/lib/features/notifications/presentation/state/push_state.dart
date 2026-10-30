class PushState {
  const PushState({
    this.busy = false,
    this.notice,
    this.error = false,
    this.noticeId = 0,
    this.openId = 0,
  });
  final bool busy, error;
  final String? notice;
  final int noticeId, openId;
}
