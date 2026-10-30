import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/content_reports/domain/entities/content_report.dart';
import 'package:flutter_application_entrehuellas/features/content_reports/domain/repositories/content_report_repository.dart';
import 'package:flutter_application_entrehuellas/features/content_reports/domain/use_cases/submit_content_report.dart';
import 'package:flutter_application_entrehuellas/features/content_reports/data/data_sources/content_report_source.dart';
import 'package:flutter_application_entrehuellas/features/content_reports/data/repositories/content_report_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/content_reports/providers/content_report_providers.dart';
import 'package:flutter_application_entrehuellas/features/content_reports/presentation/view_models/content_report_view_model.dart';
import 'package:flutter_application_entrehuellas/features/content_reports/presentation/screens/content_report_screen.dart';
import 'alert_preferences_test.dart' show loadFonts;

const reportTarget = (kind: 'lost', id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa29');
const commandId = 'cccccccc-cccc-4ccc-8ccc-cccccccccc29';

class FakeReports implements ContentReportRepository {
  final attempts = <ReportCommand>[];
  ReportReceipt? receipt;
  ReportIssue? issue;
  bool ambiguous = false;
  Completer<void>? pending;
  @override
  Future<ReportReceipt> submit(String actor, ReportCommand command) async {
    attempts.add(command);
    await pending?.future;
    if (issue != null) throw ReportFailure(issue!);
    receipt ??= ReportReceipt(
      id: command.id,
      actor: actor,
      target: command.target,
      reason: command.reason,
      evidence: command.evidence.isEmpty ? null : command.evidence,
      submittedAt: DateTime.utc(2026, 10, 18, 17),
    );
    if (ambiguous) throw const ReportFailure(ReportIssue.unavailable);
    return receipt!;
  }
}

ProviderContainer reportContainer(
  FakeReports repo, {
  Stream<AuthSession?>? sessions,
}) => ProviderContainer(
  overrides: [
    contentReportRepositoryProvider.overrideWithValue(repo),
    reportSessionProvider.overrideWith(
      (ref) => sessions ?? Stream.value(const AuthSession(userId: 'actor')),
    ),
  ],
);

class FakeReportSource implements ContentReportSource {
  Object? result;
  String? failure;
  Map<String, dynamic>? params;
  @override
  Future<Object?> submit(String actor, Map<String, dynamic> params) async {
    this.params = params;
    if (failure != null) throw ReportSourceFailure(failure!);
    return result;
  }
}

void main() {
  test(
    'Domain validates required reason, Unicode limits, actor and stable resource identifiers',
    () async {
      final repo = FakeReports(), action = SubmitContentReport(FakeReports());
      for (final reason in ['', '\u00a0\u3000', '🐾' * 501]) {
        expect(
          () => action.validate(reason, ''),
          throwsA(isA<ReportFailure>()),
        );
      }
      action.validate('🐾' * 500, '🐾' * 1000);
      expect(
        () => action.validate('Motivo', '🐾' * 1001),
        throwsA(isA<ReportFailure>()),
      );
      expect(
        () => SubmitContentReport(repo)(
          '',
          const ReportCommand(
            id: commandId,
            target: reportTarget,
            reason: 'Motivo',
            evidence: '',
          ),
        ),
        throwsA(isA<ReportFailure>()),
      );
      expect(
        () => SubmitContentReport(repo)(
          'actor',
          const ReportCommand(
            id: 'invalid',
            target: reportTarget,
            reason: 'Motivo',
            evidence: '',
          ),
        ),
        throwsA(isA<ReportFailure>()),
      );
      expect(repo.attempts, isEmpty);
    },
  );
  test(
    'Repository validates the persisted receipt and maps infrastructure errors safely',
    () async {
      final source = FakeReportSource(),
          repo = ContentReportRepositoryImpl(FakeReportSource());
      final actual = ContentReportRepositoryImpl(source);
      const command = ReportCommand(
        id: commandId,
        target: reportTarget,
        reason: ' Motivo ',
        evidence: ' Detalles ',
      );
      final row = {
        'id': commandId,
        'reporter_id': 'actor',
        'resource_kind': 'lost',
        'resource_id': reportTarget.id,
        'reason': 'Motivo',
        'evidence_note': 'Detalles',
        'submitted_at': '2026-10-18T17:00:00Z',
      };
      source.result = row;
      expect((await actual.submit('actor', command)).id, commandId);
      expect(source.params!['p_reason'], 'Motivo');
      for (final entry in {
        'reporter_id': 'other',
        'resource_kind': 'found',
        'id': 'other',
        'resource_id': 'other',
        'reason': 'changed',
        'evidence_note': 'changed',
        'submitted_at': 'invalid',
      }.entries) {
        source.result = {...row, entry.key: entry.value};
        await expectLater(
          actual.submit('actor', command),
          throwsA(
            isA<ReportFailure>().having(
              (e) => e.issue,
              'issue',
              ReportIssue.unavailable,
            ),
          ),
        );
      }
      for (final issue in ReportIssue.values) {
        source.failure = issue.name;
        await expectLater(
          actual.submit('actor', command),
          throwsA(isA<ReportFailure>().having((e) => e.issue, 'issue', issue)),
        );
      }
      source.failure = 'raw secret error';
      await expectLater(
        actual.submit('actor', command),
        throwsA(
          isA<ReportFailure>().having(
            (e) => e.issue,
            'issue',
            ReportIssue.unavailable,
          ),
        ),
      );
      await expectLater(
        repo.submit('actor', command),
        throwsA(isA<ReportFailure>()),
      );
    },
  );
  test(
    'Ambiguous submission freezes payload, prevents duplicates and confirms only after receipt',
    () async {
      final repo = FakeReports()..ambiguous = true;
      final scope = reportContainer(repo);
      addTearDown(scope.dispose);
      final provider = contentReportViewModelProvider(reportTarget),
          sub = scope.listen(
            contentReportViewModelProvider(reportTarget),
            (_, _) {},
          );
      addTearDown(sub.close);
      await scope.read(provider.future);
      final model = scope.read(provider.notifier);
      expect(await model.submit(), false);
      expect(repo.attempts, isEmpty);
      model.edit(reason: 'Contenido engañoso', evidence: 'Detalles privados');
      expect(await model.submit(), false);
      expect(scope.read(provider).requireValue.receipt, isNull);
      final frozen = scope.read(provider).requireValue.frozen!;
      model.edit(reason: 'No reemplazar');
      expect(scope.read(provider).requireValue.reason, frozen.reason);
      repo.ambiguous = false;
      repo.pending = Completer<void>();
      final save = model.submit();
      expect(await model.submit(), false);
      repo.pending!.complete();
      expect(await save, true);
      expect(identical(repo.attempts[0], repo.attempts[1]), true);
      expect(await model.submit(), false);
      expect(scope.read(provider).requireValue.receipt!.id, frozen.id);
    },
  );
  test(
    'Conflict freezes further submissions; invalid input allows editing',
    () async {
      final repo = FakeReports()..issue = ReportIssue.invalid;
      final scope = reportContainer(repo);
      addTearDown(scope.dispose);
      final p = contentReportViewModelProvider(reportTarget),
          sub = scope.listen(
            contentReportViewModelProvider(reportTarget),
            (_, _) {},
          );
      addTearDown(sub.close);
      await scope.read(p.future);
      final m = scope.read(p.notifier);
      m.edit(reason: 'Motivo');
      expect(await m.submit(), false);
      expect(scope.read(p).requireValue.editable, true);
      repo.issue = ReportIssue.conflict;
      expect(await m.submit(), false);
      expect(await m.submit(), false);
      expect(scope.read(p).requireValue.editable, false);
      expect(repo.attempts.length, 2);
    },
  );
  test(
    'Session error, same-account recovery, identity change and disposal discard late responses',
    () async {
      final repo = FakeReports(),
          sessions = StreamController<AuthSession?>.broadcast();
      final scope = reportContainer(repo, sessions: sessions.stream);
      addTearDown(scope.dispose);
      addTearDown(sessions.close);
      final p = contentReportViewModelProvider(reportTarget),
          sub = scope.listen(
            contentReportViewModelProvider(reportTarget),
            (_, _) {},
          );
      addTearDown(sub.close);
      sessions.add(const AuthSession(userId: 'actor'));
      await scope.read(p.future);
      final m = scope.read(p.notifier);
      m.edit(reason: 'Motivo');
      repo.pending = Completer<void>();
      final save = m.submit();
      sessions.addError(StateError('offline'));
      await Future<void>.delayed(Duration.zero);
      repo.pending!.complete();
      expect(await save, false);
      await expectLater(scope.read(p.future), throwsA(anything));
      sessions.add(const AuthSession(userId: 'actor'));
      await Future<void>.delayed(Duration.zero);
      await scope.read(p.future);
      expect(scope.read(p).requireValue.reason, isEmpty);
      repo.receipt = null;
      repo.pending = Completer<void>();
      m.edit(reason: 'Motivo');
      final late = m.submit();
      sessions.add(const AuthSession(userId: 'other'));
      await Future<void>.delayed(Duration.zero);
      await scope.read(p.future);
      repo.pending!.complete();
      expect(await late, false);
      expect(scope.read(p).requireValue.actor, 'other');
      expect(scope.read(p).requireValue.receipt, isNull);
      repo.receipt = null;
      repo.pending = Completer<void>();
      m.edit(reason: 'Otro');
      final disposed = m.submit();
      scope.dispose();
      repo.pending!.complete();
      expect(await disposed, false);
    },
  );
  for (final small in [false, true]) {
    testWidgets(
      'Form, validation and private receipt ${small ? 'small' : 'normal'}',
      (tester) async {
        await tester.runAsync(loadFonts);
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = FakeReports();
        final c = reportContainer(repo);
        addTearDown(c.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: c,
            child: MaterialApp(
              theme: AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(small ? 2 : 1),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: const RepaintBoundary(
                key: ValueKey('capture'),
                child: ContentReportScreen(target: reportTarget),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        Future<void> capture(String name) async {
          await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
                  find.byKey(const ValueKey('capture')),
                ),
                image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final dir = Directory('build/ui-preview/content-reports')
              ..createSync(recursive: true);
            File(
              '${dir.path}/${small ? 'small' : 'normal'}-$name.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        await capture('form');
        final m = c.read(contentReportViewModelProvider(reportTarget).notifier);
        expect(await m.submit(), false);
        await tester.pumpAndSettle();
        expect(repo.attempts, isEmpty);
        await tester.ensureVisible(find.byType(TextField).first);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextField).first,
          'Contenido engañoso',
        );
        await tester.ensureVisible(find.byType(TextField).last);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextField).last,
          'El texto anuncia información falsa.',
        );
        await tester.pumpAndSettle();
        await capture('fields');
        await tester.ensureVisible(find.text('Enviar denuncia'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Enviar denuncia'));
        await tester.pumpAndSettle();
        expect(find.text('Denuncia registrada'), findsOneWidget);
        expect(repo.attempts.length, 1);
        await capture('receipt');
        await tester.ensureVisible(find.textContaining('Referencia:'));
        await tester.pumpAndSettle();
        await capture('receipt-bottom');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
