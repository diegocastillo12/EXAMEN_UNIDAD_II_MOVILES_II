import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/onboarding_record_dto.dart';
import 'onboarding_data_source.dart';

final class SupabaseOnboardingDataSource implements OnboardingDataSource {
  const SupabaseOnboardingDataSource(this._client);
  final SupabaseClient _client;
  @override
  Future<OnboardingRecordDto> read(String userId) async {
    final row = await _client
        .from('profiles')
        .select('onboarding_completed_at')
        .eq('id', userId)
        .single();
    return OnboardingRecordDto.fromMap(row);
  }

  @override
  Future<void> complete() async {
    await _client.rpc('complete_onboarding');
  }
}
