import '../entities/saved_case_mark.dart';
import '../entities/saved_case_ref.dart';
import '../entities/saved_case_page.dart';

abstract interface class SavedCasesRepository {
  Future<SavedCasePage> list(String owner, {String? cursor});
  Future<SavedCaseMark> read(String owner, SavedCaseRef target);
  Future<SavedCaseMark> setSaved(
    String owner,
    SavedCaseRef target, {
    required bool saved,
    required int expectedVersion,
  });
}
