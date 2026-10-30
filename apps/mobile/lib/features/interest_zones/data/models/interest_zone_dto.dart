import '../../domain/entities/interest_zone.dart';

class InterestZoneDto {
  const InterestZoneDto(this.json);
  final Map<String, dynamic> json;
  InterestZone toEntity() => InterestZone(
    id: json['id'] as String,
    ownerId: json['owner_id'] as String,
    name: json['name'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    radiusMeters: json['radius_meters'] as int,
    version: json['version'] as int,
  );
}
