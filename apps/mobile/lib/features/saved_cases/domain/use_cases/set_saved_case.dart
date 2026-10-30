import '../entities/saved_case_mark.dart';
import '../entities/saved_case_ref.dart';
import '../failures/saved_case_failure.dart';
import '../repositories/saved_cases_repository.dart';

class SetSavedCase {
  const SetSavedCase(this._repository);
  final SavedCasesRepository _repository;
  Future<SavedCaseMark> call(
    String owner,
    SavedCaseRef target, {
    required bool saved,
    required int expectedVersion,
  }) {
    if (owner.trim().isEmpty) {
      throw const SavedCaseFailure(SavedCaseFailureKind.forbidden);
    }
    if (!target.valid || expectedVersion < 0 || expectedVersion >= 2147483647) {
      throw const SavedCaseFailure(SavedCaseFailureKind.invalid);
    }
    return _repository.setSaved(
      owner,
      target,
      saved: saved,
      expectedVersion: expectedVersion,
    );
  }
}
