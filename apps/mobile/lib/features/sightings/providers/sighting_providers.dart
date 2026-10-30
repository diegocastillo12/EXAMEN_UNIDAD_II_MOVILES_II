import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/domain/entities/auth_session.dart';
import '../domain/entities/sighting.dart';
import '../domain/repositories/sighting_repository.dart';
import '../domain/use_cases/sighting_actions.dart';

final sightingRepositoryProvider = Provider<SightingRepository>(
  (ref) => throw StateError('SightingRepository must be injected'),
);
final sightingTargetProvider = Provider<SightingTarget>(
  (ref) => throw StateError('SightingTarget must be injected'),
);
final sightingSessionProvider = StreamProvider.autoDispose<AuthSession?>(
  (ref) => ref.watch(watchAuthSessionProvider)(),
  retry: (_, _) => null,
);
final submitSightingProvider = Provider(
  (ref) => SubmitSighting(ref.watch(sightingRepositoryProvider)),
);
final locateSightingProvider = Provider(
  (ref) => LocateSighting(ref.watch(sightingRepositoryProvider)),
);
final chooseSightingPhotoProvider = Provider(
  (ref) => ChooseSightingPhoto(ref.watch(sightingRepositoryProvider)),
);
