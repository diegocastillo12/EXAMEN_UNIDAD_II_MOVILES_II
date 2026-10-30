import 'package:supabase_flutter/supabase_flutter.dart';

class AppealSourceFailure implements Exception {
  const AppealSourceFailure(this.code);
  final String code;
}

abstract interface class AppealsSource {
  Future<Object?> list(String actor, Map<String, dynamic> params);
  Future<Object?> submit(String actor, Map<String, dynamic> params);
}

class SupabaseAppealsSource implements AppealsSource {
  const SupabaseAppealsSource(this.client);
  final SupabaseClient client;
  Future<Object?> _rpc(
    String actor,
    String name,
    Map<String, dynamic> params,
  ) async {
    try {
      if (client.auth.currentUser?.id != actor ||
          client.auth.currentUser?.isAnonymous == true) {
        throw const AppealSourceFailure('forbidden');
      }
      final value = await client
          .rpc(name, params: params)
          .timeout(const Duration(seconds: 30));
      if (client.auth.currentUser?.id != actor) {
        throw const AppealSourceFailure('forbidden');
      }
      return value;
    } on AppealSourceFailure {
      rethrow;
    } on AuthException {
      throw const AppealSourceFailure('forbidden');
    } on PostgrestException catch (e) {
      throw AppealSourceFailure(switch (e.message) {
        'appeal_invalid' => 'invalid',
        'appeal_conflict' => 'conflict',
        _ => e.code == '42501' ? 'forbidden' : 'unavailable',
      });
    } catch (_) {
      throw const AppealSourceFailure('unavailable');
    }
  }

  @override
  Future<Object?> list(String actor, Map<String, dynamic> params) =>
      _rpc(actor, 'list_moderation_appeals', params);
  @override
  Future<Object?> submit(String actor, Map<String, dynamic> params) =>
      _rpc(actor, 'submit_moderation_appeal', params);
}
