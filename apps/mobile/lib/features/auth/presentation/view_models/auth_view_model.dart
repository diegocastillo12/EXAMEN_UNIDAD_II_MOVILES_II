import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/startup_state_provider.dart';
import '../../providers/auth_providers.dart';
import '../state/auth_view_state.dart';

final authViewModelProvider =
    NotifierProvider.autoDispose<AuthViewModel, AuthViewState>(
      AuthViewModel.new,
    );

class AuthViewModel extends Notifier<AuthViewState> {
  @override
  AuthViewState build() {
    final startup = ref.watch(startupStateProvider);
    return AuthViewState(
      startup: startup,
      session: startup.isReady
          ? ref.watch(authSessionProvider)
          : const AsyncData(null),
    );
  }
}
