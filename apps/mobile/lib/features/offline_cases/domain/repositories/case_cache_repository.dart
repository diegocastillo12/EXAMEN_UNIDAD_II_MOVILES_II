import '../entities/cached_case.dart';

abstract interface class CaseCacheRepository {
  Future<CachedCase?> read(String owner, String source, String id);
  Future<List<CachedCase>> list(String owner);
  Future<void> put(String owner, CachedCase value);
  Future<void> remove(String owner, String source, String id);
}
