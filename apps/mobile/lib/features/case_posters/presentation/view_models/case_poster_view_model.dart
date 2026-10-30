import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/case_poster.dart';
import '../../providers/case_poster_providers.dart';
import '../state/case_poster_state.dart';

final casePosterViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<CasePosterViewModel, CasePosterState, PosterCase>(
      CasePosterViewModel.new,
      retry: (_, _) => null,
    );

class CasePosterViewModel extends AsyncNotifier<CasePosterState> {
  CasePosterViewModel(this.target);
  final PosterCase target;
  int _generation = 0;
  @override
  Future<CasePosterState> build() async {
    final generation = ++_generation;
    ref.onDispose(() => _generation++);
    final session = await ref.watch(posterSessionProvider.future);
    if (session == null || !ref.mounted || generation != _generation) {
      throw const PosterFailure(PosterFailureKind.forbidden);
    }
    return CasePosterState(
      owner: session.userId,
      configured: ref.watch(casePosterRepositoryProvider).configured,
    );
  }

  void retry() => ref.invalidateSelf();
  Future<void> generate() async {
    final old = state.isLoading ? null : state.asData?.value;
    if (old == null || old.busy) return;
    final generation = ++_generation;
    state = AsyncData(
      CasePosterState(
        owner: old.owner,
        configured: old.configured,
        document: old.document,
        generating: true,
        noticeId: old.noticeId,
      ),
    );
    try {
      final doc = await ref.read(generateCasePosterProvider)(old.owner, target);
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      state = AsyncData(
        CasePosterState(
          owner: old.owner,
          configured: old.configured,
          document: doc,
          notice: 'Cartel generado.',
          noticeId: old.noticeId + 1,
        ),
      );
    } catch (error) {
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      state = AsyncData(
        CasePosterState(
          owner: old.owner,
          configured: old.configured,
          document: old.document,
          notice: _label(error),
          noticeId: old.noticeId + 1,
          isError: true,
        ),
      );
    }
  }

  Future<void> export(PosterExportAction action) async {
    final old = state.isLoading ? null : state.asData?.value;
    final doc = old?.document;
    if (old == null || doc == null || old.busy) return;
    final generation = ++_generation;
    state = AsyncData(
      CasePosterState(
        owner: old.owner,
        configured: old.configured,
        document: doc,
        exporting: action,
        noticeId: old.noticeId,
      ),
    );
    try {
      final result = await ref.read(exportCasePosterProvider)(
        old.owner,
        doc,
        action,
      );
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      state = AsyncData(
        CasePosterState(
          owner: old.owner,
          configured: old.configured,
          document: doc,
          notice: result == PosterExportResult.unconfirmed
              ? 'Confirma el resultado en la aplicación elegida.'
              : result == PosterExportResult.cancelled
              ? 'Acción cancelada. Puedes reintentar.'
              : action == PosterExportAction.savePdf
              ? 'Acción de impresión o guardado completada.'
              : 'Se abrió la opción de compartir.',
          noticeId: old.noticeId + 1,
        ),
      );
    } catch (error) {
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      final invalid =
          error is PosterFailure &&
          [
            PosterFailureKind.stale,
            PosterFailureKind.inactive,
            PosterFailureKind.forbidden,
          ].contains(error.kind);
      state = AsyncData(
        CasePosterState(
          owner: old.owner,
          configured: old.configured,
          document: invalid ? null : doc,
          notice: _label(error),
          noticeId: old.noticeId + 1,
          isError: true,
        ),
      );
    }
  }

  String _label(Object error) => switch (error) {
    PosterFailure(kind: PosterFailureKind.notConfigured) =>
      'La ficha web del QR aún no está habilitada.',
    PosterFailure(kind: PosterFailureKind.forbidden) =>
      'Solo el responsable puede generar o compartir este cartel.',
    PosterFailure(kind: PosterFailureKind.inactive) =>
      'El caso ya no está activo o no tiene una foto pública disponible.',
    PosterFailure(kind: PosterFailureKind.stale) =>
      'El caso cambió. Genera de nuevo el cartel.',
    _ => 'No pudimos completar la acción. Puedes reintentar.',
  };
}
