import '../entities/pet.dart';
import '../failures/pet_failure.dart';
import '../repositories/pet_repository.dart';

class RestorePet {
  const RestorePet(this._repository);
  final PetRepository _repository;
  Future<Pet> call(String ownerId, Pet pet) async {
    if (ownerId.isEmpty || pet.ownerId != ownerId) {
      throw const PetFailure(PetFailureKind.forbidden);
    }

    final result = await _repository.restore(ownerId, pet.id, pet.version);
    if (result.ownerId != ownerId ||
        result.id != pet.id ||
        result.isArchived != false) {
      throw const PetFailure(PetFailureKind.forbidden);
    }
    return result;
  }
}
