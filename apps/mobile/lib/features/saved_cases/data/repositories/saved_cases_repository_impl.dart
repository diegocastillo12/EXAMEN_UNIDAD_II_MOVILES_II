import '../../domain/entities/saved_case_mark.dart';
import '../../domain/entities/saved_case_ref.dart';
import '../../domain/entities/saved_case_page.dart';
import '../../../../core/data/models/public_case_page_dto.dart';
import '../../domain/failures/saved_case_failure.dart';
import '../../domain/repositories/saved_cases_repository.dart';
import '../data_sources/saved_cases_data_source.dart';
import '../models/saved_case_mark_dto.dart';

class SavedCasesRepositoryImpl implements SavedCasesRepository {
  const SavedCasesRepositoryImpl(this._source);
  final SavedCasesDataSource _source;
  @override
  Future<SavedCasePage> list(String owner, {String? cursor}) async {
    try {
      final dto = await _source.list(owner, cursor);
      final items = await Future.wait(
        dto.items.map((row) async {
          final path = row['cover_path'] as String?;
          final cover = path == null
              ? null
              : await _source.cover(owner, row['source'] as String, path);
          return PublicCasePageDto.toEntity(row, cover);
        }),
      );
      return SavedCasePage(items: items, cursor: dto.nextCursor);
    } catch (_) {
      throw const SavedCaseFailure(SavedCaseFailureKind.unavailable);
    }
  }

  Future<SavedCaseMark> _map(Future<SavedCaseMarkDto> Function() action) async {
    try {
      return (await action()).toEntity();
    } on SavedCaseSourceFailure catch (error) {
      throw SavedCaseFailure(switch (error.kind) {
        SavedCaseSourceIssue.forbidden => SavedCaseFailureKind.forbidden,
        SavedCaseSourceIssue.conflict => SavedCaseFailureKind.conflict,
        SavedCaseSourceIssue.hidden => SavedCaseFailureKind.hidden,
        SavedCaseSourceIssue.unavailable => SavedCaseFailureKind.unavailable,
      });
    } catch (_) {
      throw const SavedCaseFailure(SavedCaseFailureKind.unavailable);
    }
  }

  @override
  Future<SavedCaseMark> read(String owner, SavedCaseRef target) =>
      _map(() => _source.read(owner, target.source.name, target.id));
  @override
  Future<SavedCaseMark> setSaved(
    String owner,
    SavedCaseRef target, {
    required bool saved,
    required int expectedVersion,
  }) => _map(
    () => _source.setSaved(
      owner,
      target.source.name,
      target.id,
      saved: saved,
      expectedVersion: expectedVersion,
    ),
  );
}
