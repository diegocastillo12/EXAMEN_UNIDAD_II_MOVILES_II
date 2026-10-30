import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_block.dart';
import '../../providers/user_block_providers.dart';
import '../state/user_block_state.dart';

final userBlockViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<UserBlockViewModel, UserBlockState, BlockTarget?>(
      UserBlockViewModel.new,
      retry: (_, _) => null,
    );

class UserBlockViewModel extends AsyncNotifier<UserBlockState> {
  UserBlockViewModel(this.target);
  final BlockTarget? target;
  int _generation = 0;
  @override
  Future<UserBlockState> build() async {
    final generation = ++_generation;
    final session = await ref.watch(blockSessionProvider.future);
    if (session == null) throw const BlockFailure(BlockIssue.forbidden);
    final scope = target;
    if (scope != null) {
      final entry = await ref.read(prepareUserBlockProvider)(
        session.userId,
        scope,
      );
      if (generation != _generation) {
        throw const BlockFailure(BlockIssue.forbidden);
      }
      return UserBlockState(actor: session.userId, target: entry);
    }
    final page = await ref.read(readUserBlocksProvider)(session.userId);
    if (generation != _generation) {
      throw const BlockFailure(BlockIssue.forbidden);
    }
    return UserBlockState(
      actor: session.userId,
      items: page.items,
      next: page.next,
    );
  }

  void retry() => ref.invalidateSelf();
  bool _current(int generation, String actor) =>
      ref.mounted &&
      generation == _generation &&
      !state.isLoading &&
      !state.hasError &&
      state.asData?.value.actor == actor;
  Future<void> load({bool more = false}) async {
    final value = state.asData?.value;
    if (value == null ||
        state.isLoading ||
        state.hasError ||
        value.busy ||
        value.refreshing ||
        value.pending != null ||
        target != null ||
        (more && value.next == null)) {
      return;
    }
    final generation = _generation;
    state = AsyncData(value.copy(refreshing: true));
    try {
      final page = await ref.read(readUserBlocksProvider)(
        value.actor,
        before: more ? value.next : null,
      );
      if (!_current(generation, value.actor)) return;
      state = AsyncData(
        value.copy(
          items: more
              ? List.unmodifiable([
                  ...value.items,
                  ...page.items.where(
                    (e) => !value.items.any((old) => old.id == e.id),
                  ),
                ])
              : page.items,
          next: page.next,
          replaceNext: true,
        ),
      );
    } catch (e) {
      if (_current(generation, value.actor)) _fail(value, e);
    }
  }

  void _fail(UserBlockState value, Object e, {BlockChange? pending}) {
    final issue = e is BlockFailure ? e.issue : BlockIssue.unavailable;
    state = issue == BlockIssue.forbidden
        ? AsyncError(BlockFailure(issue), StackTrace.current)
        : AsyncData(
            value.copy(
              issue: issue,
              pending: pending,
              clearPending: issue != BlockIssue.unavailable,
            ),
          );
  }

  Future<bool> change(UserBlock entry, bool enabled) async {
    final value = state.asData?.value;
    if (value == null ||
        state.isLoading ||
        state.hasError ||
        value.busy ||
        value.refreshing ||
        value.issue == BlockIssue.conflict) {
      return false;
    }
    if (value.pending != null &&
        (value.pending!.entry.id != entry.id ||
            value.pending!.enabled != enabled)) {
      return false;
    }
    final command = value.pending ?? BlockChange(entry, enabled);
    final generation = _generation, keep = ref.keepAlive();
    state = AsyncData(value.copy(busy: true, pending: command));
    try {
      final updated = await ref
          .read(setUserBlockProvider)(value.actor, command)
          .timeout(const Duration(seconds: 35));
      if (!_current(generation, value.actor)) return false;
      state = AsyncData(
        value.copy(
          target: target != null ? updated : null,
          items: value.items
              .where((e) => e.id != updated.id)
              .toList(growable: false),
          clearPending: true,
          confirmed: true,
        ),
      );
      return true;
    } catch (e) {
      if (_current(generation, value.actor)) _fail(value, e, pending: command);
      return false;
    } finally {
      keep.close();
    }
  }
}
