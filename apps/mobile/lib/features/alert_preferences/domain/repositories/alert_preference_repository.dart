import '../entities/alert_preferences.dart';

abstract interface class AlertPreferenceRepository {
  /// Null is confirmed absence; errors never produce defaults.
  Future<AlertPreferences?> read(String ownerId);

  /// Stable account key + expected version + choices identify an identical retry.
  Future<AlertPreferences> save(AlertPreferences preferences);
}
