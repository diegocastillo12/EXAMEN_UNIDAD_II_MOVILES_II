import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/explore_query.dart';
import '../models/explore_page_dto.dart';
import 'explore_data_source.dart';

class SupabaseExploreDataSource implements ExploreDataSource {
  const SupabaseExploreDataSource(this._client);
  final SupabaseClient _client;
  void _check(String owner) {
    if (_client.auth.currentUser?.id != owner) {
      throw const ExploreSourceFailure(true);
    }
  }

  @override
  Future<ExplorePageDto> search(
    String owner,
    ExploreQuery q,
    String? cursor,
  ) async {
    _check(owner);
    try {
      final result = await _client
          .rpc(
            'explore_cases',
            params: {
              'p_kind': q.kind.name,
              'p_species': q.species.name,
              'p_status': q.status.name,
              'p_since': q.since?.toUtc().toIso8601String(),
              'p_until': q.until?.toUtc().toIso8601String(),
              'p_latitude': q.latitude,
              'p_longitude': q.longitude,
              'p_radius_meters': q.radiusMeters,
              'p_cursor': cursor == null ? null : jsonDecode(cursor),
              'p_limit': 20,
            },
          )
          .timeout(const Duration(seconds: 15));
      _check(owner);
      return ExplorePageDto(Map<String, dynamic>.from(result as Map));
    } on ExploreSourceFailure {
      rethrow;
    } on PostgrestException catch (e) {
      throw ExploreSourceFailure(e.code == '42501');
    } catch (_) {
      throw const ExploreSourceFailure(false);
    }
  }

  @override
  Future<Uri> cover(String owner, String source, String path) async {
    _check(owner);
    try {
      final url = await _client.storage
          .from(
            source == 'lost'
                ? 'pet-photo-thumbnails'
                : 'found-photo-thumbnails',
          )
          .createSignedUrl(path, 3600)
          .timeout(const Duration(seconds: 15));
      _check(owner);
      return Uri.parse(url);
    } catch (_) {
      throw const ExploreSourceFailure(false);
    }
  }
}
