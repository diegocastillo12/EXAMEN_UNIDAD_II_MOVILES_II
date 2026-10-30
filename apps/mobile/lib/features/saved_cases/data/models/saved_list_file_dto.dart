import '../../../../core/domain/entities/public_case_card.dart';

/// Only the already-authorized public list fields. No contact or signed URLs.
abstract final class SavedListFileDto {
  static Map<String, Object?> encode(PublicCaseCard item) => {
    'id': item.id,
    'report_kind': item.reportKind,
    'from_pet': item.fromPet,
    'kind': item.kind.name,
    'status': item.status.name,
    'species': item.species,
    'name': item.name,
    'traits': item.traits,
    'occurred_at': item.occurredAt.toIso8601String(),
    'latitude': item.latitude,
    'longitude': item.longitude,
    'distance_meters': item.distanceMeters,
  };

  static PublicCaseCard decode(Map<String, dynamic> row) => PublicCaseCard(
    id: row['id'] as String,
    reportKind: row['report_kind'] as String,
    fromPet: row['from_pet'] as bool,
    kind: PublicCaseKind.values.byName(row['kind'] as String),
    status: PublicCaseStatus.values.byName(row['status'] as String),
    species: row['species'] as String,
    name: row['name'] as String,
    traits: row['traits'] as String,
    occurredAt: DateTime.parse(row['occurred_at'] as String),
    latitude: (row['latitude'] as num).toDouble(),
    longitude: (row['longitude'] as num).toDouble(),
    distanceMeters: row['distance_meters'] as int?,
  );
}
