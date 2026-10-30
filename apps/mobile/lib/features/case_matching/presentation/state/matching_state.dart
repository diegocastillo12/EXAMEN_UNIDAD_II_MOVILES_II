import '../../domain/entities/case_match.dart';

class MatchingState {
  MatchingState({
    required this.owner,
    required List<MatchSearch> searches,
    this.selected,
    this.result,
    this.busy = false,
    this.issue,
    this.notice = 0,
    this.saved = 0,
  }) : searches = List.unmodifiable(searches);
  final String owner;
  final List<MatchSearch> searches;
  final MatchReference? selected;
  final CaseMatchResult? result;
  final bool busy;
  final MatchIssue? issue;
  final int notice, saved;
  MatchingState copyWith({
    MatchReference? selected,
    CaseMatchResult? result,
    bool? busy,
    MatchIssue? issue,
    bool clearIssue = false,
    bool clearResult = false,
    int? saved,
  }) => MatchingState(
    owner: owner,
    searches: searches,
    selected: selected ?? this.selected,
    result: clearResult ? null : result ?? this.result,
    busy: busy ?? this.busy,
    issue: clearIssue ? null : issue ?? this.issue,
    notice: issue == null ? notice : notice + 1,
    saved: saved ?? this.saved,
  );
}
