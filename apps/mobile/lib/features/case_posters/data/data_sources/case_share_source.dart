import 'dart:typed_data';
import '../../domain/entities/case_poster.dart';
import '../../domain/entities/case_share.dart';
import '../models/poster_payload.dart';

abstract interface class CaseShareSource {
  void checkSession(String actor);
  Future<PosterPayload> prepare(String actor, PosterCase target);
  Future<Uint8List> photo(String actor, PosterCase target, String path);
}

abstract interface class CaseShareActionSource {
  Future<CaseShareResult> handoff(
    CaseShareChannel channel,
    Uri publicUrl,
    PosterDocument? document,
  );
}
