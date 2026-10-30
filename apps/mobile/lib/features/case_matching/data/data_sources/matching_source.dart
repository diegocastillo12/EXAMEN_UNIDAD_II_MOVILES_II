import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/case_match.dart';

class MatchingSource {
  MatchingSource(this.supabase, this.client, this.baseUrl);
  final SupabaseClient supabase;
  final http.Client client;
  final String baseUrl;
  Future<dynamic> call(
    String owner,
    String operation,
    Map<String, dynamic> body,
  ) async {
    try {
      final base = Uri.parse(baseUrl);
      if (base.scheme != 'https' ||
          base.host.isEmpty ||
          base.userInfo.isNotEmpty ||
          base.hasQuery ||
          base.hasFragment ||
          (base.path.isNotEmpty && base.path != '/')) {
        throw const MatchFailure(MatchIssue.unavailable);
      }
      var session = supabase.auth.currentSession;
      if (session == null ||
          session.user.id != owner ||
          supabase.auth.currentUser?.id != owner) {
        throw const MatchFailure(MatchIssue.forbidden);
      }
      if (session.isExpired) {
        session = (await supabase.auth.refreshSession()).session;
      }
      if (session == null || session.user.id != owner) {
        throw const MatchFailure(MatchIssue.forbidden);
      }
      final request =
          http.Request(
              'POST',
              base.replace(path: '/api/app/matching/$operation'),
            )
            ..headers.addAll({
              'Authorization': 'Bearer ${session.accessToken}',
              'Content-Type': 'application/json',
            })
            ..body = jsonEncode(body);
      final response = await client
          .send(request)
          .timeout(const Duration(seconds: 90));
      final bytes = <int>[];
      await for (final chunk in response.stream.timeout(
        const Duration(seconds: 90),
      )) {
        if (bytes.length + chunk.length > 131072) {
          throw const MatchFailure(MatchIssue.unavailable);
        }
        bytes.addAll(chunk);
      }
      if (supabase.auth.currentUser?.id != owner) {
        throw const MatchFailure(MatchIssue.forbidden);
      }
      if (response.statusCode != 200) {
        throw MatchFailure(switch (response.statusCode) {
          401 || 403 => MatchIssue.forbidden,
          409 => MatchIssue.conflict,
          422 => MatchIssue.invalid,
          429 => MatchIssue.busy,
          _ => MatchIssue.unavailable,
        });
      }
      return jsonDecode(utf8.decode(bytes));
    } on MatchFailure {
      rethrow;
    } catch (_) {
      throw const MatchFailure(MatchIssue.unavailable);
    }
  }
}
