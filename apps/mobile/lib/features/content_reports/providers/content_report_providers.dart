import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/entities/auth_session.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/content_report_repository.dart';
import '../domain/use_cases/submit_content_report.dart';

final contentReportRepositoryProvider = Provider<ContentReportRepository>(
  (ref) => throw StateError('ContentReportRepository must be injected'),
);
final reportSessionProvider = StreamProvider.autoDispose<AuthSession?>(
  (ref) => ref.watch(watchAuthSessionProvider)(),
  retry: (_, _) => null,
);
final submitContentReportProvider = Provider(
  (ref) => SubmitContentReport(ref.watch(contentReportRepositoryProvider)),
);
