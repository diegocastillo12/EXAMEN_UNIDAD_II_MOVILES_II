import '../../domain/entities/pet.dart';
import '../../domain/failures/pet_failure.dart';

class PetEditorState {
  const PetEditorState({
    required this.id,
    required this.ownerId,
    this.original,
    this.name = '',
    this.species,
    this.sex = PetSex.male,
    this.age = '',
    this.traits = '',
    this.speciesDetail = '',
    this.size,
    this.busy = false,
    this.saved,
    this.issue,
    this.errorId = 0,
    this.invalidFields = const {},
  });
  final String id;
  final String ownerId;
  final Pet? original;
  final String name;
  final PetSpecies? species;
  final PetSex? sex;
  final String age;
  final String traits;
  final String speciesDetail;
  final PetSize? size;
  final bool busy;
  final Pet? saved;
  final PetFailureKind? issue;
  final int errorId;
  final Set<PetFailureKind> invalidFields;
  bool get hasUnsavedChanges => original != null
      ? dirty
      : name.isNotEmpty ||
            species != null ||
            sex != PetSex.male ||
            age.isNotEmpty ||
            traits.isNotEmpty ||
            speciesDetail.isNotEmpty ||
            size != null;

  bool get dirty =>
      original == null ||
      name != original!.fields.name ||
      species != original!.fields.species ||
      speciesDetail != (original!.fields.speciesDetail ?? '') ||
      size != original!.fields.size ||
      sex != original!.fields.sex ||
      age != (original!.fields.ageMonths?.toString() ?? '') ||
      traits != (original!.fields.traits ?? '');
  PetEditorState copy({
    String? name,
    PetSpecies? species,
    PetSex? sex,
    bool clearSex = false,
    String? age,
    String? traits,
    String? speciesDetail,
    PetSize? size,
    bool clearSize = false,
    bool busy = false,
    Pet? saved,
    PetFailureKind? issue,
    int? errorId,
    Set<PetFailureKind>? invalidFields,
  }) => PetEditorState(
    id: id,
    ownerId: ownerId,
    original: original,
    name: name ?? this.name,
    species: species ?? this.species,
    sex: clearSex ? null : (sex ?? this.sex),
    age: age ?? this.age,
    traits: traits ?? this.traits,
    speciesDetail: speciesDetail ?? this.speciesDetail,
    size: clearSize ? null : (size ?? this.size),
    busy: busy,
    saved: saved,
    issue: issue,
    errorId: errorId ?? this.errorId,
    invalidFields: invalidFields ?? this.invalidFields,
  );
  factory PetEditorState.fromPet(Pet pet) => PetEditorState(
    speciesDetail: pet.fields.speciesDetail ?? '',
    size: pet.fields.size,
    id: pet.id,
    ownerId: pet.ownerId,
    original: pet,
    name: pet.fields.name,
    species: pet.fields.species,
    sex: pet.fields.sex,
    age: pet.fields.ageMonths?.toString() ?? '',
    traits: pet.fields.traits ?? '',
  );
}
