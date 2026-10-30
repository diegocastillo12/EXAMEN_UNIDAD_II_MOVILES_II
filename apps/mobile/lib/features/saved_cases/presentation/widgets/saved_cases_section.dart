import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/public_case_grid.dart';
import '../../../../core/presentation/widgets/pull_to_refresh.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../view_models/saved_case_list_view_model.dart';
import '../../providers/saved_cases_providers.dart';

class SavedCasesSection extends ConsumerWidget {
  const SavedCasesSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savedCaseListViewModelProvider);
    final data = async.isLoading || async.hasError ? null : async.asData?.value;
    final model = ref.read(savedCaseListViewModelProvider.notifier);
    return PullToRefreshTarget(
      onRefresh: model.refresh,
      enabled: !async.isLoading && data?.busy != true,
      child: ConfirmationToastHost(
        confirmed: async.hasError || data?.notice != null,
        isError: data?.noticeIsError ?? true,
        message:
            data?.notice ??
            'No pudimos consultar tus casos guardados. Puedes reintentar.',
        noticeId: (async.error, data?.owner, data?.noticeId),
        child: async.isLoading
            ? const LoadingShimmer(
                isLoading: true,
                loadingLabel: 'Consultando guardados',
                child: PublicCaseGrid.skeleton(),
              )
            : async.hasError
            ? TextButton(
                onPressed: model.refresh,
                child: const Text('Reintentar'),
              )
            : data == null
            ? const SizedBox.shrink()
            : ContentRefresh(
                refreshing: data.refreshing,
                label: 'Actualizando guardados',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Favoritos de tu cuenta',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (data.offline)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          data.items.isEmpty
                              ? data.localUnavailable
                                    ? 'Datos locales no disponibles, conéctese para actualizar'
                                    : 'Conéctate para consultar tus favoritos actuales. Las fichas consultadas están disponibles arriba.'
                              : 'Sin conexión · Lista guardada en este teléfono, sin fotos. Los favoritos pueden haber cambiado; conéctate para actualizarlos.',
                        ),
                      ),
                    if (ref.watch(saveListOfflineProvider) != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: LoadingShimmer(
                          isLoading: data.saving,
                          loadingLabel: 'Guardando lista sin conexión',
                          child: FilledButton.icon(
                            style: primaryActionButtonStyle(
                              context,
                              isLoading: data.saving,
                            ),
                            onPressed:
                                data.busy || data.offline || data.items.isEmpty
                                ? null
                                : model.saveOffline,
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('Guardar sin conexión'),
                          ),
                        ),
                      ),
                    if (data.items.isEmpty && !data.failed && !data.offline)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Aún no tienes casos guardados disponibles. Guarda uno desde su ficha.',
                        ),
                      ),
                    PublicCaseGrid(
                      items: data.items,
                      onOpen: data.busy || data.offline
                          ? null
                          : (item, source) async {
                              final box =
                                  source.findRenderObject() as RenderBox?;
                              final origin = box == null
                                  ? null
                                  : box.localToGlobal(Offset.zero) & box.size;
                              await context.push(
                                '/home/${item.fromPet ? 'cases' : 'found-cases'}/${item.id}',
                                extra: origin,
                              );
                              if (context.mounted) {
                                await ref
                                    .read(
                                      savedCaseListViewModelProvider.notifier,
                                    )
                                    .refresh();
                              }
                            },
                    ),
                    if (data.failed || data.offline)
                      TextButton(
                        onPressed: data.busy ? null : model.retry,
                        child: const Text('Reintentar'),
                      )
                    else if (data.cursor != null)
                      LoadingShimmer(
                        isLoading: data.appending,
                        loadingLabel: 'Consultando más guardados',
                        child: TextButton(
                          onPressed: data.busy ? null : model.more,
                          child: const Text('Ver más casos'),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
