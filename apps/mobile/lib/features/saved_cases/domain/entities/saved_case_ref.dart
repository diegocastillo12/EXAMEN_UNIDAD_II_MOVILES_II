enum SavedCaseSource { lost, found }

/// The source identifies the storage origin, not the report's product category.
class SavedCaseRef {
  const SavedCaseRef({required this.source, required this.id});
  final SavedCaseSource source;
  final String id;
  bool get valid => RegExp(
    r'^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$',
  ).hasMatch(id);
  @override
  bool operator ==(Object other) =>
      other is SavedCaseRef && source == other.source && id == other.id;
  @override
  int get hashCode => Object.hash(source, id);
}
