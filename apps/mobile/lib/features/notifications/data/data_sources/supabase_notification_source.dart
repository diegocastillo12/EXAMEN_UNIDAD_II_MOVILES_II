import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_dto.dart';
import 'notification_source.dart';

class SupabaseNotificationSource implements NotificationSource {
  const SupabaseNotificationSource(this.client);
  final SupabaseClient client;
  Future<dynamic> _rpc(
    String owner,
    String operation,
    Map<String, dynamic> parameters,
  ) async {
    if (client.auth.currentUser?.id != owner) {
      throw const NotificationSourceException(
        NotificationSourceIssue.forbidden,
      );
    }
    try {
      final result = await client.rpc(operation, params: parameters);
      if (client.auth.currentUser?.id != owner) {
        throw const NotificationSourceException(
          NotificationSourceIssue.forbidden,
        );
      }
      return result;
    } on PostgrestException catch (error) {
      throw NotificationSourceException(switch (error.code) {
        '42501' => NotificationSourceIssue.forbidden,
        '40001' => NotificationSourceIssue.conflict,
        _ => NotificationSourceIssue.unavailable,
      });
    }
  }

  @override
  Future<NotificationDto> query(
    String owner,
    String operation,
    Map<String, dynamic> parameters,
  ) async => NotificationDto(
    Map<String, dynamic>.from(await _rpc(owner, operation, parameters) as Map),
  );
  @override
  Future<void> write(
    String owner,
    String operation,
    Map<String, dynamic> parameters,
  ) async {
    await _rpc(owner, operation, parameters);
  }
}
