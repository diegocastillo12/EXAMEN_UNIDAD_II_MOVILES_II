import '../models/alert_preferences_dto.dart';

enum PreferenceSourceIssue { signedOut, conflict, unavailable }

class PreferenceSourceException implements Exception {
  const PreferenceSourceException(this.issue);
  final PreferenceSourceIssue issue;
}

abstract interface class AlertPreferenceDataSource {
  Future<AlertPreferencesDto?> read(String ownerId);
  Future<AlertPreferencesDto> save(
    String ownerId,
    Map<String, dynamic> parameters,
  );
}
