import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/domain/entities/case_timeline.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/domain/repositories/case_timeline_repository.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/domain/use_cases/timeline_actions.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/providers/case_timeline_providers.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/presentation/screens/case_timeline_screen.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/presentation/screens/sighting_review_screen.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/presentation/view_models/case_timeline_view_model.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/presentation/view_models/sighting_review_view_model.dart';
import 'package:flutter_application_entrehuellas/features/case_timeline/presentation/state/case_timeline_state.dart';
import 'alert_preferences_test.dart' show loadFonts;

const timelineTarget = (
  id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa11',
  community: false,
);
const sightingId = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbb11';
const reviewKey = (target: timelineTarget, id: sightingId);
final observed = DateTime(2026, 10, 10, 10, 30),
    received = DateTime(2026, 10, 12, 12);
SightingReview testReview({
  int version = 0,
  bool open = true,
  List<SightingDecision> history = const [],
  int? next,
}) => SightingReview(
  id: sightingId,
  target: timelineTarget,
  canReview: open,
  observedAt: observed,
  receivedAt: received,
  late: true,
  comment: 'Caminaba por el parque con un collar azul.',
  latitude: -12.05,
  longitude: -77.04,
  locationSource: 'manual',
  accuracy: null,
  hasPhoto: true,
  state: history.isEmpty ? 'unreviewed' : history.first.state,
  revision: version,
  history: history,
  nextRevision: next,
);
TimelineEvent event(String key, DateTime at) => TimelineEvent(
  key: key,
  id: sightingId,
  kind: 'sighting',
  observedAt: at,
  receivedAt: received,
  late: true,
  comment: 'Caminaba por el parque',
  hasPhoto: true,
  reviewState: 'unreviewed',
  revision: 0,
);

class FakeTimeline implements CaseTimelineRepository {
  SightingReview current = testReview();
  TimelineIssue? readIssue, saveIssue;
  bool ambiguous = false, deny = false;
  final attempts = <ReviewCommand>[];
  final decisions = <String, SightingDecision>{};
  Completer<void>? pending, pendingRead;
  Completer<Uint8List?>? pendingPhoto;
  final image = img.encodeJpg(img.Image(width: 80, height: 60));
  @override
  Future<bool> canRead(String owner, TimelineTarget target) async => !deny;
  @override
  Future<TimelinePage> read(
    String owner,
    TimelineTarget target,
    TimelineCursor? cursor,
  ) async {
    await pendingRead?.future;
    if (deny) throw const TimelineFailure(TimelineIssue.forbidden);
    if (readIssue != null) throw TimelineFailure(readIssue!);
    return TimelinePage(
      'active',
      cursor == null
          ? [event('new', received), event('middle', observed)]
          : [event('middle', observed), event('old', DateTime(2026, 10, 9))],
      cursor == null ? TimelineCursor(observed, 'middle') : null,
    );
  }

  @override
  Future<SightingReview> detail(String owner, String id, int? before) async {
    await pendingRead?.future;
    if (deny) throw const TimelineFailure(TimelineIssue.forbidden);
    if (readIssue != null) throw TimelineFailure(readIssue!);
    return current;
  }

  @override
  Future<Uint8List?> evidence(String owner, String id) async =>
      pendingPhoto == null ? image : await pendingPhoto!.future;
  @override
  Future<SightingDecision> review(String owner, ReviewCommand command) async {
    attempts.add(command);
    await pending?.future;
    if (saveIssue != null) throw TimelineFailure(saveIssue!);
    if (deny) throw const TimelineFailure(TimelineIssue.forbidden);
    final previous = decisions[command.id];
    if (previous != null) return previous;
    if (command.expectedRevision != current.revision) {
      throw const TimelineFailure(TimelineIssue.conflict);
    }
    final decision = SightingDecision(
      commandId: command.id,
      sightingId: command.sightingId,
      revision: command.expectedRevision + 1,
      previousState: current.state,
      state: command.state,
      reason: command.reason,
      actorId: owner,
      reviewedAt: received,
    );
    decisions[command.id] = decision;
    current = current.withDecision(decision);
    if (ambiguous) {
      ambiguous = false;
      throw const TimelineFailure(TimelineIssue.unavailable);
    }
    return decision;
  }
}

ProviderContainer timelineContainer(
  FakeTimeline repository, {
  Stream<AuthSession?>? sessions,
}) => ProviderContainer(
  overrides: [
    caseTimelineRepositoryProvider.overrideWithValue(repository),
    timelineSessionProvider.overrideWith(
      (ref) => sessions ?? Stream.value(const AuthSession(userId: 'owner')),
    ),
  ],
);

class _Tiles extends TileProvider {
  final image = img.encodePng(img.Image(width: 256, height: 256));
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(image);
}

void main() {
  test(
    'All four classifications need a reason and a changed state; closed cases are read only',
    () {
      final action = ReviewSighting(FakeTimeline());
      for (final value in ['useful', 'doubtful', 'rejected', 'confirmed']) {
        action.validate(testReview(), value, 'Identifiqué el collar');
      }
      for (final reason in ['', 'x' * 501]) {
        expect(
          () => action.validate(testReview(), 'useful', reason),
          throwsA(isA<TimelineFailure>()),
        );
      }
      expect(
        () => action.validate(testReview(open: false), 'useful', 'Motivo'),
        throwsA(isA<TimelineFailure>()),
      );
      expect(
        () => action.validate(testReview(), 'unreviewed', 'Motivo'),
        throwsA(isA<TimelineFailure>()),
      );
    },
  );
  test(
    'Timeline pages keep observed order, deduplicate and preserve content on failed refresh',
    () async {
      final repository = FakeTimeline();
      final container = timelineContainer(repository);
      addTearDown(container.dispose);
      final provider = caseTimelineViewModelProvider(timelineTarget),
          sub = container.listen(
            caseTimelineViewModelProvider(timelineTarget),
            (_, _) {},
          );
      addTearDown(sub.close);
      await container.read(provider.future);
      final model = container.read(provider.notifier);
      await model.more();
      expect(
        container.read(provider).requireValue.page.items.map((e) => e.key),
        ['new', 'middle', 'old'],
      );
      repository.readIssue = TimelineIssue.unavailable;
      await model.refresh();
      expect(container.read(provider).requireValue.page.items.length, 3);
      repository.readIssue = null;
      repository.deny = true;
      await model.refresh();
      expect(container.read(provider).hasError, true);
    },
  );
  test(
    'Ambiguous save freezes command and only persisted receipt updates classification, blocking double submission',
    () async {
      final repository = FakeTimeline()..ambiguous = true;
      final c = timelineContainer(repository);
      addTearDown(c.dispose);
      final provider = sightingReviewViewModelProvider(reviewKey),
          sub = c.listen(sightingReviewViewModelProvider(reviewKey), (_, _) {});
      addTearDown(sub.close);
      await c.read(provider.future);
      final m = c.read(provider.notifier);
      m.select('confirmed');
      m.reason('La foto muestra el mismo collar');
      await m.save();
      final frozen = repository.attempts.single;
      expect(repository.current.state, 'confirmed');
      expect(c.read(provider).requireValue.detail.state, 'unreviewed');
      m.select('rejected');
      m.reason('Changed');
      expect(c.read(provider).requireValue.reason, frozen.reason);
      repository.pending = Completer<void>();
      final retry = m.save();
      await m.save();
      expect(repository.attempts.length, 2);
      expect(identical(repository.attempts.last, frozen), true);
      repository.pending!.complete();
      await retry;
      expect(c.read(provider).requireValue.saved, true);
      expect(c.read(provider).requireValue.detail.history.length, 1);
      expect(repository.decisions.length, 1);
    },
  );
  test(
    'Conflict requires explicit reload, preserves draft and survives other evidence operations',
    () async {
      final repo = FakeTimeline();
      final scope = timelineContainer(repo);
      addTearDown(scope.dispose);
      final p = sightingReviewViewModelProvider(reviewKey),
          sub = scope.listen(
            sightingReviewViewModelProvider(reviewKey),
            (_, _) {},
          );
      addTearDown(sub.close);
      await scope.read(p.future);
      final m = scope.read(p.notifier);
      m.select('useful');
      m.reason('Conserva este motivo');
      repo.saveIssue = TimelineIssue.conflict;
      await m.save();
      await m.evidence();
      await m.save();
      expect(repo.attempts.length, 1);
      repo.saveIssue = null;
      await m.refresh();
      expect(scope.read(p).requireValue.reason, 'Conserva este motivo');
      expect(scope.read(p).requireValue.frozen, isNull);
      await m.save();
      expect(repo.attempts.length, 2);
      expect(repo.attempts[0].id, isNot(repo.attempts[1].id));
    },
  );
  test(
    'Account switch drops a late review receipt and private photo',
    () async {
      final sessions = StreamController<AuthSession?>(),
          repo = FakeTimeline()..pending = Completer<void>();
      final c = timelineContainer(repo, sessions: sessions.stream);
      addTearDown(c.dispose);
      addTearDown(sessions.close);
      final p = sightingReviewViewModelProvider(reviewKey),
          sub = c.listen(sightingReviewViewModelProvider(reviewKey), (_, _) {});
      addTearDown(sub.close);
      sessions.add(const AuthSession(userId: 'owner'));
      await c.read(p.future);
      final m = c.read(p.notifier);
      m.select('doubtful');
      m.reason('Motivo');
      final saving = m.save();
      repo.deny = true;
      sessions.add(const AuthSession(userId: 'other'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await expectLater(c.read(p.future), throwsA(isA<TimelineFailure>()));
      repo.pending!.complete();
      await saving;
      expect(c.read(p).hasError, true);
    },
  );
  test(
    'Same account recovers after a session error; late photo after disposal is ignored',
    () async {
      final sessions = StreamController<AuthSession?>(), repo = FakeTimeline();
      final c = timelineContainer(repo, sessions: sessions.stream);
      addTearDown(c.dispose);
      addTearDown(sessions.close);
      final p = sightingReviewViewModelProvider(reviewKey),
          sub = c.listen(sightingReviewViewModelProvider(reviewKey), (_, _) {});
      sessions.add(const AuthSession(userId: 'owner'));
      await c.read(p.future);
      sessions.addError(Exception('Session unavailable'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(c.read(p).hasError, true);
      sessions.add(const AuthSession(userId: 'owner'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await c.read(p.future);
      repo.pendingPhoto = Completer<Uint8List?>();
      final request = c.read(p.notifier).evidence();
      sub.close();
      await c.pump();
      repo.pendingPhoto!.complete(repo.image);
      await request;
    },
  );
  for (final small in [false, true]) {
    testWidgets(
      'Timeline and review UI, saved audit and privacy message fit small=$small',
      (tester) async {
        await tester.runAsync(loadFonts);
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = FakeTimeline();
        final scope = timelineContainer(repo);
        addTearDown(scope.dispose);
        Widget app(Widget child) => UncontrolledProviderScope(
          container: scope,
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(small ? 2 : 1),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: RepaintBoundary(key: const ValueKey('capture'), child: child),
          ),
        );
        Future<void> capture(String name) async {
          await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
                  find.byKey(const ValueKey('capture')),
                ),
                image = await tester
                    .renderObject<RenderRepaintBoundary>(
                      find.byKey(const ValueKey('capture')),
                    )
                    .toImage();
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            final directory = Directory('build/ui-preview/case-timeline')
              ..createSync(recursive: true);
            File(
              '${directory.path}/${small ? 'small' : 'normal'}-$name.png',
            ).writeAsBytesSync(data!.buffer.asUint8List());
            image.dispose();
            expect(boundary.hasSize, true);
          });
        }

        await tester.pumpWidget(
          app(const CaseTimelineScreen(target: timelineTarget)),
        );
        await tester.pumpAndSettle();
        expect(find.text('Historial'), findsOneWidget);
        await capture('timeline');
        await tester.pumpWidget(
          app(
            SightingReviewScreen(
              reviewKey: reviewKey,
              createTileProvider: () => _Tiles(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Revisión'), findsOneWidget);
        await capture('detail');
        await tester.ensureVisible(find.text('Ver foto'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ver foto'));
        await tester.runAsync(
          () => precacheImage(
            MemoryImage(repo.image),
            tester.element(find.byType(SightingReviewScreen)),
          ),
        );
        await tester.pumpAndSettle();
        final photo = find.byWidgetPredicate(
          (w) =>
              w is Image && w.semanticLabel == 'Foto adjunta al avistamiento',
        );
        expect(photo, findsOneWidget);
        expect(tester.getSize(photo).height, lessThanOrEqualTo(320));
        await tester.ensureVisible(photo);
        await tester.pumpAndSettle();
        await capture('photo');
        await tester.ensureVisible(find.text('Guardar revisión'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Guardar revisión'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          find.text(timelineFailureLabel(TimelineIssue.invalid)),
          findsOneWidget,
        );
        final m = scope.read(
          sightingReviewViewModelProvider(reviewKey).notifier,
        );
        m.select('confirmed');
        m.reason('Identifiqué su collar azul.');
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Guardar revisión'));
        await tester.pumpAndSettle();
        await capture('editor');
        await tester.tap(find.text('Guardar revisión'));
        await tester.pumpAndSettle();
        expect(find.text('Revisión guardada'), findsOneWidget);
        expect(repo.current.history.single.state, 'confirmed');
        await tester.ensureVisible(find.text('Responsable del caso'));
        await tester.pumpAndSettle();
        await capture('history');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}
