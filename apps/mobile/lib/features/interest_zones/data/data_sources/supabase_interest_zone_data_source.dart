import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/interest_zone_dto.dart';
import 'interest_zone_data_source.dart';

class SupabaseInterestZoneDataSource implements InterestZoneDataSource {
  const SupabaseInterestZoneDataSource(this.client);
  final SupabaseClient client;
  Future<T> _run<T>(String ownerId, Future<T> Function() action) async {
    if (client.auth.currentUser?.id != ownerId) {
      throw const ZoneSourceException(ZoneSourceIssue.signedOut);
    }
    try {
      return await action();
    } on PostgrestException catch (error) {
      throw ZoneSourceException(switch (error.code) {
        '40001' => ZoneSourceIssue.conflict,
        '22023' || '23514' => ZoneSourceIssue.invalid,
        '42501' => ZoneSourceIssue.unavailable,
        _ => ZoneSourceIssue.network,
      });
    } catch (_) {
      throw const ZoneSourceException(ZoneSourceIssue.network);
    }
  }

  @override
  Future<List<InterestZoneDto>> list(String ownerId) => _run(ownerId, () async {
    final rows = await client
        .from('interest_zones')
        .select('id,owner_id,name,latitude,longitude,radius_meters,version')
        .eq('owner_id', ownerId)
        .order('created_at', ascending: true)
        .order('id', ascending: true);
    return rows.map(InterestZoneDto.new).toList();
  });
  @override
  Future<InterestZoneDto> save(String ownerId, Map<String, dynamic> params) =>
      _run(ownerId, () async {
        final row = await client
            .rpc('save_interest_zone', params: params)
            .single();
        return InterestZoneDto(Map<String, dynamic>.from(row as Map));
      });
  @override
  Future<void> delete(String ownerId, String id, int version) =>
      _run(ownerId, () async {
        await client.rpc(
          'delete_interest_zone',
          params: {'p_id': id, 'p_expected_version': version},
        );
      });
}
