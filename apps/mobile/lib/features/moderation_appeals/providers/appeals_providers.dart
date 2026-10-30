import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/entities/auth_session.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/appeals_repository.dart';
import '../domain/use_cases/appeal_actions.dart';

final appealsRepositoryProvider = Provider<AppealsRepository>(
  (ref) => throw StateError('AppealsRepository must be injected'),
);
final appealsSessionProvider = StreamProvider.autoDispose<AuthSession?>(
  (ref) => ref.watch(watchAuthSessionProvider)(),
  retry: (_, _) => null,
);
final readAppealsProvider = Provider(
  (ref) => ReadAppeals(ref.watch(appealsRepositoryProvider)),
);
final submitAppealProvider = Provider(
  (ref) => SubmitAppeal(ref.watch(appealsRepositoryProvider)),
);
