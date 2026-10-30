import '../../../lost_cases/domain/repositories/lost_case_repository.dart';
import '../repositories/found_case_repository.dart';
import '../entities/found_case.dart';

/// Resolves only the case opened from its detail; never reads the open catalogue.
class ReadRecoverySearch {
  const ReadRecoverySearch(this._pets, this._community);
  final LostCaseRepository _pets;
  final FoundCaseRepository _community;
  Future<RecoverySearch> call(String id, bool community) async {
    if (id.isEmpty) throw const FoundFailure(FoundFailureKind.targetClosed);
    if (community) {
      final value = await _community.readPublic(id);
      if (value == null ||
          value.id != id ||
          value.status != 'active' ||
          value.reportKind != 'possible_loss') {
        throw const FoundFailure(FoundFailureKind.targetClosed);
      }
      return RecoverySearch(
        id: id,
        community: true,
        name: '',
        species: value.species,
        speciesDetail: value.speciesDetail,
        size: value.size,
        sex: value.sex,
      );
    }
    final value = await _pets.readPublic(id);
    if (value == null || value.id != id || value.status != 'active') {
      throw const FoundFailure(FoundFailureKind.targetClosed);
    }
    if (value.fields.species == null) {
      throw const FoundFailure(FoundFailureKind.unavailable);
    }
    return RecoverySearch(
      id: id,
      community: false,
      name: value.fields.name,
      species: value.fields.species!.name,
      speciesDetail: value.fields.speciesDetail,
      size: value.fields.size?.name,
      sex: value.fields.sex?.name,
    );
  }
}
