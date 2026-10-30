import 'dart:convert';
import '../../domain/entities/cached_case.dart';
import '../../domain/repositories/case_cache_repository.dart';
import '../data_sources/case_cache_database.dart';
import '../data_sources/case_cache_photo_source.dart';
import '../models/cached_case_dto.dart';

class CaseCacheRepositoryImpl implements CaseCacheRepository {
  CaseCacheRepositoryImpl(
    this.database, {
    this.photos = const CaseCachePhotoSource(),
  });
  final CaseCacheDatabase database;
  final CaseCachePhotoSource photos;
  final Map<String, int> _versions = {};
  final Set<String> _invalidated = {};
  String _key(String owner, String source, String id) => '$owner/$source/$id';
  @override
  Future<CachedCase?> read(String owner, String source, String id) async {
    if (_invalidated.contains(_key(owner, source, id))) return null;
    final rows = await database.rows(owner, source: source, id: id);
    return rows.isEmpty
        ? null
        : CachedCaseDto.decode(jsonDecode(rows.single) as Map<String, dynamic>);
  }

  @override
  Future<List<CachedCase>> list(String owner) async =>
      (await database.rows(owner))
          .map(
            (r) => CachedCaseDto.decode(jsonDecode(r) as Map<String, dynamic>),
          )
          .where((v) => !_invalidated.contains(_key(owner, v.source, v.id)))
          .toList();
  @override
  Future<void> remove(String owner, String source, String id) {
    final key = _key(owner, source, id);
    _invalidated.add(key);
    _versions[key] = (_versions[key] ?? 0) + 1;
    return database.remove(owner, source, id);
  }

  @override
  Future<void> put(String owner, CachedCase value) async {
    final key = _key(owner, value.source, value.id);
    final version = (_versions[key] ?? 0) + 1;
    _versions[key] = version;
    final old = await read(owner, value.source, value.id);
    final references = value.lost != null
        ? value.lost!.photos.map((p) => (p.id, p.uri))
        : value.found!.photos.map((p) => (p.id, p.uri));
    final prior = old?.lost != null
        ? old!.lost!.photos.map((p) => (p.id, p.uri))
        : old?.found?.photos.map((p) => (p.id, p.uri)) ??
              const <(String, Uri?)>[];
    final local = await Future.wait(
      references.take(3).map((p) async {
        final uri = await photos.download(p.$2);
        final previous = prior.where((v) => v.$1 == p.$1).firstOrNull?.$2;
        return <String, Object?>{
          'id': p.$1,
          'data': (uri ?? previous)?.toString(),
        };
      }),
    );
    if (_versions[key] != version) return;
    await database.put(
      owner,
      value.source,
      value.id,
      value.storedAt.millisecondsSinceEpoch,
      jsonEncode(CachedCaseDto.encode(value, local)),
    );
    if (_versions[key] == version) _invalidated.remove(key);
  }
}
