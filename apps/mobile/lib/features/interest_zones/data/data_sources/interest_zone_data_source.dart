import '../models/interest_zone_dto.dart';

enum ZoneSourceIssue { signedOut, conflict, invalid, unavailable, network }

class ZoneSourceException implements Exception {
  const ZoneSourceException(this.issue);
  final ZoneSourceIssue issue;
}

abstract interface class InterestZoneDataSource {
  Future<List<InterestZoneDto>> list(String ownerId);
  Future<InterestZoneDto> save(String ownerId, Map<String, dynamic> params);
  Future<void> delete(String ownerId, String id, int version);
}
