import 'package:supabase_flutter/supabase_flutter.dart';

class ReportSourceFailure implements Exception {
  const ReportSourceFailure(this.code);
  final String code;
}

abstract interface class ContentReportSource {
  Future<Object?> submit(String actor, Map<String, dynamic> params);
}

class SupabaseContentReportSource implements ContentReportSource {
  const SupabaseContentReportSource(this.client);
  final SupabaseClient client;
  @override
  Future<Object?> submit(String actor, Map<String, dynamic> params) async {
    try {
      if (client.auth.currentUser?.id != actor) {
        throw const ReportSourceFailure('forbidden');
      }
      final result = await client
          .rpc('submit_content_report', params: params)
          .timeout(const Duration(seconds: 30));
      if (client.auth.currentUser?.id != actor) {
        throw const ReportSourceFailure('forbidden');
      }
      return result;
    } on ReportSourceFailure {
      rethrow;
    } on AuthException {
      throw const ReportSourceFailure('forbidden');
    } on PostgrestException catch (error) {
      throw ReportSourceFailure(switch (error.message) {
        'report_invalid' => 'invalid',
        'report_conflict' => 'conflict',
        _ => error.code == '42501' ? 'forbidden' : 'unavailable',
      });
    } catch (_) {
      throw const ReportSourceFailure('unavailable');
    }
  }
}
