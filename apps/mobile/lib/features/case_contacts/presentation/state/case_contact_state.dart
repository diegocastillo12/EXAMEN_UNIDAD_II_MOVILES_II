import '../../domain/entities/case_contact.dart';

class CaseContactState {
  const CaseContactState({
    required this.owner,
    required this.access,
    this.busy = false,
    this.pending,
    this.issue,
    this.notice = 0,
    this.confirmed = false,
  });
  final String owner;
  final CaseContactAccess access;
  final bool busy, confirmed;
  final CaseContactDraft? pending;
  final CaseContactFailureKind? issue;
  final int notice;
}
