import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/entities/auth_session.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/place_search_repository.dart';
import '../domain/use_cases/search_places.dart';

final placeSearchRepositoryProvider = Provider<PlaceSearchRepository>(
  (ref) => throw StateError('PlaceSearchRepository must be injected'),
);
final searchPlacesProvider = Provider(
  (ref) => SearchPlaces(ref.watch(placeSearchRepositoryProvider)),
);
final placesSessionProvider = StreamProvider.autoDispose<AuthSession?>(
  (ref) => ref.watch(watchAuthSessionProvider)(),
  retry: (_, _) => null,
);
