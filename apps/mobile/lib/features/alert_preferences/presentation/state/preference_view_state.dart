import '../../domain/entities/alert_preferences.dart';
import '../../domain/failures/preference_failure.dart';

class PreferenceViewState {
  const PreferenceViewState({
    required this.saved,
    required this.draft,
    this.saving = false,
    this.refreshing = false,
    this.issue,
    this.confirmed = false,
    this.noticeId = 0,
  });
  final AlertPreferences saved;
  final AlertPreferences draft;
  final bool saving;
  final bool refreshing;
  final PreferenceFailureKind? issue;
  final bool confirmed;
  final int noticeId;
  bool get dirty => !saved.sameChoices(draft);
  bool get busy => saving || refreshing;
  PreferenceViewState copyWith({
    AlertPreferences? saved,
    AlertPreferences? draft,
    bool? saving,
    bool? refreshing,
    PreferenceFailureKind? issue,
    bool clearIssue = false,
    bool? confirmed,
    int? noticeId,
  }) => PreferenceViewState(
    saved: saved ?? this.saved,
    draft: draft ?? this.draft,
    saving: saving ?? this.saving,
    refreshing: refreshing ?? this.refreshing,
    issue: clearIssue ? null : issue ?? this.issue,
    confirmed: confirmed ?? this.confirmed,
    noticeId: noticeId ?? this.noticeId,
  );
}
