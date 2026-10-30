import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/collection_add_button.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/entity_card_content.dart';
import '../../../../core/presentation/widgets/entity_card_surface.dart';
import '../view_models/recovery_case_view_model.dart';

class RecoveryCaseActions extends ConsumerWidget {
  const RecoveryCaseActions({
    required this.id,
    required this.community,
    required this.canResolve,
    required this.open,
    required this.onChanged,
    this.showSightingAction = true,
    super.key,
  });
  final String id;
  final bool community, canResolve, open;
  final VoidCallback onChanged;
  final bool showSightingAction;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = recoveryCaseViewModelProvider((id, community));
    final state = ref.watch(provider);
    final model = ref.read(provider.notifier);
    final value = state.asData?.value;
    return ConfirmationToastHost(
      confirmed:
          state.hasError || value?.error == true || value?.confirmed == true,
      message: value?.confirmed == true
          ? 'Recuperación confirmada'
          : 'No pudimos confirmar la operación. Reintenta.',
      isError: value?.confirmed != true,
      noticeId: state,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (open && showSightingAction)
            CollectionAddButton(
              label: 'Reportar avistamiento',
              accented: true,
              route: '/home/sightings/${community ? 'found' : 'lost'}/$id',
              icon: Icons.visibility_outlined,
            ),
          if (open && showSightingAction) const SizedBox(height: 12),
          if (open)
            CollectionAddButton(
              label: 'La vi o la encontré',
              route: '/home/found-cases/new?case=$id&community=$community',
              icon: Icons.visibility_outlined,
            ),
          if (open && canResolve) ...[
            const SizedBox(height: 12),
            CollectionAddButton(
              label: 'Ya fue recuperada',
              icon: Icons.check_circle_outline,
              route: '/home/closure/${community ? 'found' : 'lost'}/$id',
              onReturn: onChanged,
            ),
          ],
          if (!open)
            CollectionAddButton(
              label: 'Ver recuperación',
              icon: Icons.check_circle_outline,
              route: '/home/closure/${community ? 'found' : 'lost'}/$id',
            ),
          const SizedBox(height: 20),
          const Text(
            'Avisos de esta búsqueda',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          if (state.isLoading)
            const SkeletonFormFields(fieldCount: 1)
          else if (state.hasError || value?.error == true)
            TextButton(onPressed: model.retry, child: const Text('Reintentar'))
          else if (value!.notices.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Aún no hay avisos confirmados.'),
            )
          else
            for (final notice in value.notices)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: EntityCardSurface(
                  child: InkWell(
                    onTap: () => context.push('/home/found-cases/${notice.id}'),
                    child: EntityCardContent(
                      title: notice.reportKind == 'with_reporter'
                          ? 'Está con quien la encontró'
                          : 'Avistamiento',
                      subtitle: notice.traits,
                      imageUri: notice.photos
                          .where((p) => p.uri != null)
                          .firstOrNull
                          ?.uri,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
