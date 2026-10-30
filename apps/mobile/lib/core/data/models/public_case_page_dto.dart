import 'dart:convert';
import '../../domain/entities/public_case_card.dart';

class PublicCasePageDto {
  const PublicCasePageDto(this.row);
  final Map<String, dynamic> row;
  List<Map<String, dynamic>> get items => (row['items'] as List)
      .map((v) => Map<String, dynamic>.from(v as Map))
      .toList();
  String? get nextCursor =>
      row['next_cursor'] == null ? null : jsonEncode(row['next_cursor']);
  static PublicCaseCard toEntity(Map<String, dynamic> r, Uri? cover) =>
      PublicCaseCard(
        id: r['id'] as String,
        reportKind: r['report_kind'] as String? ?? 'own_loss',
        fromPet: r['source'] == 'lost',
        kind: PublicCaseKind.values.byName(r['kind'] as String),
        status: PublicCaseStatus.values.byName(r['status'] as String),
        species: r['species'] as String,
        name: r['name'] as String,
        traits: r['traits'] as String,
        occurredAt: DateTime.parse(r['occurred_at'] as String),
        latitude: (r['latitude'] as num).toDouble(),
        longitude: (r['longitude'] as num).toDouble(),
        distanceMeters: (r['distance_meters'] as num?)?.round(),
        coverUri: cover,
      );
}
