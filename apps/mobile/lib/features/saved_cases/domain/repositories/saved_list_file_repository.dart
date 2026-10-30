import '../../../../core/domain/entities/public_case_card.dart';

abstract interface class SavedListFileRepository {
  Future<void> save(String owner, List<PublicCaseCard> items);

  /// Null means that this account has not saved a list yet.
  Future<List<PublicCaseCard>?> read(String owner);
  Future<void> clearAll();
}
