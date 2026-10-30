import '../entities/pet.dart';

abstract interface class PetRepository {
  Future<Pet> archive(String ownerId, String petId, int expectedVersion);
  Future<Pet> restore(String ownerId, String petId, int expectedVersion);
  Future<void> delete(String ownerId, String petId, int expectedVersion);
  Future<List<Pet>> list(String ownerId, {bool archived = false});
  Future<Pet> read(String ownerId, String petId);
  Future<Pet> create(String ownerId, String petId, PetFields fields);
  Future<Pet> update(
    String ownerId,
    String petId,
    int expectedVersion,
    PetFields fields,
  );
}
