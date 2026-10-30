import 'dart:convert';
import '../../../../core/domain/entities/public_case_card.dart';
import '../../domain/repositories/saved_list_file_repository.dart';
import '../../domain/failures/saved_case_failure.dart';
import '../data_sources/saved_list_file_source.dart';
import '../models/saved_list_file_dto.dart';

class SavedListFileRepositoryImpl implements SavedListFileRepository {
  const SavedListFileRepositoryImpl(this.source);
  final SavedListFileSource source;
  @override
  Future<void> clearAll() async {
    try {
      await source.clearAll();
    } catch (_) {
      throw const SavedCaseFailure(SavedCaseFailureKind.unavailable);
    }
  }

  @override
  Future<void> save(String owner, List<PublicCaseCard> items) async {
    try {
      await source.write(
        owner,
        jsonEncode({
          'schema': 1,
          'owner': owner,
          'saved_at': DateTime.now().toUtc().toIso8601String(),
          'items': items.map(SavedListFileDto.encode).toList(),
        }),
      );
    } catch (_) {
      throw const SavedCaseFailure(SavedCaseFailureKind.unavailable);
    }
  }

  @override
  Future<List<PublicCaseCard>?> read(String owner) async {
    try {
      final contents = await source.read(owner);
      if (contents == null) return null;
      final row = jsonDecode(contents) as Map<String, dynamic>;
      if (row['schema'] != 1 || row['owner'] != owner) {
        throw const FormatException('Invalid offline list');
      }
      return (row['items'] as List)
          .map(
            (item) =>
                SavedListFileDto.decode(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      throw const SavedCaseFailure(SavedCaseFailureKind.unavailable);
    }
  }
}
