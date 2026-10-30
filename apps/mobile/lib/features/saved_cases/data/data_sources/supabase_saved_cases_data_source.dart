import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../../../../core/data/models/public_case_page_dto.dart';
import '../models/saved_case_mark_dto.dart';
import 'saved_cases_data_source.dart';

class SupabaseSavedCasesDataSource implements SavedCasesDataSource {
  const SupabaseSavedCasesDataSource(this._client);
  final SupabaseClient _client;
  @override
  Future<PublicCasePageDto> list(String owner, String? cursor) async {
    _check(owner);
    try {
      final raw = await _client
          .rpc(
            'list_saved_cases',
            params: {
              'p_cursor': cursor == null ? null : jsonDecode(cursor),
              'p_limit': 20,
            },
          )
          .timeout(const Duration(seconds: 15));
      _check(owner);
      return PublicCasePageDto(Map<String, dynamic>.from(raw as Map));
    } on SavedCaseSourceFailure {
      rethrow;
    } catch (_) {
      throw const SavedCaseSourceFailure(SavedCaseSourceIssue.unavailable);
    }
  }

  @override
  Future<Uri> cover(String owner, String source, String path) async {
    _check(owner);
    try {
      final url = await _client.storage
          .from(
            source == 'lost'
                ? 'pet-photo-thumbnails'
                : 'found-photo-thumbnails',
          )
          .createSignedUrl(path, 3600)
          .timeout(const Duration(seconds: 15));
      _check(owner);
      return Uri.parse(url);
    } catch (_) {
      throw const SavedCaseSourceFailure(SavedCaseSourceIssue.unavailable);
    }
  }

  void _check(String owner) {
    if (_client.auth.currentUser?.id != owner) {
      throw const SavedCaseSourceFailure(SavedCaseSourceIssue.forbidden);
    }
  }

  Future<SavedCaseMarkDto> _request(
    String owner,
    String function,
    Map<String, Object?> params,
  ) async {
    _check(owner);
    try {
      final result = await _client
          .rpc(function, params: params)
          .timeout(const Duration(seconds: 15));
      _check(owner);
      return SavedCaseMarkDto(result);
    } on SavedCaseSourceFailure {
      rethrow;
    } on PostgrestException catch (error) {
      throw SavedCaseSourceFailure(switch (error.code) {
        '42501' => SavedCaseSourceIssue.forbidden,
        '40001' => SavedCaseSourceIssue.conflict,
        'P0002' => SavedCaseSourceIssue.hidden,
        _ => SavedCaseSourceIssue.unavailable,
      });
    } catch (_) {
      throw const SavedCaseSourceFailure(SavedCaseSourceIssue.unavailable);
    }
  }

  @override
  Future<SavedCaseMarkDto> read(String owner, String source, String id) =>
      _request(owner, 'read_saved_case', {'p_source': source, 'p_case_id': id});
  @override
  Future<SavedCaseMarkDto> setSaved(
    String owner,
    String source,
    String id, {
    required bool saved,
    required int expectedVersion,
  }) => _request(owner, 'set_saved_case', {
    'p_source': source,
    'p_case_id': id,
    'p_saved': saved,
    'p_expected_version': expectedVersion,
  });
}
