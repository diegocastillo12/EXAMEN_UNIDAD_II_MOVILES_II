import '../../../../core/domain/entities/public_case_card.dart';
import '../failures/saved_case_failure.dart';
import '../repositories/saved_list_file_repository.dart';

class SaveListOffline {
  const SaveListOffline(this.repository);
  final SavedListFileRepository repository;
  Future<void> call(String owner, List<PublicCaseCard> items) {
    if (owner.trim().isEmpty || items.isEmpty) {
      throw const SavedCaseFailure(SavedCaseFailureKind.invalid);
    }
    return repository.save(owner, List.unmodifiable(items));
  }
}

class ReadListOffline {
  const ReadListOffline(this.repository);
  final SavedListFileRepository repository;
  Future<List<PublicCaseCard>?> call(String owner) {
    if (owner.trim().isEmpty) {
      throw const SavedCaseFailure(SavedCaseFailureKind.forbidden);
    }
    return repository.read(owner);
  }
}

class ClearOfflineLists {
  const ClearOfflineLists(this.repository);
  final SavedListFileRepository repository;
  Future<void> call(String actor) {
    if (actor.trim().isEmpty) {
      throw const SavedCaseFailure(SavedCaseFailureKind.forbidden);
    }
    return repository.clearAll();
  }
}
