import '../../../../core/domain/utils/new_entity_id.dart';

enum PetSpecies { dog, cat, other }

enum PetSex { male, female }

enum PetSize { small, medium, large }

class PetFields {
  const PetFields({
    required this.name,
    required this.species,
    this.sex,
    this.ageMonths,
    this.traits,
    this.speciesDetail,
    this.size,
  });
  final String name;
  final PetSpecies? species;
  final PetSex? sex;
  final int? ageMonths;
  final String? traits;
  final String? speciesDetail;
  final PetSize? size;
}

class Pet {
  const Pet({
    required this.id,
    required this.ownerId,
    required this.fields,
    required this.version,
    this.coverUri,
    this.archivedAt,
    this.caseHistoryAt,
    this.activeCaseCount = 0,
  });
  final String id;
  final String ownerId;
  final PetFields fields;
  final int version;
  final Uri? coverUri;
  final DateTime? archivedAt;
  final DateTime? caseHistoryAt;
  final int activeCaseCount;
  bool get isArchived => archivedAt != null;
}

/// One UUID per draft, reused after an ambiguous network response.
String newPetId() => newEntityId();
