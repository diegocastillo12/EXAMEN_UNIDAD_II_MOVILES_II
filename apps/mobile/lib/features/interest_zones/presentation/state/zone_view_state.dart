import '../../domain/entities/interest_zone.dart';
import '../../domain/failures/zone_failure.dart';

class ZoneViewState {
  ZoneViewState({
    required this.ownerId,
    required List<InterestZone> zones,
    this.draft,
    this.busy = false,
    this.busyZoneId,
    this.refreshing = false,
    this.issue,
    this.errorId = 0,
    this.confirmation,
    this.noticeId = 0,
  }) : zones = List.unmodifiable(zones);
  final String ownerId;
  final List<InterestZone> zones;
  final ZoneDraft? draft;
  final bool busy;
  final String? busyZoneId;
  final bool refreshing;
  final ZoneFailureKind? issue;
  final int errorId;
  final String? confirmation;
  final int noticeId;
  ZoneViewState copyWith({
    List<InterestZone>? zones,
    ZoneDraft? draft,
    bool clearDraft = false,
    bool? busy,
    String? busyZoneId,
    bool? refreshing,
    ZoneFailureKind? issue,
    bool clearIssue = false,
    int? errorId,
    String? confirmation,
    bool clearConfirmation = false,
    int? noticeId,
  }) => ZoneViewState(
    ownerId: ownerId,
    zones: zones ?? this.zones,
    draft: clearDraft ? null : draft ?? this.draft,
    busy: busy ?? this.busy,
    busyZoneId: busy == false ? null : busyZoneId ?? this.busyZoneId,
    refreshing: refreshing ?? this.refreshing,
    issue: clearIssue ? null : issue ?? this.issue,
    errorId: errorId ?? this.errorId,
    confirmation: clearConfirmation ? null : confirmation ?? this.confirmation,
    noticeId: noticeId ?? this.noticeId,
  );
}
