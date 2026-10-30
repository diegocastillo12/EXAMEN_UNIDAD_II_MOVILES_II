import '../../../../core/domain/entities/public_case_card.dart';

typedef ExploreKind = PublicCaseKind;

enum ExploreSpecies { all, dog, cat, other }

typedef ExploreStatus = PublicCaseStatus;

class ExploreQuery {
  const ExploreQuery({
    this.kind = ExploreKind.all,
    this.species = ExploreSpecies.all,
    this.status = ExploreStatus.active,
    this.since,
    this.until,
    this.latitude,
    this.longitude,
    this.radiusMeters,
  });
  final ExploreKind kind;
  final ExploreSpecies species;
  final ExploreStatus status;
  final DateTime? since, until;
  final double? latitude, longitude;
  final int? radiusMeters;
  bool get valid {
    final geo = [
      latitude,
      longitude,
      radiusMeters,
    ].where((v) => v != null).length;
    return (since == null || until == null || !since!.isAfter(until!)) &&
        (geo == 0 ||
            (geo == 3 &&
                latitude!.isFinite &&
                longitude!.isFinite &&
                latitude! >= -85 &&
                latitude! <= 85 &&
                longitude! >= -180 &&
                longitude! <= 180 &&
                radiusMeters! >= 100 &&
                radiusMeters! <= 50000));
  }
}
