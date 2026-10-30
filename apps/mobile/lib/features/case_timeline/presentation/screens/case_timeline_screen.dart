import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/formatters/case_date_label.dart';
import '../../../../core/presentation/widgets/case_screen_shell.dart';
import '../../../../core/presentation/widgets/collection_empty_state.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/entity_card_surface.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/pull_to_refresh.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../domain/entities/case_timeline.dart';
import '../state/case_timeline_state.dart';
import '../view_models/case_timeline_view_model.dart';

class CaseTimelineScreen extends ConsumerWidget {
  const CaseTimelineScreen({required this.target, super.key});
  final TimelineTarget target;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = caseTimelineViewModelProvider(target),
        async = ref.watch(provider),
        m = ref.read(provider.notifier);
    final v = async.isLoading || async.hasError ? null : async.asData?.value;
    final error = async.error is TimelineFailure
        ? (async.error as TimelineFailure).issue
        : TimelineIssue.unavailable;
    return PullToRefresh(
      onRefresh: v == null ? null : m.refresh,
      enabled: v?.busy != true,
      child: CaseScreenShell(
        title: 'Historial',
        count: 2,
        loading: async.isLoading,
        notice: async.hasError
            ? timelineFailureLabel(error)
            : v?.failure != null
            ? timelineFailureLabel(v!.failure!)
            : null,
        noticeId: (async.error, v?.owner, v?.notice),
        child: async.isLoading
            ? const SkeletonFormFields(fieldCount: 3)
            : async.hasError
            ? TextButton(onPressed: m.retry, child: const Text('Reintentar'))
            : v == null
            ? const SizedBox.shrink()
            : ContentRefresh(
                refreshing: v.busy,
                label: 'Actualizando historial',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StaggerRevealItem(
                      order: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            v.page.caseStatus == 'active'
                                ? 'Búsqueda abierta'
                                : 'Caso cerrado',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ordenado por hora del suceso, del más reciente al más antiguo. Confirmar evidencia no garantiza la ubicación actual de la mascota.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    StaggerRevealItem(
                      order: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (v.page.items.isEmpty)
                            const CollectionEmptyState(
                              title: 'Sin eventos',
                              description:
                                  'Los eventos aparecerán aquí cuando se registren.',
                            ),
                          for (final event in v.page.items)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: EntityCardSurface(
                                child: InkWell(
                                  onTap: event.kind != 'sighting'
                                      ? null
                                      : () async {
                                          await context.push(
                                            '/home/timeline/${target.community ? 'found' : 'lost'}/${target.id}/sightings/${event.id}',
                                          );
                                          if (context.mounted) {
                                            await m.refresh();
                                          }
                                        },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          switch (event.kind) {
                                            'published' => 'Búsqueda publicada',
                                            'resolved' =>
                                              'Recuperación confirmada',
                                            _ => 'Avistamiento',
                                          },
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Suceso: ${caseDateTimeLabel(event.observedAt)}',
                                        ),
                                        if (event.kind == 'sighting') ...[
                                          Text(
                                            'Recibido: ${caseDateTimeLabel(event.receivedAt)}',
                                          ),
                                          if (event.late)
                                            const Text(
                                              'Reporte tardío · más de 24 horas',
                                            ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Revisión: ${timelineStateLabel(event.reviewState)}',
                                          ),
                                          Text(
                                            event.hasPhoto
                                                ? 'Foto adjunta'
                                                : 'Sin foto adjunta',
                                          ),
                                          if (event.comment.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Text(event.comment),
                                            ),
                                          const SizedBox(height: 12),
                                          const Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Ver evidencia y revisiones',
                                                ),
                                              ),
                                              Icon(Icons.chevron_right_rounded),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (v.failure != null)
                            TextButton(
                              onPressed: v.busy ? null : m.refresh,
                              child: const Text('Reintentar actualización'),
                            ),
                          if (v.page.next != null)
                            LoadingShimmer(
                              isLoading: v.busy,
                              loadingLabel: 'Consultando más eventos',
                              child: TextButton(
                                onPressed: v.busy ? null : m.more,
                                child: const Text('Ver más eventos'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
