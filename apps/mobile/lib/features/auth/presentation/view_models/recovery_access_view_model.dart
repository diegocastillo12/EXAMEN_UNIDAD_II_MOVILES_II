import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recovery_access.dart';
import '../../providers/password_recovery_providers.dart';
import '../../../../core/config/startup_state_provider.dart';

final recoveryAccessViewModelProvider =
    StreamNotifierProvider.autoDispose<RecoveryAccessViewModel, RecoveryAccess>(
      RecoveryAccessViewModel.new,
      retry: (retryCount, error) => null,
    );

class RecoveryAccessViewModel extends StreamNotifier<RecoveryAccess> {
  @override
  Stream<RecoveryAccess> build() => ref.watch(startupStateProvider).isReady
      ? ref.watch(watchRecoveryAccessProvider)()
      : Stream.value(RecoveryAccess.idle);
}
