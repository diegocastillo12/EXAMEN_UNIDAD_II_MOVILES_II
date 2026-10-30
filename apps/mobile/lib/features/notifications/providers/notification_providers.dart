import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/entities/auth_session.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/use_cases/notification_actions.dart';
import '../domain/repositories/push_repository.dart';
import '../domain/use_cases/push_actions.dart';

final pushRepositoryProvider = Provider<PushRepository>(
  (ref) => throw StateError('PushRepository must be injected'),
);
final enablePushProvider = Provider(
  (ref) => EnablePush(ref.watch(pushRepositoryProvider)),
);
final synchronizePushProvider = Provider(
  (ref) => SynchronizePush(ref.watch(pushRepositoryProvider)),
);
final watchPushSignalsProvider = Provider(
  (ref) => WatchPushSignals(ref.watch(pushRepositoryProvider)),
);
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => throw StateError('NotificationRepository must be injected'),
);
final notificationSessionProvider = StreamProvider.autoDispose<AuthSession?>(
  (ref) => ref.watch(watchAuthSessionProvider)(),
  retry: (_, _) => null,
);
final readAlertSubscriptionProvider = Provider(
  (ref) => ReadAlertSubscription(ref.watch(notificationRepositoryProvider)),
);
final followAlertTargetProvider = Provider(
  (ref) => FollowAlertTarget(ref.watch(notificationRepositoryProvider)),
);
final listNotificationsProvider = Provider(
  (ref) => ListNotifications(ref.watch(notificationRepositoryProvider)),
);
final markNotificationReadProvider = Provider(
  (ref) => MarkNotificationRead(ref.watch(notificationRepositoryProvider)),
);
