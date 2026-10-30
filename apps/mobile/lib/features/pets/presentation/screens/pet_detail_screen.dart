import '../../../../core/theme/app_typography.dart';
import '../../domain/failures/pet_failure.dart';
import '../../../../core/presentation/widgets/photo_gallery_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../domain/entities/pet.dart';
import '../view_models/pet_list_view_model.dart';
import '../view_models/pet_photos_view_model.dart';
import '../widgets/pet_screen_shell.dart';
import '../widgets/pet_load_feedback.dart';
import '../widgets/pet_labels.dart';
import '../widgets/pet_skeleton.dart';
import '../widgets/pet_photo_gallery.dart';
import '../widgets/pet_lifecycle_actions.dart';
import '../view_models/pet_lifecycle_view_model.dart';

class PetDetailScreen extends ConsumerStatefulWidget {
  const PetDetailScreen({
    required this.petId,
    this.savedPet,
    this.canEdit = true,
    super.key,
  });
  final String petId;
  final Pet? savedPet;
  final bool canEdit;
  @override
  ConsumerState<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends ConsumerState<PetDetailScreen> {
  bool _confirmed = false;
  String? _confirmationOwner;
  @override
  void initState() {
    super.initState();
    _confirmationOwner = widget.savedPet?.ownerId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.savedPet != null) setState(() => _confirmed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lifecycle = ref.watch(petLifecycleViewModelProvider(widget.petId));
    final value = ref.watch(petDetailViewModelProvider(widget.petId));
    final showData =
        value.hasValue &&
        !value.hasError &&
        (!value.isLoading || value.isRefreshing);
    return PopScope(
      canPop: !lifecycle.busy,
      child: ConfirmationToastHost(
        confirmed:
            lifecycle.issue != null ||
            lifecycle.confirmed ||
            (_confirmed && value.asData?.value.ownerId == _confirmationOwner),
        noticeId: lifecycle.noticeId,
        isError: lifecycle.issue != null,
        message: lifecycle.issue != null
            ? petLifecycleFailureLabel(lifecycle.issue!)
            : lifecycle.confirmed
            ? (lifecycle.archived ? 'Mascota archivada' : 'Mascota restaurada')
            : 'Mascota guardada',
        child: PetScreenShell(
          navigationEnabled: !lifecycle.busy,
          loading: value.isLoading && !showData,
          count: widget.canEdit ? 4 : 2,
          child: PetRefreshProgress(
            refreshing: showData && value.isLoading,
            child: value.isLoading && !showData
                ? const PetSkeleton(layout: PetSkeletonLayout.detail)
                : value.hasError
                ? PetLoadFeedback(
                    error: value.error,
                    onRetry: () => ref
                        .read(petDetailViewModelProvider(widget.petId).notifier)
                        .reload(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StaggerRevealItem(
                        order: 0,
                        child: _PetIdentity(pet: value.requireValue),
                      ),
                      const SizedBox(height: 24),
                      StaggerRevealItem(
                        order: 1,
                        child: _PetInformation(pet: value.requireValue),
                      ),
                      if (widget.canEdit) ...[
                        const SizedBox(height: 24),
                        StaggerRevealItem(
                          order: 2,
                          child: FilledButton(
                            style: primaryActionButtonStyle(context),
                            onPressed: lifecycle.busy
                                ? null
                                : () async {
                                    setState(() => _confirmed = false);
                                    ref
                                        .read(
                                          petLifecycleViewModelProvider(
                                            widget.petId,
                                          ).notifier,
                                        )
                                        .clearFeedback();
                                    final saved = await context.push<Pet>(
                                      '/home/pets/${widget.petId}/edit',
                                    );
                                    if (mounted && saved != null) {
                                      setState(() {
                                        _confirmationOwner = saved.ownerId;
                                        _confirmed = true;
                                      });
                                    }
                                  },
                            child: const Text('Editar mascota'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        StaggerRevealItem(
                          order: 3,
                          child: PetLifecycleActions(pet: value.requireValue),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _PetIdentity extends ConsumerWidget {
  const _PetIdentity({required this.pet});
  final Pet pet;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(petPhotosViewModelProvider(pet.id));
    final hasPhotos = photos.photos.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final size = PhotoGalleryStrip.detailTileSize(constraints.maxWidth);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PetPhotoGallery(petId: pet.id, existing: true, tileSize: size),
                if (!hasPhotos && photos.issue == null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ExcludeSemantics(
                      child: Icon(
                        Icons.pets_outlined,
                        size: size,
                        color: const Color(0xFF6E6E73),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(pet.fields.name, style: AppTypography.primaryTitle),
        ),
      ],
    );
  }
}

class _PetInformation extends StatelessWidget {
  const _PetInformation({required this.pet});
  final Pet pet;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F7),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in [
          (
            'Especie',
            pet.fields.speciesDetail ?? speciesLabel(pet.fields.species),
          ),
          ('Tamaño', sizeLabel(pet.fields.size)),
          ('Sexo', sexLabel(pet.fields.sex)),
          ('Edad aproximada', ageLabel(pet.fields.ageMonths)),
          ('Rasgos', pet.fields.traits ?? 'Sin especificar'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.$1,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6E6E73),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.$2,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

String petLifecycleFailureLabel(PetFailureKind kind) => switch (kind) {
  PetFailureKind.activeCase =>
    'Resuelve o cancela el caso activo antes de archivar.',
  PetFailureKind.conflict => 'La ficha cambió. Actualízala antes de continuar.',
  PetFailureKind.missing => 'Esta mascota ya no está disponible.',
  _ => 'No se pudo completar la acción. Puedes reintentar.',
};
