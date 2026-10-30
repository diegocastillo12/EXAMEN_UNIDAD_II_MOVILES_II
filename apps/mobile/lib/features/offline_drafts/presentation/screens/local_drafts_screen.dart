import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/entity_screen_shell.dart';
import '../../../../core/presentation/widgets/entity_card_surface.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../domain/entities/local_report_draft.dart';
import '../view_models/local_drafts_view_model.dart';

class LocalDraftsScreen extends ConsumerStatefulWidget {
  const LocalDraftsScreen({required this.onOpen, super.key});
  final Future<void> Function(LocalReportDraft) onOpen;
  @override
  ConsumerState<LocalDraftsScreen> createState() => _LocalDraftsScreenState();
}

class _LocalDraftsScreenState extends ConsumerState<LocalDraftsScreen> {
  bool _opening = false;
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(localDraftsViewModelProvider);
    final items = async.isLoading || async.hasError
        ? null
        : async.asData?.value;
    final model = ref.read(localDraftsViewModelProvider.notifier);
    return ConfirmationToastHost(
      confirmed: async.hasError,
      isError: true,
      noticeId: async.error,
      message:
          'No pudimos leer los borradores de este dispositivo. Puedes reintentar.',
      child: EntityScreenShell(
        title: 'Borradores',
        loading: async.isLoading,
        count: 1,
        child: StaggerRevealItem(
          order: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Sin publicar · Solo en este dispositivo'),
              TextButton(
                onPressed: () => context.push('/home/submissions'),
                child: const Text('Ver envíos'),
              ),
              const SizedBox(height: 16),
              if (async.isLoading)
                const SkeletonFormFields(fieldCount: 3)
              else if (async.hasError)
                TextButton(
                  onPressed: model.reload,
                  child: const Text('Reintentar'),
                )
              else if (items != null) ...[
                if (items.isEmpty)
                  const Text('No tienes borradores guardados.'),
                for (final d in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: EntityCardSurface(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              d.slot == 'lost'
                                  ? 'Mascota perdida: ${d.pet?.fields.name ?? 'Mi mascota'}'
                                  : d.slot == 'community-search'
                                  ? 'Búsqueda de mascota'
                                  : d.slot.startsWith('sighting:')
                                  ? 'Avistamiento'
                                  : 'Aviso de mascota encontrada',
                            ),
                            if (d.target != null) Text(d.target!.name),
                            if (d.frozen)
                              const Text(
                                'Resultado del envío pendiente de confirmar',
                              ),
                            TextButton(
                              onPressed: _opening
                                  ? null
                                  : () async {
                                      setState(() => _opening = true);
                                      try {
                                        await widget.onOpen(d);
                                      } finally {
                                        if (mounted) {
                                          setState(() => _opening = false);
                                          model.reload();
                                        }
                                      }
                                    },
                              child: const Text('Retomar borrador'),
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
