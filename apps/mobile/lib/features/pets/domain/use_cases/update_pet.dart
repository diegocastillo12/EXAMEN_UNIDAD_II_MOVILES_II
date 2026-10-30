import '../entities/pet.dart';
import '../failures/pet_failure.dart';
import '../repositories/pet_repository.dart';
import 'validate_pet.dart';

class UpdatePet {
  const UpdatePet(this._repository);
  final PetRepository _repository;
  Future<Pet> call(
    String ownerId,
    String petId,
    int expectedVersion,
    PetFields fields,
  ) async {
    if (ownerId.isEmpty) throw const PetFailure(PetFailureKind.signedOut);
    if (expectedVersion < 1) throw const PetFailure(PetFailureKind.conflict);
    final pet = await _repository.update(
      ownerId,
      petId,
      expectedVersion,
      validatePet(fields),
    );
    if (pet.ownerId != ownerId || pet.id != petId) {
      throw const PetFailure(PetFailureKind.forbidden);
    }
    return pet;
  }
}
