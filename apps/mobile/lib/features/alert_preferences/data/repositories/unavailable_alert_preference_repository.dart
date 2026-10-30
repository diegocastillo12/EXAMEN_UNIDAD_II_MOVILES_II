import '../../domain/entities/alert_preferences.dart';
import '../../domain/failures/preference_failure.dart';
import '../../domain/repositories/alert_preference_repository.dart';

class UnavailableAlertPreferenceRepository
    implements AlertPreferenceRepository {
  const UnavailableAlertPreferenceRepository();
  @override
  Future<AlertPreferences?> read(String ownerId) async =>
      throw const PreferenceFailure(PreferenceFailureKind.unavailable);
  @override
  Future<AlertPreferences> save(AlertPreferences preferences) async =>
      throw const PreferenceFailure(PreferenceFailureKind.unavailable);
}
