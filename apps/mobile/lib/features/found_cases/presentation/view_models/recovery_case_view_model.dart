import 'found_read_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/found_case_providers.dart';
import '../../domain/entities/found_case.dart';
import '../state/recovery_case_state.dart';

final recoveryCaseViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<RecoveryCaseViewModel, RecoveryCaseState, (String, bool)>(
      (key) => RecoveryCaseViewModel(key.$1, key.$2),
      retry: (_, _) => null,
    );

class RecoveryCaseViewModel extends AsyncNotifier<RecoveryCaseState> {
  RecoveryCaseViewModel(this.id, this.community);
  final String id;
  final bool community;
  String? _owner;
  int _generation = 0;
  @override
  Future<RecoveryCaseState> build() async {
    _generation++;
    final session = await ref.watch(foundSessionProvider.future);
    if (session == null) throw const FoundFailure(FoundFailureKind.forbidden);
    _owner = session.userId;
    return RecoveryCaseState(
      notices: await ref.watch(readRecoveryObservationsProvider)(id, community),
    );
  }

  void retry() => ref.invalidateSelf();
  Future<bool> resolve() async {
    final value = state.asData?.value;
    if (value == null || value.busy || _owner == null) return false;
    final owner = _owner!, generation = _generation, keep = ref.keepAlive();
    state = AsyncData(RecoveryCaseState(notices: value.notices, busy: true));
    try {
      await ref
          .read(resolveRecoverySearchProvider)(owner, id, community)
          .timeout(const Duration(seconds: 30));
      if (!ref.mounted || generation != _generation || owner != _owner) {
        return false;
      }
      state = AsyncData(
        RecoveryCaseState(notices: value.notices, confirmed: true),
      );
      ref.invalidate(myFoundCasesViewModelProvider);
      return true;
    } catch (_) {
      if (ref.mounted && generation == _generation && owner == _owner) {
        state = AsyncData(
          RecoveryCaseState(notices: value.notices, error: true),
        );
      }
      return false;
    } finally {
      keep.close();
    }
  }
}
