bool crossesFeatureBoundary(String source, String target) {
  final feature = RegExp(r'/features/([^/]+)/');
  final origin = feature.firstMatch(source)?.group(1);
  final destination = feature.firstMatch(target)?.group(1);
  if (source.contains('/core/') && destination != null) return true;
  return origin != null &&
      destination != null &&
      origin != destination &&
      (target.contains('/presentation/') || target.contains('/data/'));
}
