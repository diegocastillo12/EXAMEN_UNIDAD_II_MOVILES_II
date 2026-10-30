import '../entities/pet.dart';
import '../failures/pet_failure.dart';
import '../repositories/pet_repository.dart';

class ArchivePet {
  const ArchivePet(this._repository);
  final PetRepository _repository;
  Future<Pet> call(String ownerId, Pet pet) async {
    if (ownerId.isEmpty || pet.ownerId != ownerId) {
      throw const PetFailure(PetFailureKind.forbidden);
    }
    if (pet.activeCaseCount > 0) {
      throw const PetFailure(PetFailureKind.activeCase);
    }
    final result = await _repository.archive(ownerId, pet.id, pet.version);
    if (result.ownerId != ownerId ||
        result.id != pet.id ||
        result.isArchived != true) {
      throw const PetFailure(PetFailureKind.forbidden);
    }
    return result;
  }
}
