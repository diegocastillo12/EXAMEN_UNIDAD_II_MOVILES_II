import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../domain/entities/cached_case.dart';
import '../../providers/case_cache_providers.dart';

final cachedCasesSessionProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(watchAuthSessionProvider)(),
  retry: (_, _) => null,
);
final cachedCasesViewModelProvider =
    AsyncNotifierProvider.autoDispose<CachedCasesViewModel, List<CachedCase>>(
      CachedCasesViewModel.new,
      retry: (_, _) => null,
    );

class CachedCasesViewModel extends AsyncNotifier<List<CachedCase>> {
  @override
  Future<List<CachedCase>> build() async {
    final session = await ref.watch(cachedCasesSessionProvider.future);
    if (session == null) return const [];
    return ref.watch(listCachedCasesProvider)?.call(session.userId) ?? const [];
  }

  void refresh() => ref.invalidateSelf();
}
