import '../models/saved_case_mark_dto.dart';
import '../../../../core/data/models/public_case_page_dto.dart';

enum SavedCaseSourceIssue { forbidden, unavailable, conflict, hidden }

class SavedCaseSourceFailure implements Exception {
  const SavedCaseSourceFailure(this.kind);
  final SavedCaseSourceIssue kind;
}

abstract interface class SavedCasesDataSource {
  Future<PublicCasePageDto> list(String owner, String? cursor);
  Future<Uri> cover(String owner, String source, String path);
  Future<SavedCaseMarkDto> read(String owner, String source, String id);
  Future<SavedCaseMarkDto> setSaved(
    String owner,
    String source,
    String id, {
    required bool saved,
    required int expectedVersion,
  });
}
