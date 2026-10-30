import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/alert_preference_repository.dart';
import '../domain/use_cases/manage_alert_preferences.dart';

final alertPreferenceRepositoryProvider = Provider<AlertPreferenceRepository>(
  (ref) => throw StateError('AlertPreferenceRepository must be injected.'),
);
final preferenceSessionProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(watchAuthSessionProvider)(),
);
final readAlertPreferencesProvider = Provider(
  (ref) => ReadAlertPreferences(ref.watch(alertPreferenceRepositoryProvider)),
);
final saveAlertPreferencesProvider = Provider(
  (ref) => SaveAlertPreferences(ref.watch(alertPreferenceRepositoryProvider)),
);
