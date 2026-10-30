import '../../../../core/presentation/widgets/report_draft_status.dart';
import '../../../../core/presentation/widgets/case_report_fields.dart';
import '../../../../core/presentation/widgets/collection_add_button.dart';
import '../../../../core/presentation/widgets/validation_surface.dart';
import '../../../../core/presentation/widgets/photo_gallery_strip.dart';
import '../../../../core/presentation/widgets/case_photo_failure.dart';
import '../../../../core/presentation/widgets/shake_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/app_select_field.dart';
import '../../../../core/presentation/widgets/confirm_discard_action.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../domain/entities/lost_case.dart';
import '../../../pets/domain/entities/pet.dart';
import '../state/case_editor_state.dart';
import '../view_models/case_editor_view_model.dart';
import '../widgets/case_public_content.dart';
import '../widgets/case_screen_shell.dart';

class CaseEditorScreen extends ConsumerStatefulWidget {
  const CaseEditorScreen({
    this.embedded = false,
    this.petDetailsOnly = false,
    this.locationSearchBuilder,
    super.key,
  });
  final bool embedded;

  /// App composes the common report fields for embedded creation.
  final bool petDetailsOnly;
  final ReportLocationSearchBuilder? locationSearchBuilder;
  @override
  ConsumerState<CaseEditorScreen> createState() => _CaseEditorScreenState();
}

class _CaseEditorScreenState extends ConsumerState<CaseEditorScreen> {
  final _place = TextEditingController();
  bool _leaving = false, _canPop = false;
  @override
  void dispose() {
    _place.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    final value = ref.read(caseEditorViewModelProvider).asData?.value;
    if (_leaving || value?.busy == true) return;
    _leaving = true;
    final leave =
        value?.dirty != true ||
        await confirmDiscardAction(
          context,
          '¿Salir del reporte?',
          value?.lockedDraft != null
              ? 'El envío pudo haber llegado al servidor. Consulta Mis casos antes de publicar otra vez.'
              : 'Conservaremos el borrador en este dispositivo para que puedas retomarlo.',
          'Salir',
        );
    _leaving = false;
    if (!mounted || !leave) return;
    if (!await ref.read(caseEditorViewModelProvider.notifier).saveForLater()) {
      return;
    }
    if (!mounted) return;
    setState(() => _canPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(caseEditorViewModelProvider, (previous, next) {
      if (next.isLoading ||
          next.hasError ||
          previous?.asData?.value.ownerId != next.asData?.value.ownerId) {
        _place.clear();
      }
    });
    final async = ref.watch(caseEditorViewModelProvider),
        value = async.isLoading || async.hasError ? null : async.asData?.value;
    final model = ref.read(caseEditorViewModelProvider.notifier);
    if (value != null && _place.text != value.placeReference) {
      _place.text = value.placeReference;
    }
    if (widget.embedded) {
      return async.isLoading
          ? const SkeletonFormFields(fieldCount: 1)
          : async.hasError
          ? TextButton(onPressed: model.retry, child: const Text('Reintentar'))
          : value == null
          ? const SizedBox.shrink()
          : _content(value, model);
    }
    return PopScope(
      canPop: _canPop || (value?.dirty != true && value?.busy != true),
      onPopInvokedWithResult: (popped, result) {
        if (!popped) _leave();
      },
      child: CaseScreenShell(
        title: 'Mascota perdida',
        count: value?.stage == CaseEditorStage.form ? 8 : 2,
        loading: async.isLoading,
        immersive: value?.stage == CaseEditorStage.preview,
        notice: async.hasError
            ? 'No pudimos preparar el reporte. Revisa tu sesión y conexión.'
            : value?.issue != null
            ? caseFailureLabel(value!.issue)
            : value?.stage == CaseEditorStage.confirmed
            ? 'Caso publicado'
            : null,
        noticeIsError: value?.stage != CaseEditorStage.confirmed,
        noticeId: (async.error, value?.ownerId, value?.errorId, value?.stage),
        stage: value?.stage ?? 'initial',
        onBack: _leave,
        child: async.isLoading
            ? const SkeletonFormFields(fieldCount: 4)
            : async.hasError
            ? Column(
                children: [
                  TextButton(
                    onPressed: model.retry,
                    child: const Text('Reintentar'),
                  ),
                ],
              )
            : value == null
            ? const SizedBox.shrink()
            : _content(value, model),
      ),
    );
  }

  Widget _shake(CaseEditorState value, CaseField field, Widget child) =>
      ShakeField(
        errorId: value.errorId,
        hasError: value.invalidFields.contains(field),
        child: child,
      );
  Widget _content(CaseEditorState value, CaseEditorViewModel model) =>
      value.stage != CaseEditorStage.form
      ? _editorContent(value, model)
      : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!(value.stage == CaseEditorStage.confirmed) &&
                !widget.petDetailsOnly)
              ReportDraftStatus(
                submissionState: value.submissionStatus?.name,
                onRetry:
                    value.issue == CaseFailureKind.localStorage && !value.busy
                    ? model.saveForLater
                    : null,
                onDiscard: value.busy || value.lockedDraft != null
                    ? null
                    : () => model.discardLocalDraft(value.draftId),
              ),
            _editorContent(value, model),
          ],
        );
  Widget _editorContent(CaseEditorState value, CaseEditorViewModel model) {
    if (value.stage == CaseEditorStage.confirmed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          StaggerRevealItem(
            order: 0,
            child: FilledButton(
              style: primaryActionButtonStyle(context),
              onPressed: () =>
                  context.pushReplacement('/home/cases/${value.published!.id}'),
              child: const Text('Ver ficha pública'),
            ),
          ),
        ],
      );
    }
    if (value.stage == CaseEditorStage.preview) {
      final preview = value.preview;
      return CasePreviewContent(
        value: preview,
        actions: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (value.submissionStatus != null)
              Text(reportSubmissionStatusLabel(value.submissionStatus?.name)),
            TextButton(
              onPressed: value.busy
                  ? null
                  : () => context.push('/home/submissions'),
              child: const Text('Ver envíos'),
            ),
            if (value.lockedDraft != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: value.busy
                    ? null
                    : () => context.push('/home/my-cases'),
                child: const Text('Consultar Mis casos'),
              ),
            ],
            const SizedBox(height: 24),
            ValidationSurface(
              invalid: value.issue != null && value.invalidFields.isEmpty,
              errorId: value.errorId,
              child: LoadingShimmer(
                isLoading: value.busy,
                loadingLabel: 'Publicando caso',
                child: FilledButton(
                  style: primaryActionButtonStyle(
                    context,
                    isLoading: value.busy,
                  ),
                  onPressed: value.busy ? null : model.publish,
                  child: const Text('Publicar caso'),
                ),
              ),
            ),
            TextButton(
              onPressed: value.busy || value.lockedDraft != null
                  ? null
                  : model.backToForm,
              child: const Text('Editar reporte'),
            ),
          ],
        ),
      );
    }
    if (value.pets.isEmpty && !widget.petDetailsOnly) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Primero registra una mascota y guarda sus fotos para publicar su búsqueda.',
          ),
          const SizedBox(height: 24),
          const CollectionAddButton(
            label: 'Registrar mascota',
            route: '/home/pets/new',
          ),
          TextButton(
            onPressed: model.retry,
            child: const Text('Consultar mis mascotas'),
          ),
        ],
      );
    }
    final editable = !value.busy && !value.loadingPhotos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.petDetailsOnly)
          StaggerRevealItem(
            order: 0,
            child: _shake(
              value,
              CaseField.pet,
              AppSelectField<String>(
                label: 'Mascota',
                invalid: value.invalidFields.contains(CaseField.pet),
                value: value.pet?.id,
                options: value.pets
                    .map(
                      (p) => AppSelectOption(
                        value: p.id,
                        label: p.fields.name,
                        icon: Icons.pets_outlined,
                      ),
                    )
                    .toList(),
                onChanged: editable ? model.selectPet : null,
              ),
            ),
          ),
        const SizedBox(height: 20),
        if (widget.petDetailsOnly && value.pet != null) ...[
          Text(
            value.pet!.fields.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            [
              switch (value.pet!.fields.species) {
                PetSpecies.dog => 'Perro',
                PetSpecies.cat => 'Gato',
                PetSpecies.other =>
                  value.pet!.fields.speciesDetail ?? 'Otra especie',
                null => 'Especie sin completar',
              },
              if (value.pet!.fields.size != null)
                switch (value.pet!.fields.size!) {
                  PetSize.small => 'Pequeño',
                  PetSize.medium => 'Mediano',
                  PetSize.large => 'Grande',
                },
              if (value.pet!.fields.ageMonths != null)
                '${value.pet!.fields.ageMonths} meses',
              if (value.pet!.fields.sex != null)
                value.pet!.fields.sex == PetSex.male ? 'Macho' : 'Hembra',
            ].join(' · '),
          ),
          if (value.pet!.fields.traits?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(value.pet!.fields.traits!),
          ],
          const SizedBox(height: 20),
        ],
        if (value.pet != null)
          StaggerRevealItem(
            order: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (value.loadingPhotos)
                  const SkeletonFormFields(fieldCount: 1)
                else ...[
                  const Text(
                    'Fotos que se mostrarán públicamente',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final size = PhotoGalleryStrip.detailTileSize(
                        constraints.maxWidth,
                      );
                      return _shake(
                        value,
                        CaseField.photos,
                        PhotoGalleryStrip(
                          key: ValueKey(value.pet!.id),
                          children: [
                            for (final photo in value.photos)
                              PhotoGalleryTile(
                                id: photo.id,
                                size: size,
                                invalid: value.invalidFields.contains(
                                  CaseField.photos,
                                ),
                                primary: photo.isPrimary,
                                selected: value.selectedPhotos.contains(
                                  photo.id,
                                ),
                                onSelectionChanged: editable
                                    ? (_) => model.togglePhoto(photo.id)
                                    : null,
                                selectionLabel: photo.isPrimary
                                    ? 'Foto principal'
                                    : 'Foto ${value.photos.indexOf(photo) + 1}',
                                child: photo.uri == null
                                    ? const CasePhotoFailure()
                                    : Image.network(
                                        photo.uri.toString(),
                                        width: size,
                                        height: size,
                                        fit: BoxFit.cover,
                                        cacheWidth:
                                            (size *
                                                    MediaQuery.devicePixelRatioOf(
                                                      context,
                                                    ))
                                                .ceil(),
                                        errorBuilder: (_, _, _) =>
                                            const CasePhotoFailure(),
                                      ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () =>
                        context.push('/home/pets/${value.pet!.id}/edit'),
                    child: const Text('Editar mascota y fotos'),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        if (!widget.petDetailsOnly)
          CaseReportFields(
            locationSearchBuilder: widget.locationSearchBuilder,
            dateTime: value.dateTimeDraft,
            latitude: value.latitude,
            longitude: value.longitude,
            placeController: _place,
            errorId: value.errorId,
            enabled: editable,
            order: 2,
            locationTitle: 'Lugar de desaparición',
            dateInvalid: value.invalidFields.contains(CaseField.date),
            pointInvalid: value.invalidFields.contains(CaseField.point),
            placeInvalid: value.invalidFields.contains(CaseField.place),
            onDate: model.chooseDate,
            onTime: model.chooseTime,
            onPoint: (lat, lon) => model.edit(latitude: lat, longitude: lon),
            onPlace: (text) => model.edit(placeReference: text),
            onReview: model.preview,
          ),
      ],
    );
  }
}
