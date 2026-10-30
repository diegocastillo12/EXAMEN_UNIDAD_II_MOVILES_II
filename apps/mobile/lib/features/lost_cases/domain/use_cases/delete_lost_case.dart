import '../entities/lost_case.dart';
import '../repositories/lost_case_repository.dart';

class DeletePublishedLostCase {
  const DeletePublishedLostCase(this._repository);
  final LostCaseRepository _repository;
  Future<void> call(String owner, PublishedLostCase value) {
    if (value.ownerId != owner) {
      throw const CaseFailure(CaseFailureKind.forbidden);
    }
    if (!{'active', 'resolved'}.contains(value.status)) {
      throw const CaseFailure(CaseFailureKind.conflict);
    }
    return _repository.delete(owner, value.id);
  }
}
