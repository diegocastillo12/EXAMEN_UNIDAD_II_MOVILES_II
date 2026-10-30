typedef AlertTarget = ({String kind, String id});

class AlertSubscription {
  const AlertSubscription(this.following, this.version);
  final bool following;
  final int version;
}

class InboxNotification {
  const InboxNotification({
    required this.id,
    required this.source,
    required this.caseId,
    required this.title,
    required this.createdAt,
    required this.read,
  });
  final String id, source, caseId, title;
  final DateTime createdAt;
  final bool read;
  InboxNotification asRead() => InboxNotification(
    id: id,
    source: source,
    caseId: caseId,
    title: title,
    createdAt: createdAt,
    read: true,
  );
}

class NotificationPage {
  const NotificationPage(this.items, this.cursor);
  final List<InboxNotification> items;
  final String? cursor;
}

enum NotificationIssue { forbidden, conflict, unavailable, invalid }

class NotificationFailure implements Exception {
  const NotificationFailure(this.issue);
  final NotificationIssue issue;
}
