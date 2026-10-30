import '../entities/saved_case_mark.dart';
import '../entities/saved_case_ref.dart';
import '../failures/saved_case_failure.dart';
import '../repositories/saved_cases_repository.dart';

class ReadSavedCase {
  const ReadSavedCase(this._repository);
  final SavedCasesRepository _repository;
  Future<SavedCaseMark> call(String owner, SavedCaseRef target) {
    if (owner.trim().isEmpty) {
      throw const SavedCaseFailure(SavedCaseFailureKind.forbidden);
    }
    if (!target.valid) {
      throw const SavedCaseFailure(SavedCaseFailureKind.invalid);
    }
    return _repository.read(owner, target);
  }
}
