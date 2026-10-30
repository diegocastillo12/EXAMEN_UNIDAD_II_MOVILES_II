import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/interest_zone_repository.dart';
import '../domain/use_cases/manage_interest_zones.dart';

final interestZoneRepositoryProvider = Provider<InterestZoneRepository>(
  (ref) => throw StateError('InterestZoneRepository must be injected.'),
);
final zoneSessionProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(watchAuthSessionProvider)(),
);
final listInterestZonesProvider = Provider(
  (ref) => ListInterestZones(ref.watch(interestZoneRepositoryProvider)),
);
final saveInterestZoneProvider = Provider(
  (ref) => SaveInterestZone(ref.watch(interestZoneRepositoryProvider)),
);
final deleteInterestZoneProvider = Provider(
  (ref) => DeleteInterestZone(ref.watch(interestZoneRepositoryProvider)),
);
