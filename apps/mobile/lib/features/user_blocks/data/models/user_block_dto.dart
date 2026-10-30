import '../../domain/entities/user_block.dart';

class UserBlockDto {
  static final _id = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );
  static UserBlock entry(Object? raw) {
    final row = Map<String, dynamic>.from(raw as Map);
    final id = row['id'] as String, label = row['label'] as String;
    final version = row['version'] as int;
    if (!_id.hasMatch(id) ||
        label.isEmpty ||
        label.runes.length > 120 ||
        version < 0 ||
        version > 2147483647) {
      throw const FormatException();
    }
    return UserBlock(
      id: id,
      label: label,
      enabled: row['enabled'] as bool,
      version: version,
    );
  }

  static UserBlockPage page(Object? raw) {
    final row = Map<String, dynamic>.from(raw as Map);
    final items = (row['items'] as List).map(entry).toList(growable: false);
    final next = row['next'] as String?;
    if (items.length > 20 ||
        items.any((e) => !e.enabled) ||
        items.map((e) => e.id).toSet().length != items.length ||
        (next != null && !_id.hasMatch(next))) {
      throw const FormatException();
    }
    return UserBlockPage(List.unmodifiable(items), next);
  }
}
