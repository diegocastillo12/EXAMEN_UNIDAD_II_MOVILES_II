enum PetFailureKind {
  unavailable,
  signedOut,
  missing,
  forbidden,
  conflict,
  activeCase,
  caseHistory,
  invalidName,
  invalidSpecies,
  invalidSize,
  invalidAge,
  invalidTraits,
  invalidSpeciesDetail,
}

final class PetFailure implements Exception {
  const PetFailure(this.kind);
  final PetFailureKind kind;
}
