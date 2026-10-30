import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/case_contact.dart';
import '../../providers/case_contact_providers.dart';
import '../state/case_contact_state.dart';

final caseContactViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<CaseContactViewModel, CaseContactState, CaseContactTarget>(
      CaseContactViewModel.new,
      retry: (_, _) => null,
    );

class CaseContactViewModel extends AsyncNotifier<CaseContactState> {
  CaseContactViewModel(this.target);
  final CaseContactTarget target;
  int _generation = 0;

  @override
  Future<CaseContactState> build() async {
    _generation++;
    final session = await ref.watch(caseContactSessionProvider.future);
    if (session == null) {
      throw const CaseContactFailure(CaseContactFailureKind.forbidden);
    }
    final access = await ref.watch(readCaseContactProvider)(
      session.userId,
      target,
    );
    return CaseContactState(owner: session.userId, access: access);
  }

  void retry() => ref.invalidateSelf();
  bool _current(int generation) =>
      ref.mounted && generation == _generation && !state.isLoading;

  Future<void> save(CaseContactDraft draft) async {
    final old = state.asData?.value;
    if (old == null ||
        old.busy ||
        !old.access.canEdit ||
        old.issue == CaseContactFailureKind.conflict ||
        old.issue == CaseContactFailureKind.forbidden) {
      return;
    }
    final pending = old.pending ?? draft;
    final generation = _generation;
    state = AsyncData(
      CaseContactState(
        owner: old.owner,
        access: old.access,
        busy: true,
        pending: pending,
        notice: old.notice,
      ),
    );
    try {
      final saved = await ref.read(saveCaseContactProvider)(
        old.owner,
        target,
        pending,
      );
      if (_current(generation)) {
        state = AsyncData(
          CaseContactState(
            owner: old.owner,
            access: saved,
            confirmed: true,
            notice: old.notice + 1,
          ),
        );
      }
    } catch (error) {
      if (!_current(generation)) return;
      final kind = error is CaseContactFailure
          ? error.kind
          : CaseContactFailureKind.unavailable;
      state = AsyncData(
        CaseContactState(
          owner: old.owner,
          access: old.access,
          pending: kind == CaseContactFailureKind.unavailable ? pending : null,
          issue: kind,
          notice: old.notice + 1,
        ),
      );
    }
  }

  Future<void> open({required bool message}) async {
    final old = state.asData?.value;
    final phone = old?.access.contact?.phone;
    if (old == null || old.busy || phone == null) return;
    final generation = _generation;
    state = AsyncData(
      CaseContactState(
        owner: old.owner,
        access: old.access,
        busy: true,
        notice: old.notice,
      ),
    );
    try {
      // Recheck consent/visibility before handing a number to another app.
      final access = await ref.read(readCaseContactProvider)(old.owner, target);
      if (!_current(generation)) return;
      if (access.contact?.phone != phone) {
        state = AsyncData(
          CaseContactState(
            owner: old.owner,
            access: access,
            issue: CaseContactFailureKind.conflict,
            notice: old.notice + 1,
          ),
        );
        return;
      }
      await ref.read(openCaseContactProvider)(phone, message: message);
      if (_current(generation)) {
        state = AsyncData(
          CaseContactState(
            owner: old.owner,
            access: access,
            notice: old.notice,
          ),
        );
      }
    } catch (_) {
      if (_current(generation)) {
        state = AsyncData(
          CaseContactState(
            owner: old.owner,
            access: old.access,
            issue: CaseContactFailureKind.unavailable,
            notice: old.notice + 1,
          ),
        );
      }
    }
  }
}
