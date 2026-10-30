import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSourceFailure implements Exception {
  const ContactSourceFailure(this.code);
  final String? code;
}

class CaseContactSource {
  const CaseContactSource(this._client);
  final SupabaseClient _client;

  Future<Map<String, dynamic>> request(
    String owner,
    String function,
    Map<String, dynamic> params,
  ) async {
    void check() {
      if (_client.auth.currentUser?.id != owner) {
        throw const ContactSourceFailure('42501');
      }
    }

    check();
    try {
      final row = Map<String, dynamic>.from(
        await _client
                .rpc(function, params: params)
                .timeout(const Duration(seconds: 20))
            as Map,
      );
      check();
      final contact = row['contact'];
      if (contact is Map && contact['avatar_path'] is String) {
        try {
          contact['avatar_url'] = await _client.storage
              .from('profile-avatars')
              .createSignedUrl(contact['avatar_path'] as String, 60)
              .timeout(const Duration(seconds: 10));
        } catch (_) {
          /* Optional avatar must not hide the authorized contact. */
        }
      }
      check();
      return row;
    } on PostgrestException catch (error) {
      throw ContactSourceFailure(error.code);
    }
  }

  Future<void> open(String phone, {required bool message}) async {
    if (!await launchUrl(
      Uri(scheme: message ? 'sms' : 'tel', path: phone),
      mode: LaunchMode.externalApplication,
    )) {
      throw const ContactSourceFailure(null);
    }
  }
}
