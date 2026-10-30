import '../../domain/entities/pet.dart';
import '../../domain/failures/pet_failure.dart';
import '../../domain/repositories/pet_repository.dart';
import '../data_sources/pet_data_source.dart';

class PetRepositoryImpl implements PetRepository {
  const PetRepositoryImpl(this._source);
  final PetDataSource _source;
  @override
  Future<void> delete(String ownerId, String petId, int expectedVersion) =>
      _run(() => _source.delete(ownerId, petId, expectedVersion));
  @override
  Future<Pet> archive(String ownerId, String petId, int expectedVersion) =>
      _run(
        () async =>
            (await _source.archive(ownerId, petId, expectedVersion)).toEntity(),
      );
  @override
  Future<Pet> restore(String ownerId, String petId, int expectedVersion) =>
      _run(
        () async =>
            (await _source.restore(ownerId, petId, expectedVersion)).toEntity(),
      );
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PetSourceFailure catch (error) {
      throw PetFailure(PetFailureKind.values.byName(error.kind.name));
    } catch (_) {
      throw const PetFailure(PetFailureKind.unavailable);
    }
  }

  @override
  Future<List<Pet>> list(String ownerId, {bool archived = false}) => _run(
    () async => (await _source.list(
      ownerId,
      archived: archived,
    )).map((d) => d.toEntity()).toList(),
  );
  @override
  Future<Pet> read(String ownerId, String petId) =>
      _run(() async => (await _source.read(ownerId, petId)).toEntity());
  @override
  Future<Pet> create(String ownerId, String petId, PetFields f) => _run(
    () async => (await _source.create(
      ownerId,
      petId,
      name: f.name,
      species: f.species!.name,
      sex: f.sex?.name,
      ageMonths: f.ageMonths,
      traits: f.traits,
      speciesDetail: f.speciesDetail,
      size: f.size?.name,
    )).toEntity(),
  );
  @override
  Future<Pet> update(
    String ownerId,
    String petId,
    int expectedVersion,
    PetFields f,
  ) => _run(
    () async => (await _source.update(
      ownerId,
      petId,
      expectedVersion,
      name: f.name,
      species: f.species!.name,
      sex: f.sex?.name,
      ageMonths: f.ageMonths,
      traits: f.traits,
      speciesDetail: f.speciesDetail,
      size: f.size?.name,
    )).toEntity(),
  );
}
