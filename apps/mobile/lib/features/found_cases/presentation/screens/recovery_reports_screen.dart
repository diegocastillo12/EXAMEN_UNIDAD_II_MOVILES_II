import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/case_screen_shell.dart';
import '../../../../core/presentation/widgets/collection_header.dart';
import '../../../../core/presentation/widgets/collection_add_button.dart';
import '../../../../core/presentation/widgets/managed_case_collection.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/confirm_discard_action.dart';
import '../../../../core/presentation/widgets/entity_card_content.dart';
import '../../../../core/presentation/widgets/entity_card_surface.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../domain/entities/recovery_report.dart';
import '../view_models/recovery_reports_view_model.dart';
import '../widgets/found_public_content.dart' show foundSpeciesLabel;

String _title(RecoveryReport value) => value.fromPet
    ? (value.petCase!.petName.isEmpty
          ? 'Mascota perdida'
          : value.petCase!.petName)
    : '${switch (value.report!.reportKind) {
        'possible_loss' => 'Posiblemente perdida',
        'sighting' => 'Avistamiento',
        'independent_found' || 'with_reporter' => 'Encontrada',
        _ => 'Reporte anterior',
      }} · ${foundSpeciesLabel(value.report!.species)}';
String _subtitle(RecoveryReport value) => value.pending
    ? (value.status == 'draft'
          ? 'Envío pendiente sin publicar'
          : 'Limpieza de fotos pendiente')
    : value.fromPet || value.report!.reportKind == 'possible_loss'
    ? (value.status == 'active' ? 'Búsqueda abierta' : 'Búsqueda resuelta')
    : value.report!.reportKind == 'independent_found'
    ? (value.status == 'active'
          ? 'Hallazgo sin familia identificada'
          : 'Hallazgo retirado')
    : value.report!.reportKind == 'legacy_found'
    ? 'Reporte anterior'
    : (value.status == 'active'
          ? 'Aviso en una búsqueda abierta'
          : 'Aviso en una búsqueda cerrada');

class RecoveryReportsScreen extends ConsumerWidget {
  const RecoveryReportsScreen({required this.onReport, super.key});
  final void Function(BuildContext source, VoidCallback onReturn) onReport;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recoveryReportsViewModelProvider);
    final model = ref.read(recoveryReportsViewModelProvider.notifier);
    final value = async.isLoading ? null : async.asData?.value;
    void refresh() {
      if (context.mounted) {
        ref.read(recoveryReportsViewModelProvider.notifier).retry();
      }
    }

    return CaseScreenShell(
      title: 'Mis reportes',
      header: CollectionHeader(
        title: 'Mis reportes',
        action: CollectionAddButton(
          label: 'Nuevo reporte',
          compact: true,
          onAction: (source) => onReport(source, refresh),
        ),
      ),
      loading: async.isLoading,
      notice: async.hasError
          ? 'No pudimos consultar tus reportes.'
          : value?.notice ??
                (value?.refreshFailed == true
                    ? 'No pudimos actualizar. Se conserva la última consulta.'
                    : null),
      noticeIsError:
          async.hasError ||
          value?.noticeIsError == true ||
          value?.refreshFailed == true,
      noticeId: async.error ?? value,
      child: async.isLoading
          ? const SkeletonFormFields(fieldCount: 3)
          : async.hasError
          ? TextButton(onPressed: model.retry, child: const Text('Reintentar'))
          : ContentRefresh(
              refreshing: value!.refreshing,
              label: 'Actualizando reportes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ManagedCaseCollection(
                    emptyActiveLabel: 'No tienes reportes abiertos',
                    emptyResolvedLabel: 'No tienes reportes resueltos',
                    deleteTitle: '¿Eliminar reporte?',
                    items: [
                      for (final report in value.reports)
                        ManagedCaseItem(
                          id: report.key,
                          title: _title(report),
                          status: report.status,
                          coverUri: report.coverUri,
                          subtitle: _subtitle(report),
                        ),
                    ],
                    busyId: value.busyId,
                    disabled: value.refreshing,
                    onOpen: (key, origin) async {
                      final report = value.reports.singleWhere(
                        (r) => r.key == key,
                      );
                      await context.push(
                        '/home/${report.fromPet ? 'cases' : 'found-cases'}/${report.id}',
                        extra: origin,
                      );
                      refresh();
                    },
                    onDelete: (key) => model.remove(
                      value.reports.singleWhere((r) => r.key == key),
                    ),
                    pending: Column(
                      children: [
                        for (final report in value.reports.where(
                          (r) => r.pending,
                        ))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EntityCardSurface(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  EntityCardContent(
                                    title: _title(report),
                                    subtitle: _subtitle(report),
                                    imageUri: report.coverUri,
                                    showChevron: false,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed:
                                          value.refreshing ||
                                              value.busyId != null
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
                                                await model.remove(report);
                                              }
                                            },
                                      child: const Text('Descartar envío'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (value.refreshFailed)
                    TextButton(
                      onPressed: model.retry,
                      child: const Text('Reintentar'),
                    ),
                ],
              ),
            ),
    );
  }
}
