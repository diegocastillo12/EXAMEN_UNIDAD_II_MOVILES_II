import 'support/fake_local_drafts.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/providers/local_draft_providers.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/sightings/domain/entities/sighting.dart';
import 'package:flutter_application_entrehuellas/features/sightings/domain/repositories/sighting_repository.dart';
import 'package:flutter_application_entrehuellas/features/sightings/domain/use_cases/sighting_actions.dart';
import 'package:flutter_application_entrehuellas/features/sightings/providers/sighting_providers.dart';
import 'package:flutter_application_entrehuellas/features/sightings/presentation/screens/sighting_screen.dart';
import 'package:flutter_application_entrehuellas/features/sightings/presentation/view_models/sighting_view_model.dart';
import 'alert_preferences_test.dart' show loadFonts;

class FakeSightings implements SightingRepository {
  final attempts = <SightingDraft>[];
  SightingIssue? issue;
  Completer<void>? pending;
  bool denyLocation = true, cancelPhoto = true;
  @override
  Future<SightingReceipt> submit(String owner, SightingDraft draft) async {
    attempts.add(draft);
    await pending?.future;
    if (issue != null) throw SightingFailure(issue!);
    return SightingReceipt(draft.id, DateTime.now(), true);
  }

  @override
  Future<SightingPoint> locate() async {
    if (denyLocation) throw const SightingFailure(SightingIssue.location);
    return const SightingPoint(-12, -77, accuracy: 20);
  }

  @override
  Future<Uint8List?> choosePhoto({required bool camera}) async {
    if (cancelPhoto) return null;
    throw const SightingFailure(SightingIssue.photo);
  }
}

class _MemoryTiles extends TileProvider {
  final bytes = img.encodePng(img.Image(width: 256, height: 256));
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(bytes);
}

const target = SightingTarget('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa25', false);
ProviderContainer containerFor(
  FakeSightings repository, {
  Stream<AuthSession?>? sessions,
}) => ProviderContainer(
  overrides: [
    localDraftRepositoryProvider.overrideWithValue(FakeLocalDrafts()),
    sightingRepositoryProvider.overrideWithValue(repository),
    sightingTargetProvider.overrideWithValue(target),
    sightingSessionProvider.overrideWith(
      (ref) => sessions ?? Stream.value(const AuthSession(userId: 'owner')),
    ),
  ],
);
void fill(SightingViewModel m) {
  m.date(DateTime(2026, 1, 1));
  m.time(10, 30);
  m.point(-12.123, -77.123);
}

void main() {
  test(
    'Future dates, invalid points and long comments fail without a write; optional comment/photo accepted',
    () async {
      final repo = FakeSightings();
      final action = SubmitSighting(repo);
      SightingDraft draft({
        DateTime? date,
        SightingPoint? point,
        String comment = '',
      }) => SightingDraft(
        id: 'id',
        target: target,
        observedAt: date ?? DateTime(2026),
        point: point ?? const SightingPoint(-12, -77),
        comment: comment,
      );
      for (final value in [
        draft(date: DateTime(2100)),
        draft(point: const SightingPoint(double.nan, -77)),
        draft(comment: 'a' * 501),
      ]) {
        await expectLater(
          action('owner', value),
          throwsA(isA<SightingFailure>()),
        );
      }
      expect(repo.attempts, isEmpty);
      await SubmitSighting(repo)('owner', draft());
      expect(repo.attempts.single.photo, isNull);
    },
  );
  test(
    'Ambiguous response freezes exact payload; retry preserves id and double submit is blocked',
    () async {
      final repo = FakeSightings()..issue = SightingIssue.unavailable;
      final c = containerFor(repo);
      addTearDown(c.dispose);
      final subscription = c.listen(sightingViewModelProvider, (_, _) {});
      addTearDown(subscription.close);
      await c.read(sightingViewModelProvider.future);
      final m = c.read(sightingViewModelProvider.notifier);
      fill(m);
      m.comment('La vi en la plaza');
      await m.submit();
      final first = repo.attempts.single;
      expect(c.read(sightingViewModelProvider).requireValue.receipt, isNull);
      m.comment('changed');
      m.point(1, 2);
      expect(
        c.read(sightingViewModelProvider).requireValue.comment,
        first.comment,
      );
      repo.issue = null;
      repo.pending = Completer<void>();
      final retry = m.submit();
      await m.submit();
      await Future<void>.delayed(Duration.zero);
      expect(repo.attempts.length, 2);
      expect(repo.attempts.last.id, first.id);
      expect(repo.attempts.last.observedAt, first.observedAt);
      expect(repo.attempts.last.comment, first.comment);
      expect(repo.attempts.last.point.latitude, first.point.latitude);
      expect(repo.attempts.last.photo, first.photo);
      repo.pending!.complete();
      await retry;
      expect(
        c.read(sightingViewModelProvider).requireValue.receipt!.id,
        first.id,
      );
      await m.submit();
      expect(repo.attempts.length, 2);
    },
  );
  test(
    'GPS denial preserves manual location and photo cancellation preserves draft',
    () async {
      final c = containerFor(FakeSightings());
      addTearDown(c.dispose);
      final sub = c.listen(sightingViewModelProvider, (_, _) {});
      addTearDown(sub.close);
      await c.read(sightingViewModelProvider.future);
      final m = c.read(sightingViewModelProvider.notifier);
      fill(m);
      await m.locate();
      expect(
        c.read(sightingViewModelProvider).requireValue.point!.source,
        'manual',
      );
      expect(
        c.read(sightingViewModelProvider).requireValue.issue,
        SightingIssue.location,
      );
      await m.photo(camera: true);
      expect(c.read(sightingViewModelProvider).requireValue.photo, isNull);
      await m.submit();
      expect(c.read(sightingViewModelProvider).requireValue.receipt, isNotNull);
    },
  );
  test('Closed case keeps fields and blocks another submission', () async {
    final repo = FakeSightings()..issue = SightingIssue.closed;
    final c = containerFor(repo);
    addTearDown(c.dispose);
    final sub = c.listen(sightingViewModelProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(sightingViewModelProvider.future);
    final m = c.read(sightingViewModelProvider.notifier);
    fill(m);
    m.comment('Keep');
    await m.submit();
    await m.submit();
    expect(repo.attempts.length, 1);
    expect(c.read(sightingViewModelProvider).requireValue.comment, 'Keep');
    expect(c.read(sightingViewModelProvider).requireValue.receipt, isNull);
  });
  test(
    'Account change discards a late receipt and clears private draft',
    () async {
      final stream = StreamController<AuthSession?>();
      final repo = FakeSightings()..pending = Completer<void>();
      final c = containerFor(repo, sessions: stream.stream);
      addTearDown(c.dispose);
      addTearDown(stream.close);
      final sub = c.listen(sightingViewModelProvider, (_, _) {});
      addTearDown(sub.close);
      stream.add(const AuthSession(userId: 'owner'));
      await c.read(sightingViewModelProvider.future);
      final m = c.read(sightingViewModelProvider.notifier);
      fill(m);
      m.comment('Private');
      final submit = m.submit();
      stream.add(const AuthSession(userId: 'second'));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await c.read(sightingViewModelProvider.future);
      repo.pending!.complete();
      await submit;
      final state = c.read(sightingViewModelProvider).requireValue;
      expect(state.owner, 'second');
      expect(state.comment, isEmpty);
      expect(state.point, isNull);
      expect(state.receipt, isNull);
    },
  );
  for (final small in [false, true]) {
    testWidgets(
      'Form, validation toast and all actions fit ${small ? 'small with enlarged text' : 'normal'}',
      (tester) async {
        await tester.runAsync(loadFonts);
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final c = containerFor(FakeSightings());
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
              home: RepaintBoundary(
                key: const ValueKey('capture'),
                child: SightingScreen(createTileProvider: () => _MemoryTiles()),
              ),
            ),
          ),
        );
        for (var i = 0; i < 40; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(find.text('La vi'), findsOneWidget);
        expect(find.text('Comentario (opcional)'), findsOneWidget);
        final directory = Directory('build/ui-preview/android-sightings')
          ..createSync(recursive: true);
        Future<void> capture(String stage) async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('capture')),
          );
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File(
            '${directory.path}/${small ? 'small' : 'normal'}-$stage.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        }

        await tester.runAsync(() => capture('top'));
        await tester.ensureVisible(find.text('Enviar avistamiento'));
        await tester.pump();
        await tester.runAsync(() => capture('actions'));
        await tester.tap(find.text('Enviar avistamiento'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          c.read(sightingViewModelProvider).requireValue.fields,
          containsAll(['observedAt', 'point']),
        );
        expect(
          find.text('Revisa la fecha, ubicación y los campos marcados.'),
          findsOneWidget,
        );
        await tester.runAsync(() => capture('validation'));
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.byType(FlutterMap));
        await tester.pump();
        await tester.tap(find.byType(FlutterMap));
        await tester.pump(const Duration(milliseconds: 400));
        expect(
          c.read(sightingViewModelProvider).requireValue.point!.source,
          'manual',
        );
        final model = c.read(sightingViewModelProvider.notifier);
        model.date(DateTime(2026, 1, 1));
        model.time(10, 30);
        await tester.runAsync(model.submit);
        await tester.pumpAndSettle();
        expect(
          c.read(sightingViewModelProvider).requireValue.receipt,
          isNotNull,
        );
        await tester.ensureVisible(find.text('Volver a la ficha'));
        await tester.pumpAndSettle();
        await tester.runAsync(() => capture('receipt'));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 5));
      },
    );
  }
}
