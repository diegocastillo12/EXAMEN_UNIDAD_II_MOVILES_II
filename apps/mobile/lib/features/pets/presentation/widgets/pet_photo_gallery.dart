import '../../../../core/presentation/widgets/photo_add_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/photo_gallery_strip.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/shake_field.dart';
import '../../domain/entities/pet_photo.dart';
import '../view_models/pet_photos_view_model.dart';

class PetPhotoGallery extends ConsumerStatefulWidget {
  const PetPhotoGallery({
    required this.petId,
    required this.existing,
    this.editable = false,
    this.locked = false,
    this.tileSize = 112,
    super.key,
  });
  final String petId;
  final bool existing;
  final bool editable;
  final bool locked;
  final double tileSize;
  @override
  ConsumerState<PetPhotoGallery> createState() => _PetPhotoGalleryState();
}

class _PetPhotoGalleryState extends ConsumerState<PetPhotoGallery> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(petPhotosViewModelProvider(widget.petId).notifier)
            .ensureInitialized(widget.existing);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(petPhotosViewModelProvider(widget.petId));
    final model = ref.read(petPhotosViewModelProvider(widget.petId).notifier);
    final disabled = widget.locked || state.busy || state.loading;
    if (!widget.editable &&
        !state.loading &&
        state.photos.isEmpty &&
        state.issue == null) {
      return const SizedBox.shrink();
    }
    final invalid = widget.editable && state.issue != null;
    // A save error must not turn into a read error as pending changes disappear.
    final failedRead = state.failedOperation == PetPhotosOperation.load;
    return ConfirmationToastHost(
      confirmed: state.issue != null,
      isError: true,
      noticeId: state.errorId,
      message: switch (state.issue) {
        PetPhotoFailureKind.invalidPhoto => 'Elige una imagen válida.',
        PetPhotoFailureKind.galleryUnavailable =>
          'No se pudo abrir la galería. Inténtalo de nuevo.',
        PetPhotoFailureKind.cameraUnavailable =>
          'No se pudo abrir la cámara. Puedes usar la galería.',
        PetPhotoFailureKind.conflict =>
          'Las fotos cambiaron. Vuelve a consultarlas e intenta guardar.',
        PetPhotoFailureKind.limit => 'Puedes añadir hasta tres fotos.',
        _ =>
          failedRead
              ? 'No se pudieron consultar las fotos.'
              : 'No se pudieron guardar las fotos. Reintenta al guardar.',
      },
      actionLabel: invalid && state.issue == PetPhotoFailureKind.conflict
          ? 'Consultar fotos'
          : state.issue != null &&
                failedRead &&
                state.issue == PetPhotoFailureKind.unavailable
          ? 'Reintentar'
          : null,
      onAction:
          invalid && state.issue == PetPhotoFailureKind.conflict && !disabled
          ? () => model.refreshAfterConflict(widget.existing)
          : state.issue != null &&
                failedRead &&
                state.issue == PetPhotoFailureKind.unavailable &&
                !disabled
          ? () => model.initialize(widget.existing)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.editable) ...[
            const Text(
              'Fotos',
              style: TextStyle(fontSize: 16, color: Color(0xFF111111)),
            ),
            const SizedBox(height: 8),
          ],
          ShakeField(
            errorId: state.errorId,
            hasError: invalid,
            child: LoadingShimmer(
              isLoading: state.busy || state.loading,
              loadingLabel: state.loading
                  ? 'Consultando fotos'
                  : 'Preparando fotos',
              radius: 22,
              child: PhotoGalleryStrip(
                children: [
                  if (state.loading)
                    for (var i = 0; i < 2; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          width: widget.tileSize,
                          height: widget.tileSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E5EA),
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                  for (final photo
                      in widget.editable ? state.visiblePhotos : state.photos)
                    _tile(
                      id: photo.id,
                      invalid: invalid,
                      child: photo.uri == null
                          ? const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Color(0xFF6E6E73),
                              ),
                            )
                          : Image.network(
                              photo.uri.toString(),
                              width: widget.tileSize,
                              height: widget.tileSize,
                              fit: BoxFit.cover,
                              cacheWidth:
                                  (widget.tileSize *
                                          MediaQuery.devicePixelRatioOf(
                                            context,
                                          ))
                                      .ceil(),
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: Color(0xFF6E6E73),
                                ),
                              ),
                            ),
                      remove: widget.editable && !disabled
                          ? () => model.stageRemoval(photo.id)
                          : null,
                      pending: !photo.ready,
                      primary: widget.editable
                          ? state.visiblePrimaryId == photo.id
                          : photo.isPrimary,
                      selectPrimary: widget.editable && !disabled && photo.ready
                          ? () => model.stagePrimary(photo.id)
                          : null,
                    ),
                  for (final draft
                      in widget.editable ? state.pending : <PetPhotoDraft>[])
                    _tile(
                      id: draft.id,
                      invalid: invalid,
                      child: Image.memory(
                        draft.bytes,
                        width: widget.tileSize,
                        height: widget.tileSize,
                        fit: BoxFit.cover,
                        cacheWidth:
                            (widget.tileSize *
                                    MediaQuery.devicePixelRatioOf(context))
                                .ceil(),
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                      remove: widget.editable && !disabled
                          ? () => model.stageRemoval(draft.id)
                          : null,
                      primary: state.visiblePrimaryId == draft.id,
                      selectPrimary: !disabled
                          ? () => model.stagePrimary(draft.id)
                          : null,
                    ),
                  if (widget.editable &&
                      state.visiblePhotos.length + state.pending.length < 3)
                    PhotoAddTile(
                      size: widget.tileSize,
                      invalid: invalid,
                      semanticLabel: 'Añadir foto de mascota',
                      onTap: disabled
                          ? null
                          : () => model.choose(widget.existing),
                    ),
                ],
              ),
            ),
          ),
          if (widget.editable &&
              state.visiblePhotos.length + state.pending.length < 3)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: disabled
                    ? null
                    : () => model.choose(
                        widget.existing,
                        origin: PetPhotoOrigin.camera,
                      ),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Tomar foto'),
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              ),
            ),
          if (widget.editable && state.recovered)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Foto recuperada. Guarda para añadirla.',
                style: TextStyle(fontSize: 14, color: Color(0xFF6E6E73)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tile({
    required String id,
    required Widget child,
    VoidCallback? remove,
    bool pending = false,
    bool invalid = false,
    bool primary = false,
    VoidCallback? selectPrimary,
  }) => PhotoGalleryTile(
    key: ValueKey('pet_photo_$id'),
    id: id,
    size: widget.tileSize,
    remove: remove,
    pending: pending,
    invalid: invalid,
    primary: primary,
    selectPrimary: selectPrimary,
    child: child,
  );
}
