import '../../domain/entities/saved_case_mark.dart';

class SavedCaseState {
  const SavedCaseState({
    required this.owner,
    required this.mark,
    this.busy = false,
    this.notice,
    this.noticeId = 0,
    this.error = false,
    this.reloadRequired = false,
  });
  final String owner;
  final SavedCaseMark mark;
  final bool busy, error, reloadRequired;
  final String? notice;
  final int noticeId;
}
