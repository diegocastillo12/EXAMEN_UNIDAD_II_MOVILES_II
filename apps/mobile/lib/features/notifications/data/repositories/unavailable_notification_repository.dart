import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';

class UnavailableNotificationRepository implements NotificationRepository {
  const UnavailableNotificationRepository();
  Never _fail() =>
      throw const NotificationFailure(NotificationIssue.unavailable);
  @override
  Future<AlertSubscription> readSubscription(
    String owner,
    AlertTarget target,
  ) async => _fail();
  @override
  Future<AlertSubscription> follow(
    String owner,
    AlertTarget target,
    String command,
    bool following,
    int version,
  ) async => _fail();
  @override
  Future<NotificationPage> list(String owner, String? before) async => _fail();
  @override
  Future<void> markRead(String owner, String id) async => _fail();
}
