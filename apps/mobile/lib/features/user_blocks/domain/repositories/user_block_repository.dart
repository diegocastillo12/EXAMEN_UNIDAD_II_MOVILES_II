import '../entities/user_block.dart';

abstract interface class UserBlockRepository {
  Future<UserBlock?> prepare(String actor, BlockTarget target);
  Future<UserBlockPage> list(String actor, String? before);
  Future<UserBlock> set(String actor, BlockChange change);
}
