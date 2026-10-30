import '../../domain/failures/pet_failure.dart';

class PetDeletionState {
  const PetDeletionState({
    this.busyId,
    this.issueId,
    this.issue,
    this.confirmed = false,
    this.noticeId = 0,
  });
  final String? busyId;
  final String? issueId;
  final PetFailureKind? issue;
  final bool confirmed;
  final int noticeId;
}
