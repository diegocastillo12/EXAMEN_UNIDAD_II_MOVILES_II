import '../../domain/entities/notification.dart';

class NotificationDto {
  const NotificationDto(this.json);
  final Map<String, dynamic> json;
  AlertSubscription subscription() =>
      AlertSubscription(json['following'] as bool, json['version'] as int);
  NotificationPage page() => NotificationPage(
    List.unmodifiable(
      (json['items'] as List).map((raw) {
        final r = Map<String, dynamic>.from(raw as Map);
        final source = r['case_source'] as String;
        if (!['lost', 'found'].contains(source)) {
          throw const FormatException('Invalid source');
        }
        return InboxNotification(
          id: r['id'] as String,
          source: source,
          caseId: r['case_id'] as String,
          title: r['title'] as String,
          createdAt: DateTime.parse(r['created_at'] as String),
          read: r['read_at'] != null,
        );
      }),
    ),
    json['next'] as String?,
  );
}
