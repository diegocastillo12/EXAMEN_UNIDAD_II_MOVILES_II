import '../../domain/entities/user_block.dart';
import '../../domain/repositories/user_block_repository.dart';
import '../data_sources/user_block_source.dart';
import '../models/user_block_dto.dart';

class UserBlockRepositoryImpl implements UserBlockRepository {
  const UserBlockRepositoryImpl(this.source);
  final UserBlockSource source;
  Future<T> _safe<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on BlockSourceFailure catch (e) {
      throw BlockFailure(switch (e.code) {
        'invalid' => BlockIssue.invalid,
        'forbidden' => BlockIssue.forbidden,
        'conflict' => BlockIssue.conflict,
        _ => BlockIssue.unavailable,
      });
    } catch (_) {
      throw const BlockFailure(BlockIssue.unavailable);
    }
  }

  @override
  Future<UserBlock?> prepare(String actor, BlockTarget target) =>
      _safe(() async {
        final raw = await source.rpc(actor, 'prepare_user_block', {
          'p_kind': target.kind,
          'p_resource': target.id,
        });
        return raw == null ? null : UserBlockDto.entry(raw);
      });
  @override
  Future<UserBlockPage> list(String actor, String? before) => _safe(
    () async => UserBlockDto.page(
      await source.rpc(actor, 'list_user_blocks', {'p_before': before}),
    ),
  );
  @override
  Future<UserBlock> set(String actor, BlockChange change) => _safe(() async {
    final result = UserBlockDto.entry(
      await source.rpc(actor, 'set_user_block', {
        'p_id': change.entry.id,
        'p_enabled': change.enabled,
        'p_version': change.entry.version,
      }),
    );
    if (result.id != change.entry.id ||
        result.enabled != change.enabled ||
        result.version !=
            change.entry.version +
                (change.entry.enabled == change.enabled ? 0 : 1)) {
      throw const FormatException();
    }
    return result;
  });
}

class UnavailableUserBlockRepository implements UserBlockRepository {
  const UnavailableUserBlockRepository();
  @override
  Future<UserBlock?> prepare(String actor, BlockTarget target) async =>
      throw const BlockFailure(BlockIssue.unavailable);
  @override
  Future<UserBlockPage> list(String actor, String? before) async =>
      throw const BlockFailure(BlockIssue.unavailable);
  @override
  Future<UserBlock> set(String actor, BlockChange change) async =>
      throw const BlockFailure(BlockIssue.unavailable);
}
