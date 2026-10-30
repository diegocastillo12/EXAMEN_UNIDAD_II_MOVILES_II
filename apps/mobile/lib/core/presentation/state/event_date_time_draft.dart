/// Independent selections; a timestamp exists only after both are chosen.
class EventDateTimeDraft {
  const EventDateTimeDraft({this.date, this.hour, this.minute})
    : _original = null;
  const EventDateTimeDraft._({
    this.date,
    this.hour,
    this.minute,
    DateTime? original,
  }) : _original = original;
  factory EventDateTimeDraft.from(DateTime? value) {
    final local = value?.toLocal();
    return EventDateTimeDraft._(
      original: value,
      date: local == null ? null : DateTime(local.year, local.month, local.day),
      hour: local?.hour,
      minute: local?.minute,
    );
  }
  final DateTime? date;
  final DateTime? _original;
  final int? hour, minute;
  DateTime? get value =>
      _original ??
      (date == null || hour == null || minute == null
          ? null
          : DateTime(date!.year, date!.month, date!.day, hour!, minute!));
  EventDateTimeDraft withDate(DateTime selected) => EventDateTimeDraft(
    date: DateTime(selected.year, selected.month, selected.day),
    hour: hour,
    minute: minute,
  );
  EventDateTimeDraft withTime(int selectedHour, int selectedMinute) =>
      EventDateTimeDraft(
        date: date,
        hour: selectedHour,
        minute: selectedMinute,
      );
}
