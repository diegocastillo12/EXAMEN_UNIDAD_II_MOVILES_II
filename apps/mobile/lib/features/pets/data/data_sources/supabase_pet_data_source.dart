import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet_dto.dart';
import 'pet_data_source.dart';

class SupabasePetDataSource implements PetDataSource {
  const SupabasePetDataSource(this._client);
  final SupabaseClient _client;
  @override
  Future<void> delete(String ownerId, String petId, int expectedVersion) =>
      _run(ownerId, () async {
        final exists = await _client.rpc(
          'begin_pet_deletion',
          params: {'p_id': petId, 'p_expected_version': expectedVersion},
        );
        if (exists == false) return;
        _identity(ownerId);
        final photos = await _client
            .from('pet_photos')
            .select('id')
            .eq('owner_id', ownerId)
            .eq('pet_id', petId);
        _identity(ownerId);
        if (photos.isNotEmpty) {
          for (final bucket in [
            'pet-photos',
            'pet-photo-renditions',
            'pet-photo-thumbnails',
          ]) {
            _identity(ownerId);
            await _client.storage.from(bucket).remove([
              for (final photo in photos) '$ownerId/$petId/${photo['id']}.jpg',
            ]);
          }
        }
        _identity(ownerId);
        await _client.rpc('finish_pet_deletion', params: {'p_id': petId});
      });
  static const columns =
      'id,owner_id,name,species,sex,age_months,traits,species_detail,size,version,archived_at,case_history_at,active_case_count,pet_photos(id,status,created_at,is_primary,processed_at)';
  Future<PetDto> _dto(Map<String, dynamic> row) async {
    Uri? cover;
    final photos =
        (row['pet_photos'] as List? ?? [])
            .whereType<Map>()
            .where((photo) => photo['status'] == 'published')
            .toList()
          ..sort(
            (a, b) => a['is_primary'] != b['is_primary']
                ? (a['is_primary'] == true ? -1 : 1)
                : '${a['created_at']}:${a['id']}'.compareTo(
                    '${b['created_at']}:${b['id']}',
                  ),
          );
    if (photos.isNotEmpty) {
      try {
        cover = Uri.parse(
          await _client.storage
              .from(
                photos.first['processed_at'] != null
                    ? 'pet-photo-thumbnails'
                    : 'pet-photos',
              )
              .createSignedUrl(
                '${row['owner_id']}/${row['id']}/${photos.first['id']}.jpg',
                3600,
              ),
        );
      } catch (_) {
        // A failed preview must not hide the owner's pet record.
      }
    }
    return PetDto.fromMap(row, coverUri: cover);
  }

  void _identity(String owner) {
    if (_client.auth.currentUser == null) {
      throw const PetSourceFailure(PetSourceFailureKind.signedOut);
    }
    if (_client.auth.currentUser!.id != owner) {
      throw const PetSourceFailure(PetSourceFailureKind.forbidden);
    }
  }

  Future<T> _run<T>(String owner, Future<T> Function() action) async {
    _identity(owner);
    try {
      final result = await action();
      _identity(owner);
      return result;
    } on PetSourceFailure {
      rethrow;
    } on PostgrestException catch (error) {
      final kind = switch (error.code) {
        'P0002' => PetSourceFailureKind.missing,
        '40001' => PetSourceFailureKind.conflict,
        '42501' => PetSourceFailureKind.forbidden,
        '23514' => switch (error.message) {
          'pet_active_case' => PetSourceFailureKind.activeCase,
          'pet_has_case_history' => PetSourceFailureKind.caseHistory,
          'pet_invalid_name' => PetSourceFailureKind.invalidName,
          'pet_invalid_species' => PetSourceFailureKind.invalidSpecies,
          'pet_invalid_size' => PetSourceFailureKind.invalidSize,
          'pet_invalid_age' => PetSourceFailureKind.invalidAge,
          'pet_invalid_traits' => PetSourceFailureKind.invalidTraits,
          'pet_invalid_species_detail' =>
            PetSourceFailureKind.invalidSpeciesDetail,
          _ => PetSourceFailureKind.unavailable,
        },
        _ => PetSourceFailureKind.unavailable,
      };
      throw PetSourceFailure(kind);
    } catch (_) {
      throw const PetSourceFailure(PetSourceFailureKind.unavailable);
    }
  }

  @override
  Future<List<PetDto>> list(String ownerId, {bool archived = false}) =>
      _run(ownerId, () async {
        final query = _client
            .from('pets')
            .select(columns)
            .eq('owner_id', ownerId);
        final filtered = archived
            ? query.not('archived_at', 'is', null)
            : query.isFilter('archived_at', null);
        final rows = await filtered
            .order('created_at', ascending: false)
            .order('id');
        return Future.wait(rows.map(_dto));
      });
  @override
  Future<PetDto> read(String ownerId, String petId) => _run(ownerId, () async {
    final row = await _client
        .from('pets')
        .select(columns)
        .eq('owner_id', ownerId)
        .eq('id', petId)
        .maybeSingle();
    if (row == null) throw const PetSourceFailure(PetSourceFailureKind.missing);
    return _dto(row);
  });
  @override
  Future<PetDto> archive(String ownerId, String petId, int expectedVersion) =>
      _lifecycle(ownerId, petId, expectedVersion, 'archive_pet');
  @override
  Future<PetDto> restore(String ownerId, String petId, int expectedVersion) =>
      _lifecycle(ownerId, petId, expectedVersion, 'restore_pet');
  Future<PetDto> _lifecycle(
    String owner,
    String id,
    int version,
    String command,
  ) => _run(owner, () async {
    final rows = await _client.rpc(
      command,
      params: {'p_id': id, 'p_expected_version': version},
    );
    final dto = PetDto.fromMap(
      Map<String, dynamic>.from((rows as List).single as Map),
    );
    if (dto.ownerId != owner || dto.id != id) {
      throw const PetSourceFailure(PetSourceFailureKind.forbidden);
    }
    return dto;
  });
  Future<PetDto> _write(
    String owner,
    String id,
    String command,
    int? version,
    String name,
    String species,
    String? sex,
    int? age,
    String? traits,
    String? speciesDetail,
    String? size,
  ) => _run(owner, () async {
    final rows = await _client.rpc(
      command,
      params: {
        'p_id': id,
        'p_name': name,
        'p_species': species,
        'p_sex': sex,
        'p_age_months': age,
        'p_traits': traits,
        'p_species_detail': speciesDetail,
        'p_size': size,
        if (version != null) 'p_expected_version': version,
      },
    );
    final dto = PetDto.fromMap(
      Map<String, dynamic>.from((rows as List).single as Map),
    );
    if (dto.ownerId != owner || dto.id != id) {
      throw const PetSourceFailure(PetSourceFailureKind.forbidden);
    }
    return dto;
  });
  @override
  Future<PetDto> create(
    String ownerId,
    String petId, {
    required String name,
    required String species,
    String? sex,
    int? ageMonths,
    String? traits,
    String? speciesDetail,
    String? size,
  }) => _write(
    ownerId,
    petId,
    'create_pet_v2',
    null,
    name,
    species,
    sex,
    ageMonths,
    traits,
    speciesDetail,
    size,
  );
  @override
  Future<PetDto> update(
    String ownerId,
    String petId,
    int expectedVersion, {
    required String name,
    required String species,
    String? sex,
    int? ageMonths,
    String? traits,
    String? speciesDetail,
    String? size,
  }) => _write(
    ownerId,
    petId,
    'update_pet_v2',
    expectedVersion,
    name,
    species,
    sex,
    ageMonths,
    traits,
    speciesDetail,
    size,
  );
}
