import '../../domain/entities/case_share.dart';

class CaseShareState {
  const CaseShareState({
    required this.actor,
    this.action,
    this.notice,
    this.noticeId = 0,
    this.isError = false,
  });
  final String actor;
  final CaseShareChannel? action;
  final String? notice;
  final int noticeId;
  final bool isError;
  bool get busy => action != null;
}
