import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/entity_card_content.dart';
import '../../../../core/presentation/widgets/entity_card_surface.dart';
import '../../../../core/presentation/widgets/collection_add_button.dart';
import '../../../../core/presentation/widgets/collection_header.dart';
import '../../../../core/presentation/widgets/managed_case_collection.dart';
import '../widgets/found_public_content.dart';
import '../../../../core/presentation/widgets/confirm_discard_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../view_models/found_read_view_model.dart';
import '../../../../core/presentation/widgets/case_screen_shell.dart';

class MyFoundCasesScreen extends ConsumerWidget {
  const MyFoundCasesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myFoundCasesViewModelProvider);
    final model = ref.read(myFoundCasesViewModelProvider.notifier);
    return CaseScreenShell(
      title: 'Mis reportes',
      header: const CollectionHeader(
        title: 'Mis reportes',
        action: CollectionAddButton(
          label: 'Reportar mascota perdida',
          route: '/home/lost-cases/new',
          compact: true,
        ),
      ),
      loading: state.isLoading,
      noticeIsError:
          state.hasError ||
          state.asData?.value.noticeIsError == true ||
          state.asData?.value.refreshFailed == true,
      notice:
          state.asData?.value.notice ??
          (state.hasError
              ? 'No pudimos consultar tus casos.'
              : state.asData?.value.refreshFailed == true
              ? 'No pudimos actualizar. Se conserva la última consulta.'
              : null),
      noticeId: state.error ?? state.asData?.value,
      child: state.isLoading
          ? const SkeletonFormFields(fieldCount: 3)
          : state.hasError
          ? Column(
              children: [
                TextButton(
                  onPressed: model.retry,
                  child: const Text('Reintentar'),
                ),
              ],
            )
          : ContentRefresh(
              refreshing: state.requireValue.refreshing,
              label: 'Actualizando casos',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ManagedCaseCollection(
                    items: [
                      for (final item in state.requireValue.cases)
                        ManagedCaseItem(
                          id: item.id,
                          title:
                              '${item.reportKind == 'possible_loss'
                                  ? 'Posiblemente perdida'
                                  : item.reportKind == 'sighting'
                                  ? 'Avistamiento'
                                  : {'with_reporter', 'independent_found'}.contains(item.reportKind)
                                  ? 'Encontrada'
                                  : 'Reporte anterior'} · ${foundSpeciesLabel(item.species)}',
                          status: item.status,
                          subtitle: item.reportKind == 'possible_loss'
                              ? (item.status == 'active'
                                    ? 'Búsqueda abierta'
                                    : 'Búsqueda cerrada')
                              : item.reportKind == 'independent_found'
                              ? (item.status == 'active'
                                    ? 'Hallazgo sin familia identificada'
                                    : 'Hallazgo retirado')
                              : item.reportKind == 'legacy_found'
                              ? 'Reporte anterior'
                              : (item.status == 'active'
                                    ? 'Aviso vinculado a una búsqueda'
                                    : 'Aviso de una búsqueda cerrada'),
                          coverUri: item.coverUri,
                        ),
                    ],
                    busyId: state.requireValue.busyId,
                    disabled: state.requireValue.refreshing,
                    onOpen: (id, origin) =>
                        context.push('/home/found-cases/$id', extra: origin),
                    onDelete: (id) => model.delete(
                      state.requireValue.cases.singleWhere(
                        (item) => item.id == id,
                      ),
                    ),
                    pending: Column(
                      children: [
                        for (final item in state.requireValue.cases.where(
                          (c) => {'draft', 'discarded'}.contains(c.status),
                        ))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EntityCardSurface(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  EntityCardContent(
                                    title:
                                        '${item.reportKind == 'possible_loss'
                                            ? 'Posiblemente perdida'
                                            : item.reportKind == 'sighting'
                                            ? 'Avistamiento'
                                            : {'with_reporter', 'independent_found'}.contains(item.reportKind)
                                            ? 'Encontrada'
                                            : 'Reporte anterior'} · ${foundSpeciesLabel(item.species)}',
                                    subtitle: item.status == 'draft'
                                        ? 'Envío pendiente sin publicar'
                                        : 'Limpieza de fotos pendiente',
                                    imageUri: item.coverUri,
                                    showChevron: false,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed:
                                          state.requireValue.refreshing ||
                                              state.requireValue.busyId != null
                                          ? null
                                          : () async {
                                              final confirmed =
                                                  await confirmDiscardAction(
                                                    context,
                                                    '¿Descartar envío pendiente?',
                                                    'Se retirarán las fotos de este envío sin publicar.',
                                                    'Descartar',
                                                  );
                                              if (confirmed &&
                                                  context.mounted) {
                                                await model.discard(item.id);
                                              }
                                            },
                                      child: const Text('Descartar'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (state.requireValue.refreshFailed)
                    TextButton(
                      onPressed: state.requireValue.busyId != null
                          ? null
                          : model.retry,
                      child: const Text('Reintentar'),
                    ),
                ],
              ),
            ),
    );
  }
}
