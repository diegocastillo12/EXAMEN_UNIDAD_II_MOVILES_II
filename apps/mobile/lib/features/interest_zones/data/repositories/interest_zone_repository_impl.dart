import '../../domain/entities/interest_zone.dart';
import '../../domain/failures/zone_failure.dart';
import '../../domain/repositories/interest_zone_repository.dart';
import '../data_sources/interest_zone_data_source.dart';

class InterestZoneRepositoryImpl implements InterestZoneRepository {
  const InterestZoneRepositoryImpl(this.source);
  final InterestZoneDataSource source;
  Future<T> _map<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ZoneSourceException catch (error) {
      throw ZoneFailure(switch (error.issue) {
        ZoneSourceIssue.signedOut => ZoneFailureKind.signedOut,
        ZoneSourceIssue.conflict => ZoneFailureKind.conflict,
        ZoneSourceIssue.invalid => ZoneFailureKind.unavailable,
        ZoneSourceIssue.unavailable => ZoneFailureKind.unavailable,
        ZoneSourceIssue.network => ZoneFailureKind.network,
      });
    } catch (_) {
      throw const ZoneFailure(ZoneFailureKind.network);
    }
  }

  @override
  Future<List<InterestZone>> list(String ownerId) => _map(
    () async =>
        (await source.list(ownerId)).map((dto) => dto.toEntity()).toList(),
  );
  @override
  Future<InterestZone> save(String ownerId, ZoneDraft draft) => _map(
    () async => (await source.save(ownerId, {
      'p_id': draft.id,
      'p_expected_version': draft.version,
      'p_name': draft.name,
      'p_latitude': draft.latitude,
      'p_longitude': draft.longitude,
      'p_radius_meters': draft.radiusMeters,
    })).toEntity(),
  );
  @override
  Future<void> delete(String ownerId, InterestZone zone) =>
      _map(() => source.delete(ownerId, zone.id, zone.version));
}
