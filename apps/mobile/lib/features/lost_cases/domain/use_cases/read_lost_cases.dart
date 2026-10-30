import '../entities/lost_case.dart';
import '../repositories/lost_case_repository.dart';

class ReadPublicLostCase {
  const ReadPublicLostCase(this._repository);
  final LostCaseRepository _repository;
  Future<PublicLostCase?> call(String id) async {
    final result = await _repository.readPublic(id);
    if (result != null && result.id != id) {
      throw const CaseFailure(CaseFailureKind.forbidden);
    }
    return result?.status == 'active' ? result : null;
  }
}

class ListMyLostCases {
  const ListMyLostCases(this._repository);
  final LostCaseRepository _repository;
  Future<List<PublishedLostCase>> call(String owner) async {
    if (owner.isEmpty) throw const CaseFailure(CaseFailureKind.forbidden);
    final result = await _repository.listMine(owner);
    if (result.any((c) => c.ownerId != owner)) {
      throw const CaseFailure(CaseFailureKind.forbidden);
    }
    return List.unmodifiable(result);
  }
}
