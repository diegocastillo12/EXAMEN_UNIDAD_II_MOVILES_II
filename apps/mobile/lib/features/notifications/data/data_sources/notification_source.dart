import '../models/notification_dto.dart';

enum NotificationSourceIssue { forbidden, conflict, unavailable }

class NotificationSourceException implements Exception {
  const NotificationSourceException(this.issue);
  final NotificationSourceIssue issue;
}

abstract interface class NotificationSource {
  Future<NotificationDto> query(
    String owner,
    String operation,
    Map<String, dynamic> parameters,
  );
  Future<void> write(
    String owner,
    String operation,
    Map<String, dynamic> parameters,
  );
}
