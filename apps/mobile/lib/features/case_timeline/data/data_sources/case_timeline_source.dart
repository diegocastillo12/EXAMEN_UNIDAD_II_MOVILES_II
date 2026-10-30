import 'package:supabase_flutter/supabase_flutter.dart';

class TimelineSourceFailure implements Exception {
  const TimelineSourceFailure(this.code);
  final String code;
}

abstract interface class CaseTimelineSource {
  Future<Object?> call(
    String owner,
    String function,
    Map<String, dynamic> params,
  );
}

class SupabaseCaseTimelineSource implements CaseTimelineSource {
  const SupabaseCaseTimelineSource(this.client);
  final SupabaseClient client;
  @override
  Future<Object?> call(
    String owner,
    String function,
    Map<String, dynamic> params,
  ) async {
    try {
      if (client.auth.currentUser?.id != owner) {
        throw const TimelineSourceFailure('forbidden');
      }
      final value = await client
          .rpc(function, params: params)
          .timeout(const Duration(seconds: 30));
      if (client.auth.currentUser?.id != owner) {
        throw const TimelineSourceFailure('forbidden');
      }
      return value;
    } on TimelineSourceFailure {
      rethrow;
    } on AuthException {
      throw const TimelineSourceFailure('forbidden');
    } on PostgrestException catch (e) {
      throw TimelineSourceFailure(switch (e.message) {
        'timeline_forbidden' => 'forbidden',
        'timeline_invalid' => 'invalid',
        'timeline_conflict' => 'conflict',
        'timeline_closed' => 'closed',
        'timeline_transition' => 'transition',
        _ => e.code == '42501' ? 'forbidden' : 'unavailable',
      });
    } catch (_) {
      throw const TimelineSourceFailure('unavailable');
    }
  }
}
