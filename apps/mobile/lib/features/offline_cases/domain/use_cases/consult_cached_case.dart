import 'dart:async';
import '../../../lost_cases/domain/entities/lost_case.dart';
import '../../../found_cases/domain/entities/found_case.dart';
import '../entities/cached_case.dart';
import '../repositories/case_cache_repository.dart';

class ConsultCachedCase {
  ConsultCachedCase(this.cache);
  final CaseCacheRepository cache;
  final Map<String, int> _requests = {};
  Future<CaseConsultation<T>> _invalidate<T>(
    String owner,
    String source,
    String id,
  ) async {
    try {
      await cache.remove(owner, source, id);
      return const CaseConsultation(null);
    } catch (_) {
      return const CaseConsultation(null, storageFailed: true);
    }
  }

  Future<CaseConsultation<T>> call<T>({
    required String? owner,
    required String source,
    required String id,
    required Future<T?> Function() load,
  }) async {
    final key = '$owner/$source/$id';
    final request = (_requests[key] ?? 0) + 1;
    _requests[key] = request;
    T? value;
    try {
      value = await load().timeout(const Duration(seconds: 8));
    } catch (error) {
      if (_requests[key] != request) return const CaseConsultation(null);
      final transport =
          error is TimeoutException ||
          error is CaseFailure &&
              {
                CaseFailureKind.unavailable,
                CaseFailureKind.timedOut,
              }.contains(error.kind) ||
          error is FoundFailure &&
              {
                FoundFailureKind.unavailable,
                FoundFailureKind.timedOut,
              }.contains(error.kind);
      if (owner == null || owner.isEmpty) rethrow;
      if (!transport) {
        return _invalidate(owner, source, id);
      }
      final stored = await cache.read(owner, source, id);
      if (stored == null) rethrow;
      return CaseConsultation<T>(
        (source == 'lost' ? stored.lost : stored.found) as T?,
        cachedAt: stored.storedAt,
      );
    }
    if (_requests[key] != request) return const CaseConsultation(null);
    if (owner == null || owner.isEmpty) return CaseConsultation(value);
    final active = value is PublicLostCase
        ? value.status == 'active' && value.id == id
        : value is PublicFoundCase &&
              value.status == 'active' &&
              value.id == id;
    if (!active) {
      // A confirmed absence/closed case must never resurrect from local storage.
      return _invalidate(owner, source, id);
    }
    try {
      await cache.put(
        owner,
        CachedCase(
          storedAt: DateTime.now().toUtc(),
          lost: value is PublicLostCase ? value : null,
          found: value is PublicFoundCase ? value : null,
        ),
      );
      return CaseConsultation(value);
    } catch (_) {
      return CaseConsultation(value, storageFailed: true);
    }
  }
}

class ListCachedCases {
  const ListCachedCases(this.cache);
  final CaseCacheRepository cache;
  Future<List<CachedCase>> call(String owner) {
    if (owner.trim().isEmpty) throw ArgumentError('owner');
    return cache.list(owner);
  }
}
