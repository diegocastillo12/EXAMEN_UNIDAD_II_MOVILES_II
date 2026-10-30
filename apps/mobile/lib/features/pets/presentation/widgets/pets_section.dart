import '../../../../core/presentation/widgets/collection_header.dart';
import '../../../../core/presentation/widgets/collection_empty_state.dart';
import '../../../../core/presentation/widgets/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import 'pet_registration_button.dart';
import 'pet_list_filter.dart';
import '../view_models/pet_list_view_model.dart';
import 'pet_load_feedback.dart';
import 'pet_card_content.dart';
import 'pet_skeleton.dart';
import '../../domain/failures/pet_failure.dart';
import 'swipe_pet_card.dart';
import 'pet_deletion_dialog.dart';
import '../view_models/pet_deletion_view_model.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';

class PetsSection extends ConsumerStatefulWidget {
  const PetsSection({super.key});
  @override
  ConsumerState<PetsSection> createState() => _PetsSectionState();
}

class _PetsSectionState extends ConsumerState<PetsSection> {
  bool _sawSkeleton = false;
  bool _archived = false;
  @override
  Widget build(BuildContext context) {
    final listProvider = _archived
        ? archivedPetListViewModelProvider
        : petListViewModelProvider;
    final pets = ref.watch(listProvider);
    final deletion = ref.watch(petDeletionViewModelProvider);
    final showData =
        pets.hasValue &&
        !pets.hasError &&
        (!pets.isLoading || pets.isRefreshing);
    final loading = pets.isLoading && !showData;
    _sawSkeleton |= loading;
    return PullToRefreshTarget(
      enabled: !pets.isLoading && deletion.busyId == null,
      onRefresh: () async {
        ref.read(listProvider.notifier).reload();
        await ref.read(listProvider.future);
      },
      child: ConfirmationToastHost(
        confirmed: deletion.confirmed || deletion.issue != null,
        noticeId: deletion.noticeId,
        isError: deletion.issue != null,
        message: deletion.issue == null
            ? 'Mascota eliminada'
            : deletion.issue == PetFailureKind.conflict
            ? 'La ficha cambió. Actualiza la lista antes de eliminarla.'
            : deletion.issue == PetFailureKind.activeCase
            ? 'Resuelve o cancela el caso activo antes de eliminar.'
            : deletion.issue == PetFailureKind.caseHistory
            ? 'Esta mascota tiene historial de casos. Puedes archivarla desde su ficha.'
            : 'No se pudo eliminar la mascota. Desliza para reintentar.',
        actionLabel: deletion.issue == PetFailureKind.conflict
            ? 'Actualizar lista'
            : null,
        onAction: deletion.issue == PetFailureKind.conflict
            ? () => ref.read(listProvider.notifier).reload()
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StaggerRevealItem(
              order: 0,
              child: _PetsHeader(
                hasPets:
                    _archived || (showData && pets.requireValue.isNotEmpty),
              ),
            ),
            const SizedBox(height: 12),
            PetListFilter(
              archived: _archived,
              onChanged: deletion.busyId != null
                  ? null
                  : (archived) {
                      if (_archived == archived) return;
                      setState(() {
                        _archived = archived;
                        _sawSkeleton = false;
                      });
                    },
            ),
            const SizedBox(height: 24),
            StaggerRevealItem(
              order: 1,
              enabled: !_sawSkeleton,
              child: PetRefreshProgress(
                refreshing: showData && pets.isLoading,
                child: pets.isLoading && !showData
                    ? const PetSkeleton()
                    : pets.hasError
                    ? PetLoadFeedback(
                        error: pets.error,
                        onRetry: () => ref.read(listProvider.notifier).reload(),
                      )
                    : pets.requireValue.isEmpty
                    ? _PetsEmptyState(archived: _archived)
                    : Column(
                        children: [
                          for (final pet in pets.requireValue)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Builder(
                                    builder: (cardContext) => SwipePetCard(
                                      key: ValueKey(pet.id),
                                      busy: deletion.busyId == pet.id,
                                      disabled: deletion.busyId != null,
                                      onOpen: () {
                                        final box = cardContext
                                            .findRenderObject();
                                        final navigator = Navigator.of(
                                          cardContext,
                                        ).context.findRenderObject();
                                        final origin =
                                            box is RenderBox && box.hasSize
                                            ? box.localToGlobal(
                                                    Offset.zero,
                                                    ancestor: navigator,
                                                  ) &
                                                  box.size
                                            : null;
                                        cardContext.push(
                                          '/home/pets/${pet.id}',
                                          extra: origin,
                                        );
                                      },
                                      onDelete: (origin) async {
                                        if (await confirmPetDeletion(
                                              context,
                                              pet.fields.name,
                                              origin: origin,
                                              source: PetCardContent(pet: pet),
                                            ) &&
                                            context.mounted) {
                                          await ref
                                              .read(
                                                petDeletionViewModelProvider
                                                    .notifier,
                                              )
                                              .delete(pet);
                                        }
                                      },
                                      contentBuilder: (foreground, secondary) =>
                                          PetCardContent(
                                            pet: pet,
                                            foreground: foreground,
                                            secondary: secondary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetsHeader extends StatelessWidget {
  const _PetsHeader({required this.hasPets});
  final bool hasPets;
  @override
  Widget build(BuildContext context) => CollectionHeader(
    title: 'Mis mascotas',
    // Keep the header geometry while loading or showing the empty state.
    action: hasPets
        ? const PetRegistrationButton(compact: true)
        : const SizedBox.square(dimension: 56),
  );
}

class _PetsEmptyState extends StatelessWidget {
  const _PetsEmptyState({this.archived = false});
  final bool archived;

  @override
  Widget build(BuildContext context) => CollectionEmptyState(
    title: archived
        ? 'No tienes mascotas archivadas'
        : 'Aún no tienes mascotas',
    description: archived
        ? 'Las mascotas que archives aparecerán aquí. Podrás consultar su ficha y restaurarlas.'
        : 'Registra a tu mascota para tener su información a mano.',
    action: archived ? null : const PetRegistrationButton(),
  );
}
