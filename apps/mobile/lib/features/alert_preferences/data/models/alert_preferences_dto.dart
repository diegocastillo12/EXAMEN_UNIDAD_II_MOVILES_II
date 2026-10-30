import '../../domain/entities/alert_preferences.dart';

class AlertPreferencesDto {
  const AlertPreferencesDto(this.json);
  final Map<String, dynamic> json;
  AlertPreferences toEntity() => AlertPreferences(
    ownerId: json['owner_id'] as String,
    version: json['version'] as int,
    enabled: json['enabled'] as bool,
    lostPets: json['lost_pets'] as bool,
    foundPets: json['found_pets'] as bool,
    caseUpdates: json['case_updates'] as bool,
    inApp: json['in_app'] as bool,
    push: json['push'] as bool,
  );
}
