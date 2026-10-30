import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/entities/auth_session.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/case_closure_repository.dart';
import '../domain/use_cases/closure_actions.dart';

final caseClosureRepositoryProvider = Provider<CaseClosureRepository>(
  (ref) => throw StateError('CaseClosureRepository must be injected'),
);
final closureSessionProvider = StreamProvider.autoDispose<AuthSession?>(
  (ref) => ref.watch(watchAuthSessionProvider)(),
  retry: (_, _) => null,
);
final readCaseClosureProvider = Provider(
  (ref) => ReadCaseClosure(ref.watch(caseClosureRepositoryProvider)),
);
final closeRecoveryCaseProvider = Provider(
  (ref) => CloseRecoveryCase(ref.watch(caseClosureRepositoryProvider)),
);
