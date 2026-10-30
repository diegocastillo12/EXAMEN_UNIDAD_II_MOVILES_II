import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/explore_query.dart';
import '../../domain/failures/explore_failure.dart';
import '../../providers/explore_providers.dart';
import '../state/explore_state.dart';
import '../state/explore_filter_selection.dart';
import '../../../places/domain/entities/search_place.dart';

final exploreViewModelProvider =
    AsyncNotifierProvider.autoDispose<ExploreViewModel, ExploreState>(
      ExploreViewModel.new,
      retry: (_, _) => null,
    );

class ExploreViewModel extends AsyncNotifier<ExploreState> {
  int _generation = 0;

  @override
  Future<ExploreState> build() async {
    final generation = ++_generation;
    final session = await ref.watch(exploreSessionProvider.future);
    if (session == null) {
      throw const ExploreFailure(ExploreFailureKind.forbidden);
    }
    ExploreQuery query;
    try {
      final center = await ref.read(getCurrentExploreLocationProvider)();
      if (!ref.mounted || generation != _generation) {
        throw const ExploreFailure(ExploreFailureKind.forbidden);
      }
      query = ExploreQuery(
        latitude: center.latitude,
        longitude: center.longitude,
        radiusMeters: 15000,
      );
    } catch (error) {
      return ExploreState(
        owner: session.userId,
        query: const ExploreQuery(radiusMeters: 15000),
        items: const [],
        notice: _locationNotice(error),
        noticeId: 1,
      );
    }
    try {
      final page = await ref.read(searchCasesProvider)(session.userId, query);
      return ExploreState(
        owner: session.userId,
        query: query,
        items: page.items,
        cursor: page.nextCursor,
        centerName: 'Ubicación actual',
      );
    } catch (_) {
      return ExploreState(
        owner: session.userId,
        query: query,
        items: const [],
        failed: true,
        notice: 'No pudimos consultar los casos. Puedes reintentar.',
        centerName: 'Ubicación actual',
        noticeId: 1,
      );
    }
  }

  Future<void> apply({
    required ExploreKind kind,
    required ExploreSpecies species,
    required ExploreStatus status,
    required int days,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    String? locationLabel,
    String? centerName,
  }) async {
    final now = DateTime.now().toUtc();
    final query = ExploreQuery(
      kind: kind,
      species: species,
      status: status,
      since: days == 0 ? null : now.subtract(Duration(days: days)),
      until: days == 0 ? null : now,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );
    final current = state.isLoading ? null : state.asData?.value;
    if (current == null || current.busy) return;
    if (!query.valid ||
        latitude == null ||
        longitude == null ||
        radiusMeters == null) {
      state = AsyncData(
        ExploreState(
          owner: current.owner,
          query: current.query,
          items: current.items,
          cursor: current.cursor,
          failed: current.failed,
          notice:
              'Selecciona una ubicación en el mapa para filtrar por distancia.',
          noticeId: current.noticeId + 1,
          locationLabel: current.locationLabel,
          centerName: current.centerName,
        ),
      );
      return;
    }
    await _load(
      current,
      query: query,
      replace: true,
      locationLabel: locationLabel,
      centerName: centerName,
    );
  }

  Future<void> applySelection(ExploreFilterSelection selection) => apply(
    kind: selection.kind,
    species: selection.species,
    status: selection.status,
    days: selection.days,
    latitude: selection.lat,
    longitude: selection.lon,
    radiusMeters: selection.radius,
    locationLabel: selection.label,
    centerName: selection.centerName,
  );

  int? _filterLocationGeneration;
  Future<SearchPlace?> locateForFilter() async {
    final old = state.asData?.value;
    if (old == null || old.busy || _filterLocationGeneration == _generation) {
      return null;
    }
    _filterLocationGeneration = _generation;
    final generation = _generation;
    try {
      final place = await ref.read(getCurrentExploreLocationProvider)();
      if (!ref.mounted ||
          generation != _generation ||
          state.asData?.value.owner != old.owner) {
        return null;
      }
      return place;
    } catch (error) {
      if (ref.mounted &&
          generation == _generation &&
          state.asData?.value.owner == old.owner) {
        state = AsyncData(
          ExploreState(
            owner: old.owner,
            query: old.query,
            items: old.items,
            cursor: old.cursor,
            failed: old.failed,
            locationLabel: old.locationLabel,
            centerName: old.centerName,
            notice: _locationNotice(error),
            noticeId: old.noticeId + 1,
          ),
        );
      }
      return null;
    } finally {
      if (_filterLocationGeneration == generation) {
        _filterLocationGeneration = null;
      }
    }
  }

  Future<void> refresh() async {
    final current = state.isLoading ? null : state.asData?.value;
    if (current == null) {
      ref.invalidateSelf();
      return;
    }
    if (current.needsLocation) {
      await useCurrentLocation();
      return;
    }
    if (!current.busy) {
      await _load(current, query: current.query, replace: true);
    }
  }

  Future<void> more() async {
    final current = state.isLoading ? null : state.asData?.value;
    if (current == null ||
        current.busy ||
        current.needsLocation ||
        current.cursor == null) {
      return;
    }
    await _load(current, query: current.query, replace: false);
  }

  Future<void> useCurrentLocation() async {
    final old = state.asData?.value;
    if (old == null || old.busy) return;
    final generation = ++_generation;
    state = AsyncData(
      ExploreState(
        owner: old.owner,
        query: old.query,
        items: old.items,
        cursor: old.cursor,
        refreshing: true,
        noticeId: old.noticeId,
        locationLabel: old.locationLabel,
        centerName: old.centerName,
      ),
    );
    try {
      final center = await ref.read(getCurrentExploreLocationProvider)();
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      final previous = old.query;
      await _load(
        old,
        query: ExploreQuery(
          kind: previous.kind,
          species: previous.species,
          status: previous.status,
          since: previous.since,
          until: previous.until,
          latitude: center.latitude,
          longitude: center.longitude,
          radiusMeters: previous.radiusMeters ?? 15000,
        ),
        replace: true,
        locationLabel: '',
        centerName: 'Ubicación actual',
      );
    } catch (error) {
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      state = AsyncData(
        ExploreState(
          owner: old.owner,
          query: old.query,
          items: old.items,
          cursor: old.cursor,
          failed: old.failed,
          notice: _locationNotice(error),
          noticeId: old.noticeId + 1,
          locationLabel: old.locationLabel,
          centerName: old.centerName,
        ),
      );
    }
  }

  String _locationNotice(Object error) => switch (error) {
    ExploreFailure(kind: ExploreFailureKind.locationDenied) =>
      'No tenemos permiso de ubicación. Puedes habilitarlo en Ajustes o elegir una ubicación manualmente.',
    ExploreFailure(kind: ExploreFailureKind.locationDisabled) =>
      'Activa la ubicación del dispositivo o elige una ubicación manualmente.',
    _ =>
      'No pudimos obtener tu ubicación actual. Puedes reintentar o elegirla manualmente.',
  };

  Future<void> _load(
    ExploreState old, {
    required ExploreQuery query,
    required bool replace,
    String? locationLabel,
    String? centerName,
  }) async {
    final g = ++_generation;
    // A different query must never display results from the preceding filters.
    final same = identical(query, old.query);
    final samePoint =
        query.latitude == old.query.latitude &&
        query.longitude == old.query.longitude;
    final appliedLabel = locationLabel ?? (samePoint ? old.locationLabel : '');
    final appliedName = centerName ?? (samePoint ? old.centerName : '');
    final retained = same ? old.items : <Never>[];
    state = AsyncData(
      ExploreState(
        owner: old.owner,
        locationLabel: appliedLabel,
        centerName: appliedName,
        query: query,
        items: retained,
        cursor: replace ? null : old.cursor,
        refreshing: replace,
        applying: replace && !same,
        appending: !replace,
        noticeId: old.noticeId,
      ),
    );
    try {
      final page = await ref.read(searchCasesProvider)(
        old.owner,
        query,
        cursor: replace ? null : old.cursor,
      );
      if (!ref.mounted || g != _generation || state.isLoading) return;
      final items = replace
          ? page.items
          : [
              ...old.items,
              ...page.items.where((v) => !old.items.any((p) => p.key == v.key)),
            ];
      if (!replace && page.nextCursor == old.cursor) {
        throw const ExploreFailure(ExploreFailureKind.unavailable);
      }
      state = AsyncData(
        ExploreState(
          owner: old.owner,
          locationLabel: appliedLabel,
          centerName: appliedName,
          query: query,
          items: items,
          cursor: page.nextCursor,
          noticeId: old.noticeId,
        ),
      );
    } catch (_) {
      if (!ref.mounted || g != _generation || state.isLoading) return;
      state = AsyncData(
        ExploreState(
          owner: old.owner,
          locationLabel: appliedLabel,
          centerName: appliedName,
          query: query,
          items: retained,
          cursor: replace ? null : old.cursor,
          failed: true,
          notice: replace
              ? 'No pudimos consultar los casos. Puedes reintentar.'
              : 'No pudimos traer más casos. Puedes reintentar.',
          noticeId: old.noticeId + 1,
        ),
      );
    }
  }
}
