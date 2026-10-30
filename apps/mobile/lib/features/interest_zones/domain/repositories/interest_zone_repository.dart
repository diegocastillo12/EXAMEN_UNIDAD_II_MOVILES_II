import '../entities/interest_zone.dart';

abstract interface class InterestZoneRepository {
  Future<List<InterestZone>> list(String ownerId);
  Future<InterestZone> save(String ownerId, ZoneDraft draft);
  Future<void> delete(String ownerId, InterestZone zone);
}
