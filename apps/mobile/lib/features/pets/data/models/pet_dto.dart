import '../../domain/entities/pet.dart';

class PetDto {
  const PetDto({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.version,
    this.sex,
    this.ageMonths,
    this.traits,
    this.speciesDetail,
    this.size,
    this.coverUri,
    this.archivedAt,
    this.caseHistoryAt,
    this.activeCaseCount = 0,
  });
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String? sex;
  final int? ageMonths;
  final String? traits;
  final String? speciesDetail;
  final String? size;
  final Uri? coverUri;
  final DateTime? archivedAt;
  final DateTime? caseHistoryAt;
  final int activeCaseCount;
  final int version;
  factory PetDto.fromMap(Map<String, dynamic> row, {Uri? coverUri}) => PetDto(
    coverUri: coverUri,
    archivedAt: row['archived_at'] == null
        ? null
        : DateTime.parse(row['archived_at'] as String),
    caseHistoryAt: row['case_history_at'] == null
        ? null
        : DateTime.parse(row['case_history_at'] as String),
    activeCaseCount: row['active_case_count'] as int? ?? 0,
    id: row['id'] as String,
    ownerId: row['owner_id'] as String,
    version: row['version'] as int,
    name: row['name'] as String,
    species: row['species'] as String,
    sex: row['sex'] as String?,
    ageMonths: row['age_months'] as int?,
    traits: row['traits'] as String?,
    speciesDetail: row['species_detail'] as String?,
    size: row['size'] as String?,
  );
  Pet toEntity() => Pet(
    coverUri: coverUri,
    archivedAt: archivedAt,
    caseHistoryAt: caseHistoryAt,
    activeCaseCount: activeCaseCount,
    id: id,
    ownerId: ownerId,
    version: version,
    fields: PetFields(
      speciesDetail: speciesDetail,
      size: size == null ? null : PetSize.values.byName(size!),
      name: name,
      species: PetSpecies.values.byName(species),
      sex: sex == null ? null : PetSex.values.byName(sex!),
      ageMonths: ageMonths,
      traits: traits,
    ),
  );
}
