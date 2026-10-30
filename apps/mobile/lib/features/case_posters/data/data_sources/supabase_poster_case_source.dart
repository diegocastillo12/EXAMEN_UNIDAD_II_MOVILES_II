import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/case_poster.dart';
import '../models/poster_payload.dart';
import 'poster_case_source.dart';

class SupabasePosterCaseSource implements PosterCaseSource {
  const SupabasePosterCaseSource(this._client);
  final SupabaseClient _client;
  @override
  void checkOwner(String owner) {
    if (_client.auth.currentUser?.id != owner) {
      throw const PosterFailure(PosterFailureKind.forbidden);
    }
  }

  @override
  Future<PosterPayload> prepare(String owner, PosterCase target) async {
    checkOwner(owner);
    try {
      final row = await _client
          .rpc(
            'prepare_case_poster',
            params: {'p_source': target.source.name, 'p_id': target.id},
          )
          .timeout(const Duration(seconds: 15));
      checkOwner(owner);
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
  Future<Uint8List> photo(String owner, PosterCase target, String path) async {
    checkOwner(owner);
    // A processed rendition only: no originals, private metadata or signed URL in PDF.
    final bytes = await _client.storage
        .from(
          target.source == PosterSource.lost
              ? 'pet-photo-renditions'
              : 'found-photo-renditions',
        )
        .download(path)
        .timeout(const Duration(seconds: 15));
    checkOwner(owner);
    if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
      throw const PosterFailure(PosterFailureKind.unavailable);
    }
    return bytes;
  }
}
