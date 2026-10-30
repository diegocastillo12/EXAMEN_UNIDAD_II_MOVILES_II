import '../../domain/entities/interest_zone.dart';
import '../../domain/failures/zone_failure.dart';
import '../../domain/repositories/interest_zone_repository.dart';

class UnavailableInterestZoneRepository implements InterestZoneRepository {
  const UnavailableInterestZoneRepository();
  @override
  Future<List<InterestZone>> list(String ownerId) async =>
      throw const ZoneFailure(ZoneFailureKind.unavailable);
  @override
  Future<InterestZone> save(String ownerId, ZoneDraft draft) async =>
      throw const ZoneFailure(ZoneFailureKind.unavailable);
  @override
  Future<void> delete(String ownerId, InterestZone zone) async =>
      throw const ZoneFailure(ZoneFailureKind.unavailable);
}
