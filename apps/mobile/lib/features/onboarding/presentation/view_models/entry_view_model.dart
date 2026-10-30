import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/startup_state_provider.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../providers/onboarding_providers.dart';
import '../state/entry_destination.dart';

final entryViewModelProvider =
    AsyncNotifierProvider.autoDispose<EntryViewModel, EntryDestination>(
      EntryViewModel.new,
    );

class EntryViewModel extends AsyncNotifier<EntryDestination> {
  @override
  Future<EntryDestination> build() async {
    if (!ref.watch(startupStateProvider).isReady) return EntryDestination.login;
    final session = ref.watch(authSessionProvider);
    if (session.hasError) throw StateError('Session unavailable');
    if (session.isLoading) return EntryDestination.checking;
    final user = session.asData?.value;
    if (user == null) return EntryDestination.login;
    final completed = await ref.watch(checkOnboardingProvider)(user.userId);
    return completed ? EntryDestination.home : EntryDestination.onboarding;
  }

  void retry() => ref.invalidateSelf();
}

final entryExitViewModelProvider =
    NotifierProvider.autoDispose<EntryExitViewModel, AsyncValue<void>>(
      EntryExitViewModel.new,
    );

class EntryExitViewModel extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);
  Future<void> signOut() async {
    if (state.isLoading) return;
    final keep = ref.keepAlive();
    state = const AsyncLoading();
    try {
      await ref.read(signOutProvider)();
      if (ref.mounted) state = const AsyncData(null);
    } catch (error, stack) {
      if (ref.mounted) state = AsyncError(error, stack);
    } finally {
      keep.close();
    }
  }
}
