import '../entities/user_block.dart';
import '../repositories/user_block_repository.dart';

final _id = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

class ReadUserBlocks {
  const ReadUserBlocks(this.repository);
  final UserBlockRepository repository;
  Future<UserBlockPage> call(String actor, {String? before}) {
    if (!_id.hasMatch(actor) || (before != null && !_id.hasMatch(before))) {
      throw const BlockFailure(BlockIssue.invalid);
    }
    return repository.list(actor, before);
  }
}

class PrepareUserBlock {
  const PrepareUserBlock(this.repository);
  final UserBlockRepository repository;
  Future<UserBlock?> call(String actor, BlockTarget target) {
    if (!_id.hasMatch(actor) ||
        !_id.hasMatch(target.id) ||
        !{'lost', 'found', 'sighting'}.contains(target.kind)) {
      throw const BlockFailure(BlockIssue.invalid);
    }
    return repository.prepare(actor, target);
  }
}

class SetUserBlock {
  const SetUserBlock(this.repository);
  final UserBlockRepository repository;
  Future<UserBlock> call(String actor, BlockChange change) {
    if (!_id.hasMatch(actor) ||
        !_id.hasMatch(change.entry.id) ||
        change.entry.version < 0 ||
        change.entry.version >= 2147483647) {
      throw const BlockFailure(BlockIssue.invalid);
    }
    return repository.set(actor, change);
  }
}
