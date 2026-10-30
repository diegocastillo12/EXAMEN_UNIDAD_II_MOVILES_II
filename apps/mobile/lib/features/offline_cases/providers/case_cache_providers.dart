import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/case_cache_repository.dart';
import '../domain/use_cases/consult_cached_case.dart';

final caseCacheRepositoryProvider = Provider<CaseCacheRepository?>(
  (ref) => null,
);
final consultCachedCaseProvider = Provider((ref) {
  final cache = ref.watch(caseCacheRepositoryProvider);
  return cache == null ? null : ConsultCachedCase(cache);
});
final listCachedCasesProvider = Provider((ref) {
  final cache = ref.watch(caseCacheRepositoryProvider);
  return cache == null ? null : ListCachedCases(cache);
});
