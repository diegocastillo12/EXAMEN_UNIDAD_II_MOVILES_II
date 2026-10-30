import '../../domain/entities/found_case.dart';

class FoundCaseDto {
  const FoundCaseDto(this.row);
  final Map<String, dynamic> row;
  FoundPublication publication({Uri? coverUri}) => FoundPublication(
    id: row['id'] as String,
    reportKind: row['report_kind'] as String? ?? 'legacy_found',
    targetId:
        (row['target_id'] ??
                row['target_lost_case_id'] ??
                row['target_community_case_id'])
            as String?,
    communityTarget:
        row['community_target'] as bool? ??
        (row['target_community_case_id'] != null),
    ownerId: row['owner_id'] as String,
    status: row['status'] as String,
    coverUri: coverUri,
    species: row['species'] as String?,
  );
  PublicFoundCase publicCase(List<FoundPhoto> photos) => PublicFoundCase(
    id: row['id'] as String,
    reportKind: row['report_kind'] as String? ?? 'legacy_found',
    targetId:
        (row['target_id'] ??
                row['target_lost_case_id'] ??
                row['target_community_case_id'])
            as String?,
    communityTarget:
        row['community_target'] as bool? ??
        (row['target_community_case_id'] != null),
    status: row['status'] as String,
    canResolve: row['can_resolve'] as bool? ?? false,
    canGeneratePoster: row['can_generate_poster'] as bool? ?? false,
    occurredAt: DateTime.parse(row['occurred_at'] as String),
    latitude: (row['latitude'] as num).toDouble(),
    longitude: (row['longitude'] as num).toDouble(),
    species: row['species'] as String,
    speciesDetail: row['species_detail'] as String?,
    size: row['size'] as String?,
    sex: row['sex'] as String?,
    traits: row['traits'] as String,
    custody: row['custody'] as String?,
    photos: photos,
  );
}
