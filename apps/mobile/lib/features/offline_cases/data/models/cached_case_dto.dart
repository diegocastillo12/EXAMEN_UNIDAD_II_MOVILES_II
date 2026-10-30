import '../../../lost_cases/domain/entities/lost_case.dart';
import '../../../found_cases/domain/entities/found_case.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../domain/entities/cached_case.dart';

/// Explicit allowlist: no contact, profile, signed URL or authorization flag.
class CachedCaseDto {
  static Map<String, Object?> encode(
    CachedCase item,
    List<Map<String, Object?>> photos,
  ) {
    final lost = item.lost;
    final found = item.found;
    return {
      'id': item.id,
      'source': item.source,
      'stored_at': item.storedAt.toIso8601String(),
      'occurred_at': (lost?.occurredAt ?? found!.occurredAt).toIso8601String(),
      'status': lost?.status ?? found!.status,
      'latitude': lost?.latitude ?? found!.latitude,
      'longitude': lost?.longitude ?? found!.longitude,
      'species': lost?.fields.species?.name ?? found?.species,
      'species_detail': lost?.fields.speciesDetail ?? found?.speciesDetail,
      'size': lost?.fields.size?.name ?? found?.size,
      'sex': lost?.fields.sex?.name ?? found?.sex,
      'traits': lost?.fields.traits ?? found?.traits,
      'name': lost?.fields.name,
      'age_months': lost?.fields.ageMonths,
      'report_kind': found?.reportKind,
      'custody': found?.custody,
      'photos': photos,
    };
  }

  static CachedCase decode(Map<String, dynamic> row) {
    final photos = (row['photos'] as List).cast<Map<String, dynamic>>();
    Uri? photo(Map<String, dynamic> p) {
      final raw = p['data'] as String?;
      if (raw == null) return null;
      final uri = Uri.parse(raw);
      if (uri.scheme != 'data' || !uri.data!.mimeType.startsWith('image/')) {
        throw const FormatException('Invalid local photo');
      }
      return uri;
    }

    return CachedCase(
      storedAt: DateTime.parse(row['stored_at'] as String),
      lost: row['source'] != 'lost'
          ? null
          : PublicLostCase(
              id: row['id'] as String,
              status: row['status'] as String,
              occurredAt: DateTime.parse(row['occurred_at'] as String),
              latitude: (row['latitude'] as num).toDouble(),
              longitude: (row['longitude'] as num).toDouble(),
              fields: PetFields(
                name: row['name'] as String,
                species: row['species'] == null
                    ? null
                    : PetSpecies.values.byName(row['species'] as String),
                speciesDetail: row['species_detail'] as String?,
                size: row['size'] == null
                    ? null
                    : PetSize.values.byName(row['size'] as String),
                sex: row['sex'] == null
                    ? null
                    : PetSex.values.byName(row['sex'] as String),
                ageMonths: row['age_months'] as int?,
                traits: row['traits'] as String?,
              ),
              photos: photos
                  .map((p) => CasePhoto(id: p['id'] as String, uri: photo(p)))
                  .toList(),
            ),
      found: row['source'] != 'found'
          ? null
          : PublicFoundCase(
              id: row['id'] as String,
              status: row['status'] as String,
              occurredAt: DateTime.parse(row['occurred_at'] as String),
              latitude: (row['latitude'] as num).toDouble(),
              longitude: (row['longitude'] as num).toDouble(),
              species: row['species'] as String,
              speciesDetail: row['species_detail'] as String?,
              size: row['size'] as String?,
              sex: row['sex'] as String?,
              traits: row['traits'] as String,
              reportKind: row['report_kind'] as String,
              custody: row['custody'] as String?,
              photos: photos
                  .map((p) => FoundPhoto(p['id'] as String, photo(p)))
                  .toList(),
            ),
    );
  }
}
