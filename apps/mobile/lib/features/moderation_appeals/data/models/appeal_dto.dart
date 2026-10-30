import '../../domain/entities/moderation_appeal.dart';

class AppealDto {
  static Map<String, dynamic> _map(Object? value) {
    if (value is! Map<String, dynamic>) throw const FormatException();
    return value;
  }

  static String _text(Object? value, [int max = 1000]) {
    if (value is! String || value.trim().isEmpty || value.runes.length > max) {
      throw const FormatException();
    }
    return value;
  }

  static String _id(Object? value) {
    final text = _text(value, 36);
    if (!RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    ).hasMatch(text)) {
      throw const FormatException();
    }
    return text;
  }

  static ModeratedDecision decision(Object? raw) {
    final v = _map(raw), a = v['appeal'] == null ? null : _map(v['appeal']);
    final b = a?['answer'] == null ? null : _map(a!['answer']);
    if (!['lost', 'found', 'sighting'].contains(v['kind']) ||
        !['hide', 'show', 'dismiss'].contains(v['action'])) {
      throw const FormatException();
    }
    return ModeratedDecision(
      id: _id(v['decision']),
      kind: v['kind'] as String,
      resource: _id(v['resource']),
      action: v['action'] as String,
      reason: _text(v['reason'], 500),
      decidedAt: DateTime.parse(_text(v['decidedAt'], 64)),
      appeal: a == null
          ? null
          : AppealSubmission(
              id: _id(a['id']),
              reason: _text(a['reason']),
              submittedAt: DateTime.parse(_text(a['submittedAt'], 64)),
              answer: b == null
                  ? null
                  : AppealAnswer(
                      id: _id(b['id']),
                      actor: _id(b['actor']),
                      reason: _text(b['reason']),
                      answeredAt: DateTime.parse(_text(b['answeredAt'], 64)),
                    ),
            ),
    );
  }

  static AppealPage page(Object? raw) {
    final v = _map(raw), items = v['items'];
    if (items is! List || items.length > 20) throw const FormatException();
    final next = v['next'] == null ? null : _map(v['next']);
    final time = next == null ? null : _text(next['time'], 64);
    if (time != null) DateTime.parse(time);
    return AppealPage(
      items: items.map(decision).toList(),
      next: next == null ? null : (time: time!, id: _id(next['id'])),
    );
  }
}
