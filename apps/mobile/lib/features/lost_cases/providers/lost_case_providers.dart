import '../domain/use_cases/delete_lost_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/lost_case_repository.dart';
import '../domain/use_cases/publish_lost_case.dart';
import '../domain/use_cases/read_lost_cases.dart';

final lostCaseRepositoryProvider = Provider<LostCaseRepository>(
  (ref) => throw StateError('LostCaseRepository must be injected.'),
);
final publishLostCaseProvider = Provider(
  (ref) => PublishLostCase(ref.watch(lostCaseRepositoryProvider)),
);
final readPublicLostCaseProvider = Provider(
  (ref) => ReadPublicLostCase(ref.watch(lostCaseRepositoryProvider)),
);
final listMyLostCasesProvider = Provider(
  (ref) => ListMyLostCases(ref.watch(lostCaseRepositoryProvider)),
);
final caseSessionProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(watchAuthSessionProvider)(),
);

final deletePublishedLostCaseProvider = Provider(
  (ref) => DeletePublishedLostCase(ref.watch(lostCaseRepositoryProvider)),
);
