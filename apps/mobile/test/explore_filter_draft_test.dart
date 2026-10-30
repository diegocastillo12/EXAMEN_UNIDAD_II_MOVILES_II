import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/failures/explore_failure.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/repositories/current_location_repository.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/state/explore_filter_selection.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/view_models/explore_view_model.dart';
import 'package:flutter_application_entrehuellas/features/explore/providers/explore_providers.dart';
import 'package:flutter_application_entrehuellas/features/places/domain/entities/search_place.dart';
import 'explore_test.dart' show SearchFake;

class DraftLocation implements CurrentLocationRepository {
  int calls = 0;
  bool fail = false;
  Completer<SearchPlace>? pending;
  @override
  Future<SearchPlace> locate() async {
    calls++;
    if (fail) throw const ExploreFailure(ExploreFailureKind.locationDenied);
    return pending?.future ??
        Future.value(
          const SearchPlace(
            label: 'Ubicación actual',
            latitude: -12.05,
            longitude: -77.05,
          ),
        );
  }
}

void main() {
  test(
    'GPS only edits a draft; apply preserves chosen label through refresh and pages',
    () async {
      final repo = SearchFake();
      final location = DraftLocation();
      final container = ProviderContainer(
        overrides: [
          exploreRepositoryProvider.overrideWithValue(repo),
          currentLocationRepositoryProvider.overrideWithValue(location),
          exploreSessionProvider.overrideWith(
            (_) => Stream.value(const AuthSession(userId: 'a')),
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        exploreViewModelProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      final initial = await container.read(exploreViewModelProvider.future);
      final vm = container.read(exploreViewModelProvider.notifier);
      expect(await vm.locateForFilter(), isNotNull);
      expect(repo.calls, hasLength(1));
      expect(
        container.read(exploreViewModelProvider).requireValue.query,
        same(initial.query),
      );
      await vm.applySelection(
        const ExploreFilterSelection(
          lat: -12.1,
          lon: -77.1,
          radius: 25000,
          label: 'Miraflores, Lima',
          centerName: 'Miraflores, Lima',
        ),
      );
      await vm.refresh();
      await vm.more();
      final applied = container.read(exploreViewModelProvider).requireValue;
      expect(applied.locationLabel, 'Miraflores, Lima');
      expect(applied.centerName, 'Miraflores, Lima');
      expect(applied.query.radiusMeters, 25000);
      location.fail = true;
      expect(await vm.locateForFilter(), isNull);
      expect(
        container.read(exploreViewModelProvider).requireValue.query,
        same(applied.query),
      );
      expect(
        container.read(exploreViewModelProvider).requireValue.locationLabel,
        applied.locationLabel,
      );
      expect(
        container.read(exploreViewModelProvider).requireValue.notice,
        contains('permiso'),
      );
      expect(repo.calls, hasLength(4));
    },
  );

  test(
    'Draft GPS deduplicates and discards responses belonging to a previous account',
    () async {
      final sessions = StreamController<AuthSession?>.broadcast();
      final location = DraftLocation();
      final repo = SearchFake();
      final container = ProviderContainer(
        overrides: [
          exploreRepositoryProvider.overrideWithValue(repo),
          currentLocationRepositoryProvider.overrideWithValue(location),
          exploreSessionProvider.overrideWith((_) => sessions.stream),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await sessions.close();
      });
      final subscription = container.listen(
        exploreViewModelProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      await Future<void>.delayed(Duration.zero);
      sessions.add(const AuthSession(userId: 'a'));
      await container.read(exploreViewModelProvider.future);
      final vm = container.read(exploreViewModelProvider.notifier);
      final pending = location.pending = Completer<SearchPlace>();
      final old = vm.locateForFilter();
      expect(await vm.locateForFilter(), isNull);
      expect(location.calls, 2);
      location.pending = null;
      sessions.add(const AuthSession(userId: 'b'));
      await Future<void>.delayed(Duration.zero);
      await container.read(exploreViewModelProvider.future);
      pending.complete(
        const SearchPlace(
          label: 'Private old city',
          latitude: 20,
          longitude: 20,
        ),
      );
      expect(await old, isNull);
      expect(container.read(exploreViewModelProvider).requireValue.owner, 'b');
      expect(
        container.read(exploreViewModelProvider).requireValue.locationLabel,
        isEmpty,
      );
      expect(repo.calls, hasLength(2));
    },
  );
}
