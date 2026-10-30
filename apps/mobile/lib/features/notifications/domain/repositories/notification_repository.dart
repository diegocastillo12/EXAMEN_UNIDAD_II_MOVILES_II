import '../entities/notification.dart';

abstract interface class NotificationRepository {
  Future<AlertSubscription> readSubscription(String owner, AlertTarget target);
  Future<AlertSubscription> follow(
    String owner,
    AlertTarget target,
    String command,
    bool following,
    int version,
  );
  Future<NotificationPage> list(String owner, String? before);
  Future<void> markRead(String owner, String id);
}
