import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/entity_screen_shell.dart';
import '../../../../core/presentation/widgets/entity_card_surface.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/report_draft_status.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../domain/entities/queued_report.dart';
import '../state/submission_queue_state.dart';
import '../view_models/submission_queue_view_model.dart';

class SubmissionQueueScreen extends ConsumerWidget {
  const SubmissionQueueScreen({required this.onOpen, super.key});
  final void Function(QueuedReport) onOpen;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(submissionQueueViewModelProvider);
    final v = async.isLoading || async.hasError ? null : async.asData?.value;
    final m = ref.read(submissionQueueViewModelProvider.notifier);
    return ConfirmationToastHost(
      confirmed: async.hasError || v?.issue != null,
      isError: true,
      message: async.hasError
          ? 'No pudimos leer la cola de este dispositivo. Puedes reintentar.'
          : submissionIssueLabel(v?.issue),
      noticeId: (async.error, v?.owner, v?.noticeId),
      child: EntityScreenShell(
        title: 'Envíos',
        loading: async.isLoading,
        count: 1,
        child: StaggerRevealItem(
          order: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Solo una confirmación del servidor indica que está publicado.',
              ),
              const SizedBox(height: 16),
              if (async.isLoading)
                const SkeletonFormFields(fieldCount: 3)
              else if (async.hasError)
                TextButton(onPressed: m.reload, child: const Text('Reintentar'))
              else if (v != null) ...[
                if (v.entries.isEmpty)
                  const Text('No tienes envíos en este dispositivo.'),
                for (final entry in v.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: EntityCardSurface(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              entry.command.slot == 'lost'
                                  ? 'Mascota perdida'
                                  : entry.command.slot.startsWith('sighting:')
                                  ? 'Avistamiento'
                                  : 'Búsqueda o aviso',
                            ),
                            Text(
                              reportSubmissionStatusLabel(entry.status.name),
                            ),
                            Text('Intentos: ${entry.attempts}'),
                            if (entry.issue != null)
                              TextButton(
                                onPressed: () => m.showIssue(entry.issue),
                                child: const Text('Ver motivo'),
                              ),
                            if (entry.status != SubmissionStatus.published)
                              LoadingShimmer(
                                isLoading:
                                    v.busyId == entry.command.id ||
                                    entry.status == SubmissionStatus.sending,
                                loadingLabel: 'Reintentando envío',
                                child: TextButton(
                                  onPressed:
                                      v.busyId != null ||
                                          entry.status ==
                                              SubmissionStatus.sending
                                      ? null
                                      : () => m.retry(entry.command.id),
                                  child: const Text(
                                    'Reintentar envío original',
                                  ),
                                ),
                              ),
                            TextButton(
                              onPressed: v.busyId != null
                                  ? null
                                  : () => onOpen(entry),
                              child: Text(
                                entry.status == SubmissionStatus.published
                                    ? 'Ver resultado'
                                    : 'Revisar reporte',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
