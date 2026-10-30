import '../entities/pet.dart';
import '../failures/pet_failure.dart';
import '../repositories/pet_repository.dart';

class ListMyPets {
  const ListMyPets(this._repository);
  final PetRepository _repository;
  Future<List<Pet>> call(String ownerId, {bool archived = false}) async {
    if (ownerId.isEmpty) throw const PetFailure(PetFailureKind.signedOut);
    final pets = await _repository.list(ownerId, archived: archived);
    if (pets.any((p) => p.ownerId != ownerId || p.isArchived != archived)) {
      throw const PetFailure(PetFailureKind.forbidden);
    }
    return pets;
  }
}
