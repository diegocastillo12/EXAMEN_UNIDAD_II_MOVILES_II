import 'package:supabase_flutter/supabase_flutter.dart';

class BlockSourceFailure implements Exception {
  const BlockSourceFailure(this.code);
  final String code;
}

abstract interface class UserBlockSource {
  Future<Object?> rpc(
    String actor,
    String operation,
    Map<String, dynamic> params,
  );
}

class SupabaseUserBlockSource implements UserBlockSource {
  const SupabaseUserBlockSource(this.client);
  final SupabaseClient client;
  @override
  Future<Object?> rpc(
    String actor,
    String operation,
    Map<String, dynamic> params,
  ) async {
    try {
      if (client.auth.currentUser?.id != actor) {
        throw const BlockSourceFailure('forbidden');
      }
      final result = await client
          .rpc(operation, params: params)
          .timeout(const Duration(seconds: 30));
      if (client.auth.currentUser?.id != actor) {
        throw const BlockSourceFailure('forbidden');
      }
      return result;
    } on BlockSourceFailure {
      rethrow;
    } on AuthException {
      throw const BlockSourceFailure('forbidden');
    } on PostgrestException catch (e) {
      throw BlockSourceFailure(switch (e.message) {
        'block_invalid' => 'invalid',
        'block_conflict' => 'conflict',
        _ => e.code == '42501' ? 'forbidden' : 'unavailable',
      });
    } catch (_) {
      throw const BlockSourceFailure('unavailable');
    }
  }
}
