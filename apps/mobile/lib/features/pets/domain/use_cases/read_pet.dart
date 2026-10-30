import '../entities/pet.dart';
import '../failures/pet_failure.dart';
import '../repositories/pet_repository.dart';

class ReadPet {
  const ReadPet(this._repository);
  final PetRepository _repository;
  Future<Pet> call(String ownerId, String petId) async {
    if (ownerId.isEmpty) throw const PetFailure(PetFailureKind.signedOut);
    final pet = await _repository.read(ownerId, petId);
    if (pet.ownerId != ownerId || pet.id != petId) {
      throw const PetFailure(PetFailureKind.forbidden);
    }
    return pet;
  }
}
