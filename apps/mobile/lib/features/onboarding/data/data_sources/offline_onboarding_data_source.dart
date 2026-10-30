import 'dart:async';
import 'package:http/http.dart' show ClientException;
import 'onboarding_completion_cache.dart';
import 'onboarding_data_source.dart';
import '../models/onboarding_record_dto.dart';

/// Caches only onboarding completion, never a session or operation permission.
class OfflineOnboardingDataSource implements OnboardingDataSource {
  OfflineOnboardingDataSource(
    this.remote,
    this.cache, {
    required this.currentOwner,
    this.timeout = const Duration(seconds: 5),
  });
  final OnboardingDataSource remote;
  final OnboardingCompletionCache cache;
  final String? Function() currentOwner;
  final Duration timeout;

  @override
  Future<OnboardingRecordDto> read(String userId) async {
    try {
      final record = await remote.read(userId).timeout(timeout);
      try {
        await cache.write(userId, record.completed);
      } catch (_) {
        /* Server result remains authoritative. */
      }
      return record;
    } catch (error) {
      if (currentOwner() != userId ||
          (error is! TimeoutException && error is! ClientException)) {
        rethrow;
      }
      if (await cache.read(userId) != true) rethrow;
      return const OnboardingRecordDto(completed: true);
    }
  }

  @override
  Future<void> complete() async {
    final owner = currentOwner();
    await remote.complete();
    if (owner != null) {
      try {
        await cache.write(owner, true);
      } catch (_) {
        /* Retry read can populate the cache. */
      }
    }
  }
}
