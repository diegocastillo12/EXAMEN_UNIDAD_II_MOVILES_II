import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/found_case.dart';
import '../models/found_case_dto.dart';
import 'found_case_data_source.dart';

class SupabaseFoundCaseDataSource implements FoundCaseDataSource {
  const SupabaseFoundCaseDataSource(
    this._client, {
    Duration requestTimeout = const Duration(seconds: 30),
  }) : _requestTimeout = requestTimeout;
  final Duration _requestTimeout;
  final SupabaseClient _client;
  void _identity(String owner) {
    if (_client.auth.currentUser?.id != owner) {
      throw const FoundSourceFailure(FoundFailureKind.forbidden);
    }
  }

  FoundSourceFailure _failure(String? code, String? message) =>
      FoundSourceFailure(switch (message) {
        'interaction_blocked' => FoundFailureKind.blocked,
        'found_photos_unverified' => FoundFailureKind.photos,
        'found_draft_limit' => FoundFailureKind.draftLimit,
        'found_target_closed' => FoundFailureKind.targetClosed,
        _ => switch (code) {
          '42501' ||
          '401' ||
          '403' ||
          'PGRST301' ||
          'PGRST302' ||
          'PGRST303' => FoundFailureKind.forbidden,
          '40001' || 'PT409' || '23505' || '409' => FoundFailureKind.conflict,
          '23514' => FoundFailureKind.invalid,
          '55P03' || '57014' => FoundFailureKind.timedOut,
          '422' || '413' => FoundFailureKind.photoInvalid,
          _ => FoundFailureKind.unavailable,
        },
      });
  Future<T> _run<T>(Future<T> Function() work) async {
    try {
      return await work();
    } on FoundSourceFailure {
      rethrow;
    } on TimeoutException {
      throw const FoundSourceFailure(FoundFailureKind.timedOut);
    } on PostgrestException catch (e) {
      throw _failure(e.code, e.message);
    } on FunctionException catch (e) {
      throw _failure('${e.status}', null);
    } catch (_) {
      throw const FoundSourceFailure(FoundFailureKind.unavailable);
    }
  }

  @override
  Future<FoundCaseDto> publish(String owner, FoundCaseDraft d) =>
      _run(() async {
        _identity(owner);
        final ids = d.photos.map((p) => p.id).toList();
        await _client
            .rpc(
              'prepare_recovery_report',
              params: {
                'p_id': d.id,
                'p_photo_ids': ids,
                'p_report_kind': d.reportKind,
                'p_target_id': d.targetId,
                'p_community_target': d.communityTarget,
              },
            )
            .timeout(_requestTimeout);
        _identity(owner);
        final retired =
            await _client
                    .rpc('list_found_photo_cleanup', params: {'p_id': d.id})
                    .timeout(_requestTimeout)
                as List;
        for (final bucket in [
          'found-photo-renditions',
          'found-photo-thumbnails',
        ]) {
          _identity(owner);
          final paths = retired.map((r) => r['path'] as String).toList();
          if (paths.isNotEmpty) {
            await _client.storage
                .from(bucket)
                .remove(paths)
                .timeout(_requestTimeout);
          }
        }
        for (final photo in d.photos) {
          _identity(owner);
          final response = await _client.functions
              .invoke(
                'pet-photo-process',
                body: photo.bytes,
                headers: {
                  'Content-Type': 'image/jpeg',
                  'x-found-case-id': d.id,
                  'x-photo-id': photo.id,
                },
              )
              .timeout(_requestTimeout);
          final row = response.data;
          if (row is! Map ||
              row['id'] != photo.id ||
              row['case_id'] != d.id ||
              row['owner_id'] != owner ||
              row['status'] != 'ready' ||
              row['processed_at'] == null) {
            throw const FoundSourceFailure(FoundFailureKind.unavailable);
          }
        }
        _identity(owner);
        final rows = await _client
            .rpc(
              'publish_recovery_report',
              params: {
                'p_id': d.id,
                'p_report_kind': d.reportKind,
                'p_target_id': d.targetId,
                'p_community_target': d.communityTarget,
                'p_occurred_at': d.occurredAt.toUtc().toIso8601String(),
                'p_latitude': d.latitude,
                'p_longitude': d.longitude,
                'p_place_reference': d.placeReference.trim(),
                'p_species': d.species,
                'p_species_detail': d.speciesDetail?.trim(),
                'p_size': d.size,
                'p_sex': d.sex,
                'p_traits': d.traits.trim(),
                'p_custody': d.custody,
                'p_photo_ids': ids,
              },
            )
            .timeout(_requestTimeout);
        _identity(owner);
        return FoundCaseDto(
          Map<String, dynamic>.from((rows as List).single as Map),
        );
      });
  @override
  Future<FoundCaseDto?> readPublic(String id) => _run(() async {
    final rows =
        await _client
                .rpc('read_recovery_report', params: {'p_id': id})
                .timeout(_requestTimeout)
            as List;
    return rows.isEmpty
        ? null
        : FoundCaseDto(Map<String, dynamic>.from(rows.single as Map));
  });
  @override
  Future<Uri?> photoUri(String path) async {
    try {
      return Uri.parse(
        await _client.storage
            .from('found-photo-renditions')
            .createSignedUrl(path, 300)
            .timeout(_requestTimeout),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<FoundCaseDto>> listMine(String owner) => _run(() async {
    _identity(owner);
    final rows =
        await _client.rpc('list_my_recovery_reports').timeout(_requestTimeout)
            as List;
    _identity(owner);
    return rows
        .map((row) => FoundCaseDto(Map<String, dynamic>.from(row as Map)))
        .toList();
  });
  @override
  Future<void> discard(String owner, String id) => _run(() async {
    _identity(owner);
    final rows =
        await _client
                .rpc('begin_found_case_discard', params: {'p_id': id})
                .timeout(_requestTimeout)
            as List;
    for (final bucket in ['found-photo-renditions', 'found-photo-thumbnails']) {
      _identity(owner);
      final paths = rows.map((r) => r['path'] as String).toList();
      if (paths.isNotEmpty) {
        await _client.storage
            .from(bucket)
            .remove(paths)
            .timeout(_requestTimeout);
      }
    }
    _identity(owner);
    await _client
        .rpc('finish_found_case_discard', params: {'p_id': id})
        .timeout(_requestTimeout);
    _identity(owner);
  });
  @override
  Future<List<FoundCaseDto>> listObservations(String id, bool community) =>
      _run(() async {
        final rows =
            await _client
                    .rpc(
                      'list_recovery_observations',
                      params: {'p_id': id, 'p_community': community},
                    )
                    .timeout(_requestTimeout)
                as List;
        return rows
            .map((row) => FoundCaseDto(Map<String, dynamic>.from(row as Map)))
            .toList();
      });
  @override
  Future<List<Map<String, dynamic>>> listOpenSearches(String owner) => _run(
    () async {
      _identity(owner);
      final rows =
          await _client
                  .rpc('list_open_recovery_searches')
                  .timeout(_requestTimeout)
              as List;
      _identity(owner);
      return rows.map((row) => Map<String, dynamic>.from(row as Map)).toList();
    },
  );
  @override
  Future<void> resolveSearch(String owner, String id, bool community) =>
      _run(() async {
        _identity(owner);
        await _client
            .rpc(
              'resolve_recovery_search',
              params: {'p_id': id, 'p_community': community},
            )
            .timeout(_requestTimeout);
        _identity(owner);
      });
  @override
  Future<void> delete(String owner, String id) => _run(() async {
    _identity(owner);
    await _client
        .rpc('delete_found_case', params: {'p_id': id})
        .timeout(const Duration(seconds: 15));
    _identity(owner);
  });
}
