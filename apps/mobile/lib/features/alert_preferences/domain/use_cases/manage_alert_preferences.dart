import '../entities/alert_preferences.dart';
import '../failures/preference_failure.dart';
import '../repositories/alert_preference_repository.dart';

class ReadAlertPreferences {
  const ReadAlertPreferences(this.repository);
  final AlertPreferenceRepository repository;
  Future<AlertPreferences> call(String ownerId) async {
    if (ownerId.isEmpty) {
      throw const PreferenceFailure(PreferenceFailureKind.signedOut);
    }
    final result = await repository.read(ownerId);
    if (result != null && (result.ownerId != ownerId || result.version < 1)) {
      throw const PreferenceFailure(PreferenceFailureKind.unavailable);
    }
    return result ?? AlertPreferences(ownerId: ownerId);
  }
}

class SaveAlertPreferences {
  const SaveAlertPreferences(this.repository);
  final AlertPreferenceRepository repository;
  Future<AlertPreferences> call(AlertPreferences preferences) async {
    if (preferences.ownerId.isEmpty) {
      throw const PreferenceFailure(PreferenceFailureKind.signedOut);
    }
    if (preferences.version < 0 || preferences.version >= 2147483647) {
      throw const PreferenceFailure(PreferenceFailureKind.conflict);
    }
    if (preferences.enabled &&
        !preferences.lostPets &&
        !preferences.foundPets &&
        !preferences.caseUpdates) {
      throw const PreferenceFailure(PreferenceFailureKind.invalidTypes);
    }
    if (preferences.enabled && !preferences.inApp && !preferences.push) {
      throw const PreferenceFailure(PreferenceFailureKind.invalidChannels);
    }
    final result = await repository.save(preferences);
    if (result.ownerId != preferences.ownerId ||
        !result.sameChoices(preferences) ||
        result.version < 1 ||
        result.version < preferences.version ||
        result.version > preferences.version + 1) {
      throw const PreferenceFailure(PreferenceFailureKind.unavailable);
    }
    return result;
  }
}
