import '../../domain/entities/saved_case_mark.dart';

class SavedCaseMarkDto {
  SavedCaseMarkDto(Object? raw) {
    if (raw is! Map ||
        raw['saved'] is! bool ||
        raw['version'] is! int ||
        (raw['version'] as int) < 0) {
      throw const FormatException('Invalid saved-case state');
    }
    saved = raw['saved'] as bool;
    version = raw['version'] as int;
  }
  late final bool saved;
  late final int version;
  SavedCaseMark toEntity() => SavedCaseMark(saved: saved, version: version);
}
