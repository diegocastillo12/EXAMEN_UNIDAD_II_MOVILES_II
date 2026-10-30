import '../entities/pet.dart';
import '../failures/pet_failure.dart';

/// All invalid fields, in form reading order; also used before any write.
Set<PetFailureKind> petValidationIssues(PetFields value) {
  final issues = <PetFailureKind>{};
  final name = value.name.trim();
  final traits = value.traits?.trim();
  final detail = value.speciesDetail?.trim();
  if (name.isEmpty || name.runes.length > 80) {
    issues.add(PetFailureKind.invalidName);
  }
  if (value.species == null) issues.add(PetFailureKind.invalidSpecies);
  if (value.species == PetSpecies.other &&
      (detail == null || detail.isEmpty || detail.runes.length > 60)) {
    issues.add(PetFailureKind.invalidSpeciesDetail);
  }
  if (value.size == null) issues.add(PetFailureKind.invalidSize);
  if (value.ageMonths == null ||
      value.ageMonths! < 0 ||
      value.ageMonths! > 600) {
    issues.add(PetFailureKind.invalidAge);
  }
  if (traits == null || traits.isEmpty || traits.runes.length > 200) {
    issues.add(PetFailureKind.invalidTraits);
  }
  return Set.unmodifiable(issues);
}

PetFields validatePet(PetFields value) {
  final issues = petValidationIssues(value);
  if (issues.isNotEmpty) throw PetFailure(issues.first);
  return PetFields(
    speciesDetail: value.species == PetSpecies.other
        ? value.speciesDetail!.trim()
        : null,
    size: value.size,
    name: value.name.trim(),
    species: value.species,
    sex: value.sex,
    ageMonths: value.ageMonths,
    traits: value.traits!.trim(),
  );
}
