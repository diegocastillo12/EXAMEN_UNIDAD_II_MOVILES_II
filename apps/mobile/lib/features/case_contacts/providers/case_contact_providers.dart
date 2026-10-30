import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/case_contact_repository.dart';
import '../domain/use_cases/case_contact_actions.dart';

final caseContactRepositoryProvider = Provider<CaseContactRepository>(
  (ref) => throw StateError('CaseContactRepository must be injected'),
);
final readCaseContactProvider = Provider(
  (ref) => ReadCaseContact(ref.watch(caseContactRepositoryProvider)),
);
final saveCaseContactProvider = Provider(
  (ref) => SaveCaseContact(ref.watch(caseContactRepositoryProvider)),
);
final openCaseContactProvider = Provider(
  (ref) => OpenCaseContact(ref.watch(caseContactRepositoryProvider)),
);
final caseContactSessionProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(watchAuthSessionProvider)(),
  retry: (_, _) => null,
);
