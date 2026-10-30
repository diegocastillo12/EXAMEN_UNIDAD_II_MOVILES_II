import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/auth_repository.dart';
import '../domain/use_cases/watch_auth_session.dart';
import '../domain/repositories/access_repository.dart';
import '../domain/use_cases/sign_in.dart';
import '../domain/use_cases/sign_out.dart';

/// The app composition root supplies the concrete repository.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw StateError('AuthRepository must be injected at app startup.'),
);

final watchAuthSessionProvider = Provider<WatchAuthSession>(
  (ref) => WatchAuthSession(ref.watch(authRepositoryProvider)),
);

final accessRepositoryProvider = Provider<AccessRepository>(
  (ref) => throw StateError('AccessRepository must be injected.'),
);
final signInProvider = Provider<SignIn>(
  (ref) => SignIn(ref.watch(accessRepositoryProvider)),
);
final signOutProvider = Provider<SignOut>(
  (ref) => SignOut(ref.watch(accessRepositoryProvider)),
);

final authSessionProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(watchAuthSessionProvider)(),
  retry: (_, _) => null,
);
