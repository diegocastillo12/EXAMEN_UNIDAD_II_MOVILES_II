import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/case_closure/domain/entities/case_closure.dart';
import 'package:flutter_application_entrehuellas/features/case_closure/domain/repositories/case_closure_repository.dart';
import 'package:flutter_application_entrehuellas/features/case_closure/domain/use_cases/closure_actions.dart';
import 'package:flutter_application_entrehuellas/features/case_closure/data/data_sources/case_closure_source.dart';
import 'package:flutter_application_entrehuellas/features/case_closure/data/repositories/case_closure_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/case_closure/providers/case_closure_providers.dart';
import 'package:flutter_application_entrehuellas/features/case_closure/presentation/view_models/case_closure_view_model.dart';
import 'package:flutter_application_entrehuellas/features/case_closure/presentation/screens/case_closure_screen.dart';
import 'alert_preferences_test.dart' show loadFonts;

const target = (id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa13', community: false);

class FakeClosure implements CaseClosureRepository {
  final attempts = <ClosureCommand>[];
  ClosureReceipt? receipt;
  ClosureIssue? saveIssue, readIssue;
  bool ambiguous = false;
  Completer<void>? pending;
  @override
  Future<ClosureDetail> read(String owner, ClosureTarget target) async {
    if (readIssue != null) throw ClosureFailure(readIssue!);
    return ClosureDetail(closed: receipt != null, receipt: receipt);
  }

  @override
  Future<ClosureReceipt> close(String owner, ClosureCommand command) async {
    attempts.add(command);
    await pending?.future;
    if (saveIssue != null) throw ClosureFailure(saveIssue!);
    receipt ??= ClosureReceipt(
      commandId: command.id,
      target: command.target,
      actor: owner,
      closedAt: DateTime.utc(2026, 10, 18, 17),
      reason: command.reason,
      evidence: command.evidence.isEmpty ? null : command.evidence,
    );
    if (ambiguous) throw const ClosureFailure(ClosureIssue.unavailable);
    return receipt!;
  }
}

ProviderContainer container(
  FakeClosure repo, {
  Stream<AuthSession?>? sessions,
}) => ProviderContainer(
  overrides: [
    caseClosureRepositoryProvider.overrideWithValue(repo),
    closureSessionProvider.overrideWith(
      (ref) => sessions ?? Stream.value(const AuthSession(userId: 'owner')),
    ),
  ],
);

class FakeSource implements CaseClosureSource {
  Object? result;
  String? failure;
  Map<String, dynamic>? params;
  @override
  Future<Object?> call(
    String owner,
    String function,
    Map<String, dynamic> params,
  ) async {
    this.params = params;
    if (failure != null) throw ClosureSourceFailure(failure!);
    return result;
  }
}

void main() {
  test(
    'Recovery needs a reason, accepts optional testimony and counts Unicode scalars',
    () async {
      final repo = FakeClosure(), action = CloseRecoveryCase(FakeClosure());
      for (final reason in ['', '\u00a0\u3000', 'x' * 501]) {
        expect(
          () => action.validate(reason, ''),
          throwsA(isA<ClosureFailure>()),
        );
      }
      action.validate('🐾' * 500, '');
      expect(
        () => action.validate('Recuperada', '🐾' * 501),
        throwsA(isA<ClosureFailure>()),
      );
      expect(
        () => CloseRecoveryCase(repo)(
          '',
          const ClosureCommand(
            id: 'c',
            target: target,
            reason: 'Recuperada',
            evidence: '',
          ),
        ),
        throwsA(isA<ClosureFailure>()),
      );
      expect(repo.attempts, isEmpty);
    },
  );
  test(
    'Repository maps private receipt, trims fields, rejects mismatched receipts and hides SDK messages',
    () async {
      final source = FakeSource(),
          repo = CaseClosureRepositoryImpl(FakeSource());
      final data = {
        'command_id': 'c',
        'case_source': 'lost',
        'case_id': target.id,
        'actor_id': 'owner',
        'closed_at': '2026-10-18T17:00:00Z',
        'reason': 'Volvió',
        'evidence_note': null,
      };
      source.result = data;
      final actual = CaseClosureRepositoryImpl(source);
      const command = ClosureCommand(
        id: 'c',
        target: target,
        reason: ' Volvió ',
        evidence: ' ',
      );
      expect((await actual.close('owner', command)).reason, 'Volvió');
      expect(source.params!['p_evidence_note'], isNull);
      source.result = {...data, 'actor_id': 'other'};
      await expectLater(
        actual.close('owner', command),
        throwsA(
          isA<ClosureFailure>().having(
            (e) => e.issue,
            'issue',
            ClosureIssue.unavailable,
          ),
        ),
      );
      source.failure = 'forbidden';
      await expectLater(
        actual.read('owner', target),
        throwsA(
          isA<ClosureFailure>().having(
            (e) => e.issue,
            'issue',
            ClosureIssue.forbidden,
          ),
        ),
      );
      source.failure = 'raw secret failure';
      await expectLater(
        actual.close('owner', command),
        throwsA(
          isA<ClosureFailure>().having(
            (e) => e.issue,
            'issue',
            ClosureIssue.unavailable,
          ),
        ),
      );
      await expectLater(
        repo.read('owner', target),
        throwsA(isA<ClosureFailure>()),
      );
    },
  );
  test(
    'Ambiguous closure freezes the same command, blocks double submission and confirms only the persisted receipt',
    () async {
      final repo = FakeClosure()..ambiguous = true;
      final scope = container(repo);
      addTearDown(scope.dispose);
      final provider = caseClosureViewModelProvider(target),
          sub = scope.listen(provider, (_, _) {});
      addTearDown(sub.close);
      await scope.read(provider.future);
      final model = scope.read(provider.notifier);
      model.edit(
        reason: 'La reconocí y volvió a casa',
        evidence: 'Su collar azul',
      );
      expect(await model.save(), false);
      expect(scope.read(provider).requireValue.saved, false);
      final frozen = scope.read(provider).requireValue.frozen!;
      model.edit(reason: 'No reemplazar el motivo');
      expect(scope.read(provider).requireValue.reason, frozen.reason);
      repo.ambiguous = false;
      repo.pending = Completer<void>();
      final saving = model.save();
      expect(await model.save(), false);
      repo.pending!.complete();
      expect(await saving, true);
      expect(repo.attempts.length, 2);
      expect(identical(repo.attempts[0], repo.attempts[1]), true);
      expect(
        scope.read(provider).requireValue.detail.receipt!.commandId,
        frozen.id,
      );
      expect(scope.read(provider).requireValue.saved, true);
    },
  );
  test(
    'A competing closure requires reading its receipt; refresh preserves the draft on failure',
    () async {
      final repo = FakeClosure()..saveIssue = ClosureIssue.closed;
      final c = container(repo);
      addTearDown(c.dispose);
      final p = caseClosureViewModelProvider(target),
          sub = c.listen(p, (_, _) {});
      addTearDown(sub.close);
      await c.read(p.future);
      final m = c.read(p.notifier);
      m.edit(reason: 'Volvió');
      expect(await m.save(), false);
      expect(await m.save(), false);
      expect(repo.attempts.length, 1);
      repo.readIssue = ClosureIssue.unavailable;
      await m.refresh();
      expect(c.read(p).requireValue.reason, 'Volvió');
      repo.readIssue = null;
      repo.receipt = ClosureReceipt(
        commandId: 'other',
        target: target,
        actor: 'owner',
        closedAt: DateTime.utc(2026),
        reason: 'Cierre de otra sesión',
      );
      await m.refresh();
      expect(
        c.read(p).requireValue.detail.receipt!.reason,
        'Cierre de otra sesión',
      );
      expect(c.read(p).requireValue.frozen, isNull);
      expect(await m.save(), false);
    },
  );
  test(
    'Session changes, session errors and disposal discard late confirmations',
    () async {
      final repo = FakeClosure(),
          sessions = StreamController<AuthSession?>.broadcast();
      final c = container(repo, sessions: sessions.stream);
      addTearDown(c.dispose);
      addTearDown(sessions.close);
      final p = caseClosureViewModelProvider(target),
          sub = c.listen(p, (_, _) {});
      addTearDown(sub.close);
      sessions.add(const AuthSession(userId: 'owner'));
      await c.read(p.future);
      final m = c.read(p.notifier);
      m.edit(reason: 'Volvió');
      repo.pending = Completer<void>();
      final save = m.save();
      sessions.addError(StateError('offline'));
      await Future<void>.delayed(Duration.zero);
      repo.pending!.complete();
      expect(await save, false);
      await expectLater(c.read(p.future), throwsA(anything));
      sessions.add(const AuthSession(userId: 'owner'));
      await Future<void>.delayed(Duration.zero);
      await c.read(p.future);
      expect(c.read(p).requireValue.reason, isEmpty);
      repo.receipt = null;
      m.edit(reason: 'Volvió');
      repo.pending = Completer<void>();
      final late = m.save();
      sessions.add(const AuthSession(userId: 'other'));
      await Future<void>.delayed(Duration.zero);
      await c.read(p.future);
      repo.pending!.complete();
      expect(await late, false);
      expect(c.read(p).requireValue.owner, 'other');
      expect(c.read(p).requireValue.saved, false);
      repo.receipt = null;
      m.edit(reason: 'Volvió');
      repo.pending = Completer<void>();
      final disposed = m.save();
      c.dispose();
      repo.pending!.complete();
      expect(await disposed, false);
    },
  );
  for (final small in [false, true]) {
    testWidgets(
      'Recovery form, validation, confirmation and private receipt ${small ? 'small' : 'normal'}',
      (tester) async {
        await tester.runAsync(loadFonts);
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = FakeClosure();
        final c = container(repo);
        addTearDown(c.dispose);
        int saves = 0;
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
              home: RepaintBoundary(
                key: const ValueKey('capture'),
                child: CaseClosureScreen(
                  target: target,
                  onSaved: () => saves++,
                ),
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
            final dir = Directory('build/ui-preview/case-closure')
              ..createSync(recursive: true);
            File(
              '${dir.path}/${small ? 'small' : 'normal'}-$name.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        await capture('form');
        await tester.ensureVisible(find.byType(TextField).last);
        await tester.pumpAndSettle();
        await capture('form-fields');
        final p = caseClosureViewModelProvider(target), m = c.read(p.notifier);
        expect(await m.save(), false);
        await tester.pumpAndSettle();
        expect(repo.attempts, isEmpty);
        m.edit(
          reason: 'La reconocí por su collar y regresó a casa.',
          evidence: 'La entregaron en la puerta de casa.',
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Confirmar recuperación'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirmar recuperación'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Confirmar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();
        expect(saves, 1);
        expect(find.text('Búsqueda finalizada'), findsOneWidget);
        await capture('receipt');
        await tester.ensureVisible(find.textContaining('Evidencia adicional:'));
        await tester.pumpAndSettle();
        await capture('receipt-bottom');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
