import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_providers.dart';

final profileExitViewModelProvider =
    NotifierProvider.autoDispose<ProfileExitViewModel, AsyncValue<void>>(
      ProfileExitViewModel.new,
    );

class ProfileExitViewModel extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);
  Future<void> signOut() async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    try {
      await ref.read(signOutProvider)();
      if (ref.mounted) state = const AsyncData(null);
    } catch (_, stack) {
      if (ref.mounted) {
        state = AsyncError(
          StateError('No se pudo cerrar la sesión. Reintenta.'),
          stack,
        );
      }
    }
  }
}
