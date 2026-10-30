import '../entities/saved_case_page.dart';
import '../failures/saved_case_failure.dart';
import '../repositories/saved_cases_repository.dart';

class ListSavedCases {
  const ListSavedCases(this._repository);
  final SavedCasesRepository _repository;
  Future<SavedCasePage> call(String owner, {String? cursor}) {
    if (owner.trim().isEmpty) {
      throw const SavedCaseFailure(SavedCaseFailureKind.forbidden);
    }
    if (cursor != null && cursor.length > 4096) {
      throw const SavedCaseFailure(SavedCaseFailureKind.invalid);
    }
    return _repository.list(owner, cursor: cursor);
  }
}
