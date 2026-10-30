import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/state/retained_read.dart';
import '../../../pets/providers/pet_providers.dart'
    show notifyPetChangedProvider;
import '../../domain/entities/found_case.dart';
import '../../domain/entities/recovery_report.dart';
import '../../providers/found_case_providers.dart';
import '../state/recovery_reports_state.dart';

final recoveryReportsViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      RecoveryReportsViewModel,
      RecoveryReportsState
    >(RecoveryReportsViewModel.new, retry: (_, _) => null);

class RecoveryReportsViewModel extends AsyncNotifier<RecoveryReportsState> {
  int _generation = 0;
  @override
  Future<RecoveryReportsState> build() async {
    _generation++;
    final session = await ref.watch(foundSessionProvider.future);
    if (session == null) throw const FoundFailure(FoundFailureKind.forbidden);
    return RecoveryReportsState(
      ownerId: session.userId,
      reports: await ref.watch(listRecoveryReportsProvider)(session.userId),
    );
  }

  bool _current(int g) => ref.mounted && g == _generation && !state.isLoading;
  Future<void> retry() async {
    final current = state.isLoading ? null : state.asData?.value;
    if (current == null) {
      ref.invalidateSelf();
      return;
    }
    if (current.refreshing || current.busyId != null) return;
    final g = _generation;
    state = AsyncData(
      RecoveryReportsState(
        ownerId: current.ownerId,
        reports: current.reports,
        refreshing: true,
      ),
    );
    await retainedRead(
      request: () => ref.read(listRecoveryReportsProvider)(current.ownerId),
      isCurrent: () => _current(g),
      onSuccess: (rows) => state = AsyncData(
        RecoveryReportsState(ownerId: current.ownerId, reports: rows),
      ),
      onFailure: () => state = AsyncData(
        RecoveryReportsState(
          ownerId: current.ownerId,
          reports: current.reports,
          refreshFailed: true,
        ),
      ),
    );
  }

  Future<void> remove(RecoveryReport item) async {
    final current = state.isLoading ? null : state.asData?.value;
    if (current == null ||
        current.busyId != null ||
        current.refreshing ||
        !current.reports.any((r) => r.key == item.key)) {
      return;
    }
    final g = _generation;
    state = AsyncData(
      RecoveryReportsState(
        ownerId: current.ownerId,
        reports: current.reports,
        busyId: item.key,
        noticeId: current.noticeId,
      ),
    );
    try {
      await ref.read(removeRecoveryReportProvider)(current.ownerId, item);
      if (!_current(g)) return;
      if (item.fromPet) {
        ref.read(notifyPetChangedProvider)(
          current.ownerId,
          item.petCase!.petId,
        );
      }
      // Draft removal can leave a cleanup tombstone; retain its real server state.
      final rows = item.pending
          ? await ref.read(listRecoveryReportsProvider)(current.ownerId)
          : current.reports.where((r) => r.key != item.key).toList();
      if (!_current(g)) return;
      state = AsyncData(
        RecoveryReportsState(
          ownerId: current.ownerId,
          reports: rows,
          notice: item.pending ? 'Envío descartado' : 'Reporte eliminado',
          noticeId: current.noticeId + 1,
        ),
      );
    } catch (_) {
      if (!_current(g)) return;
      state = AsyncData(
        RecoveryReportsState(
          ownerId: current.ownerId,
          reports: current.reports,
          notice: 'No pudimos retirar el reporte. Puedes reintentarlo.',
          noticeIsError: true,
          noticeId: current.noticeId + 1,
        ),
      );
    }
  }
}
