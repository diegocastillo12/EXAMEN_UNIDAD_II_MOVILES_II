import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/entity_screen_shell.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../domain/entities/case_poster.dart';
import '../view_models/case_poster_view_model.dart';

class CasePosterScreen extends ConsumerWidget {
  const CasePosterScreen({required this.target, super.key});
  final PosterCase target;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(casePosterViewModelProvider(target));
    final value = async.isLoading || async.hasError
        ? null
        : async.asData?.value;
    final model = ref.read(casePosterViewModelProvider(target).notifier);
    final doc = value?.document;
    return ConfirmationToastHost(
      confirmed: async.hasError || value?.notice != null,
      message: async.hasError
          ? 'No pudimos preparar el cartel. Revisa tu sesión y reintenta.'
          : value?.notice ?? '',
      isError: async.hasError || value?.isError == true,
      noticeId: (async.error, value?.owner, value?.noticeId),
      child: EntityScreenShell(
        title: 'Cartel con QR',
        loading: async.isLoading,
        stage: doc == null ? 'prepare' : 'ready',
        count: 6,
        child: async.hasError
            ? TextButton(
                onPressed: model.retry,
                child: const Text('Reintentar'),
              )
            : async.isLoading
            ? const LoadingShimmer(
                isLoading: true,
                loadingLabel: 'Preparando cartel',
                child: SizedBox(
                  height: 280,
                  child: ColoredBox(color: Color(0xFFF5F5F7)),
                ),
              )
            : value == null
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const StaggerRevealItem(
                    order: 0,
                    child: Text(
                      'Difunde la búsqueda con una foto pública, sus datos y un QR para consultar el estado actual.',
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (doc != null)
                    StaggerRevealItem(
                      order: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.memory(
                            doc.content.photo,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  if (doc != null) const SizedBox(height: 16),
                  if (!value.configured)
                    const StaggerRevealItem(
                      order: 1,
                      child: Text(
                        'El cartel estará disponible cuando la ficha pública pueda abrirse sin instalar la app.',
                      ),
                    ),
                  StaggerRevealItem(
                    order: 2,
                    child: _Action(
                      label: doc == null
                          ? 'Generar cartel'
                          : 'Generar de nuevo',
                      busy: value.generating,
                      enabled: !value.busy,
                      onPressed: model.generate,
                    ),
                  ),
                  if (doc != null) ...[
                    const SizedBox(height: 12),
                    StaggerRevealItem(
                      order: 3,
                      child: _Action(
                        label: 'Imprimir o guardar PDF',
                        busy: value.exporting == PosterExportAction.savePdf,
                        enabled: !value.busy,
                        onPressed: () =>
                            model.export(PosterExportAction.savePdf),
                      ),
                    ),
                    const SizedBox(height: 12),
                    StaggerRevealItem(
                      order: 4,
                      child: _Action(
                        label: 'Compartir PDF',
                        busy: value.exporting == PosterExportAction.sharePdf,
                        enabled: !value.busy,
                        onPressed: () =>
                            model.export(PosterExportAction.sharePdf),
                      ),
                    ),
                    StaggerRevealItem(
                      order: 5,
                      child: LoadingShimmer(
                        isLoading:
                            value.exporting == PosterExportAction.shareLink,
                        loadingLabel: 'Abriendo opciones para compartir enlace',
                        child: TextButton(
                          onPressed: value.busy
                              ? null
                              : () =>
                                    model.export(PosterExportAction.shareLink),
                          child: const Text('Compartir enlace'),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    'Solo se incluyen datos y fotos públicos. La ubicación exacta y los documentos privados no forman parte del cartel.',
                    style: TextStyle(color: Color(0xFF6E6E73)),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.busy,
    required this.enabled,
    required this.onPressed,
  });
  final String label;
  final bool busy, enabled;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => LoadingShimmer(
    isLoading: busy,
    loadingLabel: label,
    child: FilledButton(
      onPressed: enabled ? onPressed : null,
      style: primaryActionButtonStyle(context, isLoading: busy),
      child: Text(label, textAlign: TextAlign.center),
    ),
  );
}
