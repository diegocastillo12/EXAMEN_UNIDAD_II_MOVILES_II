import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../data_sources/notification_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this.source);
  final NotificationSource source;
  Future<T> _run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on NotificationSourceException catch (e) {
      throw NotificationFailure(switch (e.issue) {
        NotificationSourceIssue.forbidden => NotificationIssue.forbidden,
        NotificationSourceIssue.conflict => NotificationIssue.conflict,
        _ => NotificationIssue.unavailable,
      });
    } catch (_) {
      throw const NotificationFailure(NotificationIssue.unavailable);
    }
  }

  @override
  Future<AlertSubscription> readSubscription(
    String owner,
    AlertTarget target,
  ) => _run(
    () async => (await source.query(owner, 'read_alert_subscription', {
      'p_kind': target.kind,
      'p_target': target.id,
    })).subscription(),
  );
  @override
  Future<AlertSubscription> follow(
    String owner,
    AlertTarget target,
    String command,
    bool following,
    int version,
  ) => _run(
    () async => (await source.query(owner, 'set_alert_subscription', {
      'p_command': command,
      'p_kind': target.kind,
      'p_target': target.id,
      'p_following': following,
      'p_version': version,
    })).subscription(),
  );
  @override
  Future<NotificationPage> list(String owner, String? before) => _run(
    () async => (await source.query(owner, 'list_notifications', {
      'p_before': before,
    })).page(),
  );
  @override
  Future<void> markRead(String owner, String id) =>
      _run(() => source.write(owner, 'mark_notification_read', {'p_id': id}));
}
