import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/case_poster.dart';
import '../models/poster_payload.dart';
import 'case_share_source.dart';

class SupabaseCaseShareSource implements CaseShareSource {
  const SupabaseCaseShareSource(this._client);
  final SupabaseClient _client;
  @override
  void checkSession(String actor) {
    if (_client.auth.currentUser?.id != actor) {
      throw const PosterFailure(PosterFailureKind.forbidden);
    }
  }

  @override
  Future<PosterPayload> prepare(String actor, PosterCase target) async {
    checkSession(actor);
    try {
      final row = await _client
          .rpc(
            'prepare_case_share',
            params: {'p_source': target.source.name, 'p_id': target.id},
          )
          .timeout(const Duration(seconds: 15));
      checkSession(actor);
      return PosterPayload(Map<String, dynamic>.from(row as Map));
    } on PostgrestException catch (e) {
      throw PosterFailure(
        e.code == '42501'
            ? PosterFailureKind.forbidden
            : e.code == '23514'
            ? PosterFailureKind.inactive
            : PosterFailureKind.unavailable,
      );
    }
  }

  @override
  Future<Uint8List> photo(String actor, PosterCase target, String path) async {
    checkSession(actor);
    final bytes = await _client.storage
        .from(
          target.source == PosterSource.lost
              ? 'pet-photo-renditions'
              : 'found-photo-renditions',
        )
        .download(path)
        .timeout(const Duration(seconds: 15));
    checkSession(actor);
    if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
      throw const PosterFailure(PosterFailureKind.unavailable);
    }
    return bytes;
  }
}
