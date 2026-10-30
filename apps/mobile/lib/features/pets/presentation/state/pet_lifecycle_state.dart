import '../../domain/failures/pet_failure.dart';

class PetLifecycleState {
  const PetLifecycleState({
    this.busy = false,
    this.confirmed = false,
    this.archived = false,
    this.noticeId = 0,
    this.issue,
  });
  final bool busy;
  final bool confirmed;
  final bool archived;
  final int noticeId;
  final PetFailureKind? issue;
}
