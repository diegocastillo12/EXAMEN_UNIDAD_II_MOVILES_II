import '../../domain/entities/lost_case.dart';

class CaseListState {
  CaseListState({
    required this.ownerId,
    required List<PublishedLostCase> cases,
    this.busyId,
    this.notice,
    this.noticeId = 0,
    this.noticeIsError = false,
    this.refreshing = false,
    this.refreshFailed = false,
  }) : cases = List.unmodifiable(cases);
  final String ownerId;
  final String? busyId, notice;
  final int noticeId;
  final bool noticeIsError;
  final List<PublishedLostCase> cases;
  final bool refreshing, refreshFailed;
}

class PublicCaseState {
  const PublicCaseState({
    required this.ownerId,
    required this.value,
    this.cachedAt,
    this.storageFailed = false,
    this.refreshing = false,
    this.refreshFailed = false,
  });
  final DateTime? cachedAt;
  final bool storageFailed;
  final String? ownerId;
  final PublicLostCase? value;
  final bool refreshing, refreshFailed;
}
