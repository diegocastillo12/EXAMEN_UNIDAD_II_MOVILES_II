import '../../domain/entities/explore_query.dart';

class ExploreFilterSelection {
  factory ExploreFilterSelection.fromQuery(
    ExploreQuery query, {
    String label = '',
    String centerName = '',
  }) => ExploreFilterSelection(
    kind: query.kind,
    species: query.species,
    status: query.status,
    days: query.since == null || query.until == null
        ? 0
        : query.until!.difference(query.since!).inDays,
    lat: query.latitude,
    lon: query.longitude,
    radius: query.radiusMeters ?? 15000,
    label: label,
    centerName: centerName,
  );
  const ExploreFilterSelection({
    this.kind = ExploreKind.all,
    this.species = ExploreSpecies.all,
    this.status = ExploreStatus.active,
    this.days = 0,
    this.radius = 15000,
    this.lat,
    this.lon,
    this.label = '',
    this.centerName = '',
  });
  final ExploreKind kind;
  final ExploreSpecies species;
  final ExploreStatus status;
  final int days, radius;
  final double? lat, lon;
  final String label;
  final String centerName;
}
