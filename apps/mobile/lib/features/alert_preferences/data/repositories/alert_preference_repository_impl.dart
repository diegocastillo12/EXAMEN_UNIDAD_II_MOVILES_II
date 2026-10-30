import '../../domain/entities/alert_preferences.dart';
import '../../domain/failures/preference_failure.dart';
import '../../domain/repositories/alert_preference_repository.dart';
import '../data_sources/alert_preference_data_source.dart';

class AlertPreferenceRepositoryImpl implements AlertPreferenceRepository {
  const AlertPreferenceRepositoryImpl(this.source);
  final AlertPreferenceDataSource source;
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PreferenceSourceException catch (error) {
      throw PreferenceFailure(switch (error.issue) {
        PreferenceSourceIssue.signedOut => PreferenceFailureKind.signedOut,
        PreferenceSourceIssue.conflict => PreferenceFailureKind.conflict,
        PreferenceSourceIssue.unavailable => PreferenceFailureKind.unavailable,
      });
    } catch (_) {
      throw const PreferenceFailure(PreferenceFailureKind.unavailable);
    }
  }

  @override
  Future<AlertPreferences?> read(String ownerId) =>
      _run(() async => (await source.read(ownerId))?.toEntity());
  @override
  Future<AlertPreferences> save(AlertPreferences preferences) => _run(
    () async => (await source.save(preferences.ownerId, {
      'p_expected_version': preferences.version,
      'p_enabled': preferences.enabled,
      'p_lost_pets': preferences.lostPets,
      'p_found_pets': preferences.foundPets,
      'p_case_updates': preferences.caseUpdates,
      'p_in_app': preferences.inApp,
      'p_push': preferences.push,
    })).toEntity(),
  );
}
