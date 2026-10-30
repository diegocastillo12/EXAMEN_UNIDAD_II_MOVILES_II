import 'dart:typed_data';
import '../../domain/entities/case_poster.dart';
import '../models/poster_payload.dart';

abstract interface class PosterCaseSource {
  void checkOwner(String owner);
  Future<PosterPayload> prepare(String owner, PosterCase target);
  Future<Uint8List> photo(String owner, PosterCase target, String path);
}
