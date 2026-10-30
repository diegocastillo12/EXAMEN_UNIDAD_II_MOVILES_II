String caseDateOnlyLabel(DateTime time) {
  final local = time.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year}';
}

String caseDateTimeLabel(DateTime time) {
  final local = time.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${caseDateOnlyLabel(time)} ${two(local.hour)}:${two(local.minute)}';
}
