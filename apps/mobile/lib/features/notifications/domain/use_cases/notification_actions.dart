import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

void _target(String owner, AlertTarget target) {
  if (owner.isEmpty ||
      !['lost', 'found', 'zone'].contains(target.kind) ||
      !RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(target.id)) {
    throw const NotificationFailure(NotificationIssue.invalid);
  }
}

class ReadAlertSubscription {
  const ReadAlertSubscription(this.repository);
  final NotificationRepository repository;
  Future<AlertSubscription> call(String owner, AlertTarget target) {
    _target(owner, target);
    return repository.readSubscription(owner, target);
  }
}

class FollowAlertTarget {
  const FollowAlertTarget(this.repository);
  final NotificationRepository repository;
  Future<AlertSubscription> call(
    String owner,
    AlertTarget target,
    String command,
    bool following,
    int version,
  ) async {
    _target(owner, target);
    if (version < 0 || command.isEmpty) {
      throw const NotificationFailure(NotificationIssue.invalid);
    }
    final receipt = await repository.follow(
      owner,
      target,
      command,
      following,
      version,
    );
    if (receipt.following != following || receipt.version != version + 1) {
      throw const NotificationFailure(NotificationIssue.unavailable);
    }
    return receipt;
  }
}

class ListNotifications {
  const ListNotifications(this.repository);
  final NotificationRepository repository;
  Future<NotificationPage> call(String owner, [String? before]) {
    if (owner.isEmpty || (before != null && (int.tryParse(before) ?? 0) <= 0)) {
      throw const NotificationFailure(NotificationIssue.invalid);
    }
    return repository.list(owner, before);
  }
}

class MarkNotificationRead {
  const MarkNotificationRead(this.repository);
  final NotificationRepository repository;
  Future<void> call(String owner, String id) {
    if (owner.isEmpty || (int.tryParse(id) ?? 0) <= 0) {
      throw const NotificationFailure(NotificationIssue.invalid);
    }
    return repository.markRead(owner, id);
  }
}
