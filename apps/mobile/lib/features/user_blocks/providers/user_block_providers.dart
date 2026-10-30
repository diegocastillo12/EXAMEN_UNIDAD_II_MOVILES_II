import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/entities/auth_session.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/user_block_repository.dart';
import '../domain/use_cases/user_block_actions.dart';

final userBlockRepositoryProvider = Provider<UserBlockRepository>(
  (ref) => throw StateError('UserBlockRepository must be injected'),
);
final blockSessionProvider = StreamProvider.autoDispose<AuthSession?>(
  (ref) => ref.watch(watchAuthSessionProvider)(),
  retry: (_, _) => null,
);
final readUserBlocksProvider = Provider(
  (ref) => ReadUserBlocks(ref.watch(userBlockRepositoryProvider)),
);
final prepareUserBlockProvider = Provider(
  (ref) => PrepareUserBlock(ref.watch(userBlockRepositoryProvider)),
);
final setUserBlockProvider = Provider(
  (ref) => SetUserBlock(ref.watch(userBlockRepositoryProvider)),
);
