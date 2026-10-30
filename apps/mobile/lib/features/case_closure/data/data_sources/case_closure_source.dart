import 'package:supabase_flutter/supabase_flutter.dart';

class ClosureSourceFailure implements Exception {
  const ClosureSourceFailure(this.code);
  final String code;
}

abstract interface class CaseClosureSource {
  Future<Object?> call(
    String owner,
    String function,
    Map<String, dynamic> params,
  );
}

class SupabaseCaseClosureSource implements CaseClosureSource {
  const SupabaseCaseClosureSource(this.client);
  final SupabaseClient client;
  @override
  Future<Object?> call(
    String owner,
    String function,
    Map<String, dynamic> params,
  ) async {
    try {
      if (client.auth.currentUser?.id != owner) {
        throw const ClosureSourceFailure('forbidden');
      }
      final result = await client
          .rpc(function, params: params)
          .timeout(const Duration(seconds: 30));
      if (client.auth.currentUser?.id != owner) {
        throw const ClosureSourceFailure('forbidden');
      }
      return result;
    } on ClosureSourceFailure {
      rethrow;
    } on AuthException {
      throw const ClosureSourceFailure('forbidden');
    } on PostgrestException catch (e) {
      throw ClosureSourceFailure(switch (e.message) {
        'closure_invalid' => 'invalid',
        'closure_conflict' => 'conflict',
        'closure_closed' => 'closed',
        _ => e.code == '42501' ? 'forbidden' : 'unavailable',
      });
    } catch (_) {
      throw const ClosureSourceFailure('unavailable');
    }
  }
}
