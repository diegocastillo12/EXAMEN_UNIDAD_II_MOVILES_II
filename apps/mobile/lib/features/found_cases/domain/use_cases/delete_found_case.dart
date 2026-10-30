import '../entities/found_case.dart';
import '../repositories/found_case_repository.dart';

class DeleteFoundPublication {
  const DeleteFoundPublication(this._repository);
  final FoundCaseRepository _repository;
  Future<void> call(String owner, FoundPublication value) {
    if (value.ownerId != owner) {
      throw const FoundFailure(FoundFailureKind.forbidden);
    }
    if (!{'active', 'resolved'}.contains(value.status)) {
      throw const FoundFailure(FoundFailureKind.conflict);
    }
    return _repository.delete(owner, value.id);
  }
}
