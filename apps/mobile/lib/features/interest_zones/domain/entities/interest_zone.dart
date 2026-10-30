class InterestZone {
  const InterestZone({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.version,
  });
  final String id;
  final String ownerId;
  final String name;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final int version;
}

class ZoneDraft {
  const ZoneDraft({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.version = 0,
  });
  final String id;
  final String name;
  final double? latitude;
  final double? longitude;
  final int radiusMeters;
  final int version;
  ZoneDraft copyWith({
    String? name,
    double? latitude,
    double? longitude,
    int? radiusMeters,
  }) => ZoneDraft(
    id: id,
    name: name ?? this.name,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    radiusMeters: radiusMeters ?? this.radiusMeters,
    version: version,
  );
}
