import 'dart:async';
import 'package:flutter_application_entrehuellas/features/alert_preferences/domain/entities/alert_preferences.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/domain/repositories/alert_preference_repository.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/domain/failures/preference_failure.dart';

class FakeAlertPreferences implements AlertPreferenceRepository {
  final rows = <String, AlertPreferences>{};
  bool failRead = false;
  bool failSave = false;
  int reads = 0;
  final writes = <AlertPreferences>[];
  Completer<AlertPreferences?>? pendingRead;
  Completer<AlertPreferences>? pendingSave;
  @override
  Future<AlertPreferences?> read(String ownerId) async {
    reads++;
    if (pendingRead != null) return pendingRead!.future;
    if (failRead) {
      throw const PreferenceFailure(PreferenceFailureKind.unavailable);
    }
    return rows[ownerId];
  }

  @override
  Future<AlertPreferences> save(AlertPreferences preferences) async {
    writes.add(preferences);
    if (pendingSave != null) return pendingSave!.future;
    if (failSave) {
      throw const PreferenceFailure(PreferenceFailureKind.unavailable);
    }
    final current = rows[preferences.ownerId];
    if (current != null &&
        current.version == preferences.version + 1 &&
        current.sameChoices(preferences)) {
      return current;
    }
    if ((current?.version ?? 0) != preferences.version) {
      throw const PreferenceFailure(PreferenceFailureKind.conflict);
    }
    final saved = preferences.copyWith(version: preferences.version + 1);
    rows[preferences.ownerId] = saved;
    return saved;
  }
}
