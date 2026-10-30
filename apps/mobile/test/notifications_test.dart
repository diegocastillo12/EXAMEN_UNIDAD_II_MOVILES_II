import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/notifications/domain/entities/notification.dart';
import 'package:flutter_application_entrehuellas/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_application_entrehuellas/features/notifications/domain/use_cases/notification_actions.dart';
import 'package:flutter_application_entrehuellas/features/notifications/providers/notification_providers.dart';
import 'package:flutter_application_entrehuellas/features/notifications/presentation/view_models/following_view_model.dart';
import 'package:flutter_application_entrehuellas/features/notifications/presentation/view_models/inbox_view_model.dart';
import 'package:flutter_application_entrehuellas/features/notifications/presentation/screens/inbox_screen.dart';
import 'package:flutter_application_entrehuellas/features/notifications/presentation/widgets/follow_target_button.dart';
import 'package:flutter_application_entrehuellas/features/notifications/data/repositories/unavailable_push_repository.dart';
import 'package:flutter_application_entrehuellas/features/notifications/data/data_sources/notification_source.dart';
import 'package:flutter_application_entrehuellas/features/notifications/data/models/notification_dto.dart';
import 'package:flutter_application_entrehuellas/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/notifications/data/repositories/push_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/notifications/data/data_sources/device_push_source.dart';
import 'package:flutter_application_entrehuellas/features/notifications/domain/repositories/push_repository.dart';
import 'alert_preferences_test.dart' show loadFonts;

const target = (kind: 'lost', id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa12');
InboxNotification notification(String id) => InboxNotification(
  id: id,
  source: 'lost',
  caseId: target.id,
  title: 'Hay novedades en un caso que sigues',
  createdAt: DateTime(2026, 10, 18),
  read: false,
);

class FakeNotifications implements NotificationRepository {
  AlertSubscription subscription = const AlertSubscription(false, 0);
  bool ambiguous = false;
  NotificationIssue? issue;
  Completer<void>? pending;
  final attempts = <({String command, bool following, int version})>[];
  final receipts = <String, AlertSubscription>{};
  final read = <String>[];
  @override
  Future<AlertSubscription> readSubscription(
    String owner,
    AlertTarget target,
  ) async {
    await pending?.future;
    if (issue != null) throw NotificationFailure(issue!);
    return subscription;
  }

  @override
  Future<AlertSubscription> follow(
    String owner,
    AlertTarget target,
    String command,
    bool following,
    int version,
  ) async {
    attempts.add((command: command, following: following, version: version));
    await pending?.future;
    if (issue != null) throw NotificationFailure(issue!);
    final receipt = receipts.putIfAbsent(
      command,
      () => AlertSubscription(following, version + 1),
    );
    subscription = receipt;
    if (ambiguous) {
      ambiguous = false;
      throw const NotificationFailure(NotificationIssue.unavailable);
    }
    return receipt;
  }

  @override
  Future<NotificationPage> list(String owner, String? before) async {
    await pending?.future;
    if (issue != null) throw NotificationFailure(issue!);
    return before == null
        ? NotificationPage([notification('3'), notification('2')], '2')
        : NotificationPage([notification('2'), notification('1')], null);
  }

  @override
  Future<void> markRead(String owner, String id) async {
    await pending?.future;
    if (issue != null) throw NotificationFailure(issue!);
    read.add(id);
  }
}

ProviderContainer scope(
  FakeNotifications repo, [
  Stream<AuthSession?>? sessions,
]) => ProviderContainer(
  overrides: [
    notificationRepositoryProvider.overrideWithValue(repo),
    pushRepositoryProvider.overrideWithValue(const UnavailablePushRepository()),
    notificationSessionProvider.overrideWith(
      (ref) => sessions ?? Stream.value(const AuthSession(userId: 'a')),
    ),
  ],
);

class FakeSource implements NotificationSource {
  Object? error;
  final writes = <Map<String, dynamic>>[];
  @override
  Future<NotificationDto> query(
    String owner,
    String operation,
    Map<String, dynamic> parameters,
  ) async {
    if (error != null) throw error!;
    return const NotificationDto({'following': true, 'version': 1});
  }

  @override
  Future<void> write(
    String owner,
    String operation,
    Map<String, dynamic> parameters,
  ) async {
    if (error != null) throw error!;
    writes.add({'owner': owner, ...parameters});
  }
}

class FakeDevice implements DevicePushSource {
  @override
  bool configured = true;
  bool permitted = true;
  Completer<void>? retiring;
  int deleted = 0;
  @override
  Future<bool> requestPermission() async => permitted;
  @override
  Future<String?> token() async => permitted ? 'a-valid-device-token' : null;
  @override
  Future<void> deleteToken() async {
    await retiring?.future;
    deleted++;
  }

  @override
  Stream<DevicePushSignal> watch() => const Stream.empty();
}

void main() {
  test(
    'Token retirement completes before registering the next account',
    () async {
      final device = FakeDevice();
      final source = FakeSource();
      final repository = PushRepositoryImpl(device, source);
      await repository.enable('a');
      device.retiring = Completer<void>();
      final logout = repository.synchronize(null);
      await Future<void>.delayed(Duration.zero);
      final next = repository.synchronize('b');
      await Future<void>.delayed(Duration.zero);
      expect(source.writes.length, 1);
      device.retiring!.complete();
      await logout;
      await next;
      expect(device.deleted, 1);
      expect(source.writes.last['owner'], 'b');
    },
  );
  testWidgets(
    'Following button confirms only persisted selection and can unfollow',
    (tester) async {
      final repo = FakeNotifications();
      final c = scope(repo);
      addTearDown(c.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: Scaffold(body: FollowTargetButton(target: target)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Seguir caso'));
      await tester.pumpAndSettle();
      expect(find.text('Dejar de seguir'), findsOneWidget);
      expect(repo.subscription.following, true);
      await tester.tap(find.text('Dejar de seguir'));
      await tester.pumpAndSettle();
      expect(repo.subscription.following, false);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
  test(
    'Follow validation rejects invalid targets and pagination cursors',
    () async {
      final repo = FakeNotifications();
      expect(
        () => FollowAlertTarget(repo)(
          'a',
          (kind: 'bad', id: target.id),
          'command',
          true,
          0,
        ),
        throwsA(isA<NotificationFailure>()),
      );
      expect(
        () => ListNotifications(repo)('a', '-1'),
        throwsA(isA<NotificationFailure>()),
      );
    },
  );
  test(
    'Following freezes the command after response loss and prevents double sends',
    () async {
      final repo = FakeNotifications()..ambiguous = true;
      final c = scope(repo);
      addTearDown(c.dispose);
      final p = followingViewModelProvider(target);
      final sub = c.listen(p, (_, _) {});
      addTearDown(sub.close);
      await c.read(p.future);
      final vm = c.read(p.notifier);
      await vm.toggle();
      expect(c.read(p).requireValue.subscription.following, false);
      expect(c.read(p).requireValue.failed, true);
      repo.pending = Completer<void>();
      final retry = vm.toggle();
      await vm.toggle();
      expect(repo.attempts.length, 2);
      repo.pending!.complete();
      await retry;
      expect(repo.attempts[0], repo.attempts[1]);
      expect(c.read(p).requireValue.subscription.following, true);
    },
  );
  test('CAS conflict requires a fresh consultation', () async {
    final repo = FakeNotifications();
    final c = scope(repo);
    addTearDown(c.dispose);
    final p = followingViewModelProvider(target);
    final sub = c.listen(p, (_, _) {});
    addTearDown(sub.close);
    await c.read(p.future);
    repo.issue = NotificationIssue.conflict;
    await c.read(p.notifier).toggle();
    expect(c.read(p).requireValue.reload, true);
    repo.issue = null;
    await c.read(p.notifier).toggle();
    await c.read(p.future);
    expect(repo.attempts.length, 1);
  });
  test(
    'Inbox preserves refresh data, deduplicates pages, and confirms read after persistence',
    () async {
      final repo = FakeNotifications();
      final c = scope(repo);
      addTearDown(c.dispose);
      final sub = c.listen(inboxViewModelProvider, (_, _) {});
      addTearDown(sub.close);
      await c.read(inboxViewModelProvider.future);
      final vm = c.read(inboxViewModelProvider.notifier);
      await vm.more();
      expect(
        c.read(inboxViewModelProvider).requireValue.items.map((e) => e.id),
        ['3', '2', '1'],
      );
      repo.pending = Completer<void>();
      final read = vm.markRead(notification('3'));
      expect(
        c.read(inboxViewModelProvider).requireValue.items.first.read,
        false,
      );
      repo.pending!.complete();
      expect(await read, true);
      expect(
        c.read(inboxViewModelProvider).requireValue.items.first.read,
        true,
      );
      repo.pending = null;
      repo.issue = NotificationIssue.unavailable;
      await vm.refresh();
      expect(c.read(inboxViewModelProvider).requireValue.items.length, 3);
      repo.issue = NotificationIssue.forbidden;
      await vm.refresh();
      expect(c.read(inboxViewModelProvider).hasError, true);
      repo.issue = null;
      await vm.refresh();
      await c.read(inboxViewModelProvider.future);
      expect(c.read(inboxViewModelProvider).hasError, false);
    },
  );
  test(
    'Account changes and session errors hide previous inbox and ignore late writes',
    () async {
      final sessions = StreamController<AuthSession?>();
      addTearDown(sessions.close);
      final repo = FakeNotifications();
      final c = scope(repo, sessions.stream);
      addTearDown(c.dispose);
      final sub = c.listen(inboxViewModelProvider, (_, _) {});
      addTearDown(sub.close);
      sessions.add(const AuthSession(userId: 'a'));
      await c.read(inboxViewModelProvider.future);
      repo.pending = Completer<void>();
      final write = c
          .read(inboxViewModelProvider.notifier)
          .markRead(notification('3'));
      sessions.add(const AuthSession(userId: 'b'));
      await c.pump();
      expect(c.read(inboxViewModelProvider).isLoading, true);
      repo.pending!.complete();
      expect(await write, false);
      await c.read(inboxViewModelProvider.future);
      expect(c.read(inboxViewModelProvider).requireValue.owner, 'b');
      sessions.addError(Exception('session'));
      await c.pump();
      await expectLater(
        c.read(inboxViewModelProvider.future),
        throwsA(anything),
      );
      repo.pending = null;
      sessions.add(const AuthSession(userId: 'b'));
      await c.pump();
      await c.read(inboxViewModelProvider.future);
      expect(c.read(inboxViewModelProvider).requireValue.owner, 'b');
    },
  );
  test('A disposed subscription ignores a late acknowledgement', () async {
    final repo = FakeNotifications();
    final c = scope(repo);
    addTearDown(c.dispose);
    final p = followingViewModelProvider(target);
    final sub = c.listen(p, (_, _) {});
    await c.read(p.future);
    repo.pending = Completer<void>();
    final write = c.read(p.notifier).toggle();
    sub.close();
    await c.pump();
    repo.pending!.complete();
    await write;
  });
  test('Repository maps source errors to safe domain failures', () async {
    final source = FakeSource();
    final repo = NotificationRepositoryImpl(source);
    for (final issue in NotificationSourceIssue.values) {
      source.error = NotificationSourceException(issue);
      await expectLater(
        repo.readSubscription('a', target),
        throwsA(isA<NotificationFailure>()),
      );
    }
    source.error = Exception('SECRET TOKEN');
    await expectLater(
      repo.markRead('a', '1'),
      throwsA(
        isA<NotificationFailure>().having(
          (e) => e.issue,
          'issue',
          NotificationIssue.unavailable,
        ),
      ),
    );
  });
  test(
    'Push denied/configuration and account switching never register a token for the old owner',
    () async {
      final device = FakeDevice();
      final source = FakeSource();
      final repo = PushRepositoryImpl(device, source);
      device.configured = false;
      expect(await repo.enable('a'), PushAvailability.unconfigured);
      expect(source.writes, isEmpty);
      device.configured = true;
      device.permitted = false;
      expect(await repo.enable('a'), PushAvailability.denied);
      expect(source.writes, isEmpty);
      device.permitted = true;
      expect(await repo.enable('a'), PushAvailability.ready);
      expect(source.writes.single['owner'], 'a');
      await repo.synchronize(null);
      expect(device.deleted, 1);
      await repo.synchronize('b');
      expect(source.writes.last['owner'], 'b');
    },
  );
  for (final small in [false, true]) {
    testWidgets('Inbox, read state and follow render small=$small', (
      tester,
    ) async {
      await tester.runAsync(loadFonts);
      tester.view.physicalSize = small
          ? const Size(320, 350)
          : const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = FakeNotifications();
      final c = scope(repo);
      addTearDown(c.dispose);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: RepaintBoundary(
            key: boundary,
            child: MaterialApp(
              theme: AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(small ? 2 : 1)),
                child: child!,
              ),
              home: const InboxScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Alertas'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        final image = await render.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final dir = Directory('build/ui-preview/notifications')
          ..createSync(recursive: true);
        File(
          '${dir.path}/${small ? '320' : '390'}-inbox.png',
        ).writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.ensureVisible(find.text('Marcar leída').first);
      await tester.tap(find.text('Marcar leída').first);
      await tester.pumpAndSettle();
      expect(repo.read.length, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
