import '../../../../core/domain/utils/new_entity_id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/interest_zone.dart';
import '../../domain/entities/zone_point.dart';
import '../../domain/failures/zone_failure.dart';
import '../../providers/interest_zone_providers.dart';
import '../state/zone_view_state.dart';

final interestZonesViewModelProvider =
    AsyncNotifierProvider.autoDispose<InterestZonesViewModel, ZoneViewState>(
      InterestZonesViewModel.new,
      retry: (_, _) => null,
    );

class InterestZonesViewModel extends AsyncNotifier<ZoneViewState> {
  int _generation = 0;
  @override
  Future<ZoneViewState> build() async {
    _generation++;
    final list = ref.watch(listInterestZonesProvider);
    final session = await ref.watch(zoneSessionProvider.future);
    if (session == null) throw const ZoneFailure(ZoneFailureKind.signedOut);
    return ZoneViewState(
      ownerId: session.userId,
      zones: await list(session.userId),
    );
  }

  void retry() => ref.invalidateSelf();
  void chooseCoordinates(String latitude, String longitude) {
    final current = state.asData?.value;
    if (current?.draft == null || current!.busy || state.isLoading) return;
    try {
      final point = ZonePoint.parse(latitude, longitude);
      edit(latitude: point.latitude, longitude: point.longitude);
    } on ZoneFailure catch (error) {
      state = AsyncData(
        current.copyWith(issue: error.kind, errorId: current.errorId + 1),
      );
    }
  }

  bool _current(int generation, String owner) =>
      ref.mounted &&
      _generation == generation &&
      !state.isLoading &&
      state.asData?.value.ownerId == owner;
  void startEditor([InterestZone? zone]) {
    final current = state.asData?.value;
    if (current == null ||
        current.busy ||
        current.refreshing ||
        state.isLoading) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        draft: ZoneDraft(
          id: zone?.id ?? newEntityId(),
          name: zone?.name ?? '',
          latitude: zone?.latitude,
          longitude: zone?.longitude,
          radiusMeters: zone?.radiusMeters ?? 1000,
          version: zone?.version ?? 0,
        ),
        clearIssue: true,
        clearConfirmation: true,
      ),
    );
  }

  void discard() {
    final current = state.asData?.value;
    if (current == null || current.busy || state.isLoading) return;
    state = AsyncData(
      current.copyWith(
        clearDraft: true,
        clearIssue: true,
        clearConfirmation: true,
      ),
    );
  }

  void edit({
    String? name,
    double? latitude,
    double? longitude,
    int? radiusMeters,
  }) {
    final current = state.asData?.value;
    if (current?.draft == null || current!.busy || state.isLoading) return;
    state = AsyncData(
      current.copyWith(
        draft: current.draft!.copyWith(
          name: name,
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
        ),
        clearIssue: true,
        clearConfirmation: true,
      ),
    );
  }

  Future<void> save() async {
    final current = state.asData?.value;
    if (current?.draft == null || current!.busy || state.isLoading) return;
    final generation = _generation;
    final keepAlive = ref.keepAlive();
    state = AsyncData(
      current.copyWith(busy: true, clearIssue: true, clearConfirmation: true),
    );
    try {
      final saved = await ref.read(saveInterestZoneProvider)(
        current.ownerId,
        current.draft!,
      );
      if (!_current(generation, current.ownerId)) return;
      final zones = [...current.zones];
      final index = zones.indexWhere((zone) => zone.id == saved.id);
      if (index < 0) {
        zones.add(saved);
      } else {
        zones[index] = saved;
      }
      state = AsyncData(
        current.copyWith(
          zones: zones,
          clearDraft: true,
          busy: false,
          clearIssue: true,
          confirmation: 'Ubicación guardada',
          noticeId: current.noticeId + 1,
        ),
      );
    } catch (error) {
      if (_current(generation, current.ownerId)) {
        state = AsyncData(
          current.copyWith(
            busy: false,
            issue: error is ZoneFailure ? error.kind : ZoneFailureKind.network,
            errorId: current.errorId + 1,
          ),
        );
      }
    } finally {
      keepAlive.close();
    }
  }

  Future<void> delete(InterestZone zone) async {
    final current = state.asData?.value;
    if (current == null ||
        current.busy ||
        current.refreshing ||
        state.isLoading) {
      return;
    }
    final generation = _generation;
    final keepAlive = ref.keepAlive();
    state = AsyncData(
      current.copyWith(
        busy: true,
        busyZoneId: zone.id,
        clearIssue: true,
        clearConfirmation: true,
      ),
    );
    try {
      await ref.read(deleteInterestZoneProvider)(current.ownerId, zone);
      if (!_current(generation, current.ownerId)) return;
      state = AsyncData(
        current.copyWith(
          zones: current.zones.where((item) => item.id != zone.id).toList(),
          busy: false,
          clearIssue: true,
          confirmation: 'Ubicación eliminada',
          noticeId: current.noticeId + 1,
        ),
      );
    } catch (error) {
      if (_current(generation, current.ownerId)) {
        state = AsyncData(
          current.copyWith(
            busy: false,
            issue: error is ZoneFailure ? error.kind : ZoneFailureKind.network,
            errorId: current.errorId + 1,
          ),
        );
      }
    } finally {
      keepAlive.close();
    }
  }

  Future<void> refresh() async {
    final current = state.asData?.value;
    if (current == null ||
        current.busy ||
        current.refreshing ||
        state.isLoading) {
      return;
    }
    final generation = _generation;
    state = AsyncData(
      current.copyWith(
        refreshing: true,
        clearIssue: true,
        clearConfirmation: true,
      ),
    );
    try {
      final zones = await ref.read(listInterestZonesProvider)(current.ownerId);
      if (_current(generation, current.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(zones: zones, refreshing: false),
        );
      }
    } catch (error) {
      if (_current(generation, current.ownerId)) {
        state = AsyncData(
          state.requireValue.copyWith(
            refreshing: false,
            issue: error is ZoneFailure ? error.kind : ZoneFailureKind.network,
            errorId: state.requireValue.errorId + 1,
          ),
        );
      }
    }
  }
}
