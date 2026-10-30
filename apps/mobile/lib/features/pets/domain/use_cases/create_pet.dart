import '../entities/pet.dart';
import '../failures/pet_failure.dart';
import '../repositories/pet_repository.dart';
import 'validate_pet.dart';

class CreatePet {
  const CreatePet(this._repository);
  final PetRepository _repository;
  Future<Pet> call(String ownerId, String petId, PetFields fields) async {
    if (ownerId.isEmpty) throw const PetFailure(PetFailureKind.signedOut);
    final pet = await _repository.create(ownerId, petId, validatePet(fields));
    if (pet.ownerId != ownerId || pet.id != petId) {
      throw const PetFailure(PetFailureKind.forbidden);
    }
    return pet;
  }
}
