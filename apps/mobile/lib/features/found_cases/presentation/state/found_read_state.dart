import '../../domain/entities/found_case.dart';

class FoundListState {
  FoundListState({
    required this.ownerId,
    required List<FoundPublication> cases,
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
  final List<FoundPublication> cases;
  final bool refreshing, refreshFailed;
}

class PublicFoundState {
  const PublicFoundState({
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
  final PublicFoundCase? value;
  final bool refreshing, refreshFailed;
}
