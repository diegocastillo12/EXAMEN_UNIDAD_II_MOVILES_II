import '../../../../core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../domain/failures/profile_failure.dart';
import '../view_models/profile_photo_view_model.dart';
import '../view_models/profile_view_model.dart';
import 'profile_avatar.dart';

class ProfilePhotoEditor extends ConsumerStatefulWidget {
  const ProfilePhotoEditor({super.key});
  @override
  ConsumerState<ProfilePhotoEditor> createState() => _ProfilePhotoEditorState();
}

class _ProfilePhotoEditorState extends ConsumerState<ProfilePhotoEditor> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(profilePhotoViewModelProvider.notifier).recover();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileViewModelProvider, (previous, next) {
      if (!next.isLoading &&
          next.hasValue &&
          (previous == null || previous.isLoading || previous.hasError)) {
        ref.read(profilePhotoViewModelProvider.notifier).recover();
      }
    });
    final photo = ref.watch(profilePhotoViewModelProvider);
    final profile = ref.watch(profileViewModelProvider);
    final busy = photo.result.isLoading;
    final model = ref.read(profilePhotoViewModelProvider.notifier);
    final available =
        !profile.isLoading &&
        !profile.hasError &&
        !(profile.asData?.value.isBusy ?? true);
    final failed = photo.result.hasError;
    final retry = failed && photo.bytes != null;
    final invalid =
        photo.result.error is ProfileFailure &&
        (photo.result.error as ProfileFailure).kind ==
            ProfileFailureKind.invalidPhoto;
    return ConfirmationToastHost(
      key: ValueKey(profile.asData?.value.profile.userId),
      confirmed: failed || photo.result.asData?.value != null,
      isError: failed,
      message: failed
          ? (invalid
                ? 'Elige una imagen válida.'
                : 'No se pudo confirmar la foto. Tócala para reintentar.')
          : 'Foto actualizada',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LoadingShimmer(
                isLoading: busy,
                loadingLabel: 'Actualizando foto',
                radius: 36,
                child: Semantics(
                  label: photo.recovered
                      ? 'Foto recuperada pendiente de guardar'
                      : (retry
                            ? 'Reintentar foto de perfil'
                            : 'Cambiar foto de perfil'),
                  button: !photo.recovered,
                  enabled: available && !busy && !photo.recovered,
                  child: GestureDetector(
                    onTap: available && !busy && !photo.recovered
                        ? (retry ? model.retry : model.choose)
                        : null,
                    child: photo.recovered && photo.bytes != null
                        ? ClipOval(
                            child: Image.memory(
                              photo.bytes!,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Stack(
                            children: [
                              ProfileAvatar(size: 72),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF111111),
                                    shape: BoxShape.circle,
                                  ),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Icon(
                                      Icons.photo_camera_outlined,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text('Perfil', style: AppTypography.primaryTitle),
              ),
            ],
          ),
          // Android activity recovery is exceptional and requires explicit confirmation.
          if (photo.recovered) ...[
            const SizedBox(height: 12),
            LoadingShimmer(
              isLoading: busy,
              loadingLabel: 'Guardando foto recuperada',
              radius: 16,
              child: TextButton(
                onPressed: busy || !available ? null : model.retry,
                child: const Text('Guardar foto recuperada'),
              ),
            ),
            TextButton(
              onPressed: busy ? null : model.discard,
              child: const Text('Descartar foto recuperada'),
            ),
          ],
        ],
      ),
    );
  }
}
