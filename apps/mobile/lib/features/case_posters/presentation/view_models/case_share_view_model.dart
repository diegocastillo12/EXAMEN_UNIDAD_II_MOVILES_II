import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/case_poster.dart';
import '../../domain/entities/case_share.dart';
import '../../providers/case_poster_providers.dart';
import '../state/case_share_state.dart';

final caseShareViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<CaseShareViewModel, CaseShareState, PosterCase>(
      CaseShareViewModel.new,
      retry: (_, _) => null,
    );

class CaseShareViewModel extends AsyncNotifier<CaseShareState> {
  CaseShareViewModel(this.target);
  final PosterCase target;
  int _generation = 0;
  @override
  Future<CaseShareState> build() async {
    _generation++;
    final session = await ref.watch(posterSessionProvider.future);
    if (session == null) throw const PosterFailure(PosterFailureKind.forbidden);
    return CaseShareState(actor: session.userId);
  }

  void retry() => ref.invalidateSelf();
  Future<void> execute(CaseShareChannel channel) async {
    final old = state.isLoading ? null : state.asData?.value;
    if (old == null || old.busy) return;
    final generation = ++_generation;
    state = AsyncData(
      CaseShareState(actor: old.actor, action: channel, noticeId: old.noticeId),
    );
    try {
      final result = await ref.read(sharePublicCaseProvider)(
        old.actor,
        target,
        channel,
      );
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      state = AsyncData(
        CaseShareState(
          actor: old.actor,
          noticeId: old.noticeId + 1,
          notice: switch (result) {
            CaseShareResult.copied => 'Enlace copiado',
            CaseShareResult.cancelled => 'Acción cancelada. Puedes reintentar.',
            CaseShareResult.unconfirmed =>
              'Confirma el resultado en la aplicación elegida.',
            CaseShareResult.opened =>
              channel == CaseShareChannel.download
                  ? 'Se abrió la opción de imprimir o guardar el PDF.'
                  : 'Se abrió la opción de compartir.',
          },
        ),
      );
    } catch (error) {
      if (!ref.mounted || generation != _generation || state.isLoading) return;
      state = AsyncData(
        CaseShareState(
          actor: old.actor,
          noticeId: old.noticeId + 1,
          isError: true,
          notice: switch (error) {
            PosterFailure(kind: PosterFailureKind.notConfigured) =>
              'El enlace público aún no está habilitado.',
            PosterFailure(kind: PosterFailureKind.forbidden) =>
              'Este enlace no se puede compartir. Vuelve a consultar la ficha.',
            PosterFailure(kind: PosterFailureKind.inactive) =>
              'Esta ficha no dispone de un enlace público activo con foto.',
            PosterFailure(kind: PosterFailureKind.stale) =>
              'La ficha cambió. Reintenta con sus datos actuales.',
            _ => 'No pudimos completar la acción. Puedes reintentar.',
          },
        ),
      );
    }
  }
}
