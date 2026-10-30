import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/alert_preferences_dto.dart';
import 'alert_preference_data_source.dart';

class SupabaseAlertPreferenceDataSource implements AlertPreferenceDataSource {
  const SupabaseAlertPreferenceDataSource(this.client);
  final SupabaseClient client;
  Future<T> _run<T>(String ownerId, Future<T> Function() action) async {
    if (client.auth.currentUser?.id != ownerId) {
      throw const PreferenceSourceException(PreferenceSourceIssue.signedOut);
    }
    try {
      return await action();
    } on PostgrestException catch (error) {
      throw PreferenceSourceException(
        error.code == '40001'
            ? PreferenceSourceIssue.conflict
            : PreferenceSourceIssue.unavailable,
      );
    } catch (_) {
      throw const PreferenceSourceException(PreferenceSourceIssue.unavailable);
    }
  }

  @override
  Future<AlertPreferencesDto?> read(String ownerId) => _run(ownerId, () async {
    final row = await client
        .from('alert_preferences')
        .select(
          'owner_id,version,enabled,lost_pets,found_pets,case_updates,in_app,push',
        )
        .eq('owner_id', ownerId)
        .maybeSingle();
    return row == null ? null : AlertPreferencesDto(row);
  });
  @override
  Future<AlertPreferencesDto> save(
    String ownerId,
    Map<String, dynamic> parameters,
  ) => _run(ownerId, () async {
    final row = await client
        .rpc('save_alert_preferences', params: parameters)
        .single();
    return AlertPreferencesDto(Map<String, dynamic>.from(row as Map));
  });
}
