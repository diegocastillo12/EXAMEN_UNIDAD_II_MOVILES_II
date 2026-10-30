import '../../../../core/presentation/widgets/report_draft_status.dart';
import '../../../../core/presentation/widgets/case_report_fields.dart';
import '../../../../core/presentation/widgets/size_choice_selector.dart';
import '../../../../core/presentation/widgets/photo_add_tile.dart';
import '../../../../core/presentation/widgets/validation_surface.dart';
import '../../../../core/presentation/widgets/photo_gallery_strip.dart';
import '../../../../core/presentation/widgets/case_photo_failure.dart';
import '../../../../core/presentation/widgets/unicode_length_limiting_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/app_select_field.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/case_screen_shell.dart';
import '../../../../core/presentation/widgets/confirm_discard_action.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/shake_field.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../domain/entities/found_case.dart';
import '../state/found_editor_state.dart';
import '../view_models/found_editor_view_model.dart';
import '../widgets/found_public_content.dart';

class FoundEditorScreen extends ConsumerStatefulWidget {
  const FoundEditorScreen({
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
  ConsumerState<FoundEditorScreen> createState() => _FoundEditorScreenState();
}

class _FoundEditorScreenState extends ConsumerState<FoundEditorScreen> {
  final _traits = TextEditingController(),
      _detail = TextEditingController(),
      _place = TextEditingController();
  bool _leaving = false, _canPop = false;
  @override
  void dispose() {
    for (final c in [_traits, _detail, _place]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _leave() async {
    final v = ref.read(foundEditorViewModelProvider).asData?.value;
    if (_leaving || v?.busy == true) return;
    _leaving = true;
    final leave =
        v?.dirty != true ||
        await confirmDiscardAction(
          context,
          '¿Salir del reporte?',
          v?.lockedDraft != null
              ? 'El envío pudo haberse publicado. Revisa Mis búsquedas y avisos antes de reportarlo otra vez.'
              : 'Conservaremos el borrador en este dispositivo para que puedas retomarlo.',
          'Salir',
        );
    if (!mounted) {
      _leaving = false;
      return;
    }
    if (!leave) {
      _leaving = false;
      return;
    }
    if (v?.dirty == true &&
        !await ref.read(foundEditorViewModelProvider.notifier).saveForLater()) {
      _leaving = false;
      return;
    }
    _leaving = false;
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
    ref.listen(foundEditorViewModelProvider, (previous, next) {
      if (next.isLoading ||
          next.hasError ||
          previous?.asData?.value.ownerId != next.asData?.value.ownerId) {
        for (final c in [_traits, _detail, _place]) {
          c.clear();
        }
      }
      final current = next.isLoading || next.hasError
          ? null
          : next.asData?.value;
      if (current != null) {
        for (final entry in [
          (_traits, current.traits),
          (_detail, current.speciesDetail),
          (_place, current.placeReference),
        ]) {
          if (entry.$1.text != entry.$2) entry.$1.text = entry.$2;
        }
      }
    });
    final async = ref.watch(foundEditorViewModelProvider),
        v = async.isLoading || async.hasError ? null : async.asData?.value;
    final model = ref.read(foundEditorViewModelProvider.notifier);
    final targetClosed =
        v?.issue == FoundFailureKind.targetClosed ||
        (async.error is FoundFailure &&
            (async.error as FoundFailure).kind ==
                FoundFailureKind.targetClosed);
    if (v != null) {
      for (final entry in [
        (_traits, v.traits),
        (_detail, v.speciesDetail),
        (_place, v.placeReference),
      ]) {
        if (entry.$1.text != entry.$2) entry.$1.text = entry.$2;
      }
    }
    if (widget.embedded) {
      return async.isLoading
          ? const SkeletonFormFields(fieldCount: 1)
          : async.hasError
          ? TextButton(onPressed: model.retry, child: const Text('Reintentar'))
          : v == null
          ? const SizedBox.shrink()
          : _content(v, model);
    }
    return PopScope(
      canPop: _canPop || (v?.dirty != true && v?.busy != true),
      onPopInvokedWithResult: (popped, result) {
        if (!popped) _leave();
      },
      child: CaseScreenShell(
        title: v?.reportKind == 'independent_found'
            ? 'Mascota encontrada'
            : (v?.communitySearch ?? model.communitySearch)
            ? 'Posible pérdida'
            : 'Reportar aviso',
        count: v != null && v.stage == FoundStage.form
            ? (v.communitySearch ? 13 : 9)
            : 2,
        onBack: _leave,
        stage: v?.stage ?? 'initial',
        loading: async.isLoading,
        immersive: v?.stage == FoundStage.preview,
        notice: async.hasError
            ? (async.error is FoundFailure &&
                      (async.error as FoundFailure).kind ==
                          FoundFailureKind.targetClosed
                  ? foundFailureLabel(FoundFailureKind.targetClosed)
                  : 'No pudimos preparar el reporte. Revisa tu sesión y conexión.')
            : v?.issue != null
            ? foundFailureLabel(v!.issue)
            : v?.stage == FoundStage.confirmed
            ? (v?.communitySearch == false
                  ? 'Aviso publicado'
                  : v?.reportKind == 'independent_found'
                  ? 'Hallazgo publicado'
                  : 'Búsqueda publicada')
            : null,
        noticeActionLabel: targetClosed ? 'Volver a la ficha' : null,
        onNoticeAction: targetClosed && v?.busy != true ? _leave : null,
        noticeIsError: v?.stage != FoundStage.confirmed,
        noticeId: (async.error, v?.ownerId, v?.errorId, v?.stage),
        child: async.isLoading
            ? const SkeletonFormFields(fieldCount: 4)
            : async.hasError && targetClosed
            ? const SizedBox.shrink()
            : async.hasError
            ? Column(
                children: [
                  TextButton(
                    onPressed: model.retry,
                    child: const Text('Reintentar'),
                  ),
                ],
              )
            : v == null
            ? const SizedBox.shrink()
            : _content(v, model),
      ),
    );
  }

  Widget _field(FoundEditorState v, FoundField f, Widget child) => ShakeField(
    errorId: v.errorId,
    hasError: v.invalidFields.contains(f),
    child: child,
  );
  Widget _content(FoundEditorState v, FoundEditorViewModel m) =>
      v.stage != FoundStage.form
      ? _editorContent(v, m)
      : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!(v.stage == FoundStage.confirmed) && !widget.petDetailsOnly)
              ReportDraftStatus(
                submissionState: v.submissionStatus?.name,
                onRetry: v.issue == FoundFailureKind.localStorage && !v.busy
                    ? m.saveForLater
                    : null,
                onDiscard: v.busy ? null : () => m.discardLocalDraft(v.draftId),
              ),
            _editorContent(v, m),
          ],
        );
  Widget _editorContent(FoundEditorState v, FoundEditorViewModel m) {
    if (v.stage == FoundStage.confirmed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          StaggerRevealItem(
            order: 0,
            child: FilledButton(
              style: primaryActionButtonStyle(context),
              onPressed: () => context.pushReplacement(
                '/home/found-cases/${v.published!.id}',
              ),
              child: const Text('Ver ficha pública'),
            ),
          ),
        ],
      );
    }
    if (v.stage == FoundStage.preview) {
      final preview = v.preview;
      return FoundPreviewContent(
        value: preview,
        localPhotos: {for (final p in v.photos) p.id: p.bytes},
        actions: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (v.submissionStatus != null)
              Text(reportSubmissionStatusLabel(v.submissionStatus?.name)),
            TextButton(
              onPressed: v.busy
                  ? null
                  : () => context.push('/home/submissions'),
              child: const Text('Ver envíos'),
            ),
            if (v.attempted)
              ReportDraftStatus(
                onRetry: null,
                onDiscard: v.busy ? null : () => m.discardLocalDraft(v.draftId),
              ),
            if (v.lockedDraft != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: v.busy
                    ? null
                    : () => context.push('/home/my-found-cases'),
                child: const Text('Consultar Mis búsquedas y avisos'),
              ),
            ],
            const SizedBox(height: 24),
            ValidationSurface(
              invalid: v.issue != null && v.invalidFields.isEmpty,
              errorId: v.errorId,
              child: LoadingShimmer(
                isLoading: v.busy,
                loadingLabel: 'Procesando fotos y publicando caso',
                child: FilledButton(
                  style: primaryActionButtonStyle(context, isLoading: v.busy),
                  onPressed: v.busy || v.issue == FoundFailureKind.targetClosed
                      ? null
                      : m.publish,
                  child: const Text('Publicar caso'),
                ),
              ),
            ),
            TextButton(
              onPressed:
                  v.busy ||
                      v.lockedDraft != null ||
                      v.issue == FoundFailureKind.targetClosed
                  ? null
                  : m.backToForm,
              child: const Text('Editar reporte'),
            ),
          ],
        ),
      );
    }
    final enabled = !v.busy && v.issue != FoundFailureKind.targetClosed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.petDetailsOnly)
          StaggerRevealItem(
            order: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  v.reportKind == 'independent_found'
                      ? 'Publica la mascota que encontraste, aunque no conozcas a su familia. Añade fotos para buscar posibles coincidencias.'
                      : v.communitySearch
                      ? 'Reporta una mascota que sospechas que está perdida. No hace falta registrarla como tuya.'
                      : 'Tu aviso se enviará a esta búsqueda. No confirma la recuperación ni cierra el caso.',
                ),
                if (v.reportKind == 'independent_found') ...[
                  const SizedBox(height: 20),
                  AppSelectField<String>(
                    label: '¿Está bajo tu cuidado?',
                    value: v.custody,
                    options: const [
                      AppSelectOption(
                        value: '',
                        label: 'No indico',
                        icon: Icons.help_outline,
                      ),
                      AppSelectOption(
                        value: 'with_me',
                        label: 'Sí, está conmigo',
                        icon: Icons.pets_outlined,
                      ),
                      AppSelectOption(
                        value: 'not_with_me',
                        label: 'No está conmigo',
                        icon: Icons.visibility_outlined,
                      ),
                    ],
                    onChanged: enabled
                        ? (value) => m.edit(custody: value)
                        : null,
                  ),
                ],
                if (!v.communitySearch) ...[
                  const SizedBox(height: 20),
                  Text(
                    v.target?.name.isNotEmpty == true
                        ? v.target!.name
                        : 'Aviso para esta mascota',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppSelectField<String>(
                    label: '¿Qué ocurrió?',
                    value: v.reportKind,
                    options: const [
                      AppSelectOption(
                        value: 'sighting',
                        label: 'La vi',
                        icon: Icons.visibility_outlined,
                      ),
                      AppSelectOption(
                        value: 'with_reporter',
                        label: 'La encontré y está conmigo',
                        icon: Icons.pets_outlined,
                      ),
                    ],
                    onChanged: enabled ? m.chooseObservation : null,
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 20),
        if (v.communitySearch) ...[
          StaggerRevealItem(
            order: 1,
            child: _field(
              v,
              FoundField.species,
              AppSelectField<String>(
                label: 'Especie',
                icon: Icons.category_outlined,
                value: v.species.isEmpty ? null : v.species,
                invalid: v.invalidFields.contains(FoundField.species),
                options: const [
                  AppSelectOption(
                    value: 'dog',
                    label: 'Perro',
                    icon: Icons.pets_outlined,
                  ),
                  AppSelectOption(
                    value: 'cat',
                    label: 'Gato',
                    icon: Icons.pets_outlined,
                  ),
                  AppSelectOption(
                    value: 'other',
                    label: 'Otra',
                    icon: Icons.pets_outlined,
                  ),
                ],
                onChanged: enabled ? (s) => m.edit(species: s) : null,
              ),
            ),
          ),
          if (v.species == 'other') ...[
            const SizedBox(height: 20),
            StaggerRevealItem(
              order: 2,
              child: AppTextField(
                label: 'Tipo de mascota',
                icon: Icons.pets_outlined,
                controller: _detail,
                enabled: enabled,
                onChanged: (s) => m.edit(speciesDetail: s),
              ),
            ),
          ],
          const SizedBox(height: 20),
          StaggerRevealItem(
            order: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tamaño (opcional)',
                  style: TextStyle(fontSize: 16, color: Color(0xFF111111)),
                ),
                const SizedBox(height: 8),
                SizeChoiceSelector<String>(
                  value: v.size.isEmpty ? null : v.size,
                  options: const [
                    SizeChoiceOption(value: 'small', label: 'Pequeño'),
                    SizeChoiceOption(value: 'medium', label: 'Mediano'),
                    SizeChoiceOption(value: 'large', label: 'Grande'),
                  ],
                  onChanged: enabled
                      ? (size) => m.edit(size: size ?? '')
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StaggerRevealItem(
            order: 4,
            child: AppSelectField<String>(
              label: 'Sexo (opcional)',
              icon: Icons.info_outline_rounded,
              value: v.sex,
              options: const [
                AppSelectOption(
                  value: '',
                  label: 'No lo sé',
                  icon: Icons.help_outline,
                ),
                AppSelectOption(
                  value: 'male',
                  label: 'Macho',
                  icon: Icons.male,
                ),
                AppSelectOption(
                  value: 'female',
                  label: 'Hembra',
                  icon: Icons.female,
                ),
              ],
              onChanged: enabled ? (s) => m.edit(sex: s) : null,
            ),
          ),
          const SizedBox(height: 20),
        ],
        StaggerRevealItem(
          order: v.communitySearch ? 5 : 1,
          child: _field(
            v,
            FoundField.traits,
            AppTextField(
              label: v.communitySearch
                  ? 'Rasgos o descripción'
                  : 'Descripción del aviso',
              icon: Icons.notes_rounded,
              minLines: 2,
              controller: _traits,
              maxLines: 3,
              inputFormatters: const [UnicodeLengthLimitingFormatter(200)],
              footer: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${v.traits.runes.length}/200',
                  semanticsLabel: '${v.traits.runes.length} de 200 caracteres',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6E6E73),
                  ),
                ),
              ),
              enabled: enabled,
              invalid: v.invalidFields.contains(FoundField.traits),
              onChanged: (s) => m.edit(traits: s),
            ),
          ),
        ),
        const SizedBox(height: 20),
        StaggerRevealItem(
          order: v.communitySearch ? 6 : 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                v.communitySearch
                    ? 'Fotos que se mostrarán públicamente'
                    : 'Fotos del aviso (opcional)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ValidationSurface(
                invalid: v.invalidFields.contains(FoundField.photos),
                errorId: v.errorId,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final size = PhotoGalleryStrip.detailTileSize(
                          constraints.maxWidth,
                        );
                        return LoadingShimmer(
                          isLoading: v.busy,
                          loadingLabel: 'Preparando foto',
                          radius: 22,
                          child: PhotoGalleryStrip(
                            children: [
                              for (final photo in v.photos)
                                PhotoGalleryTile(
                                  id: photo.id,
                                  size: size,
                                  invalid: v.invalidFields.contains(
                                    FoundField.photos,
                                  ),
                                  remove: enabled
                                      ? () => m.removePhoto(photo.id)
                                      : null,
                                  child: Image.memory(
                                    photo.bytes,
                                    width: size,
                                    height: size,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        const CasePhotoFailure(),
                                  ),
                                ),
                              if (v.photos.length < 3)
                                PhotoAddTile(
                                  size: size,
                                  invalid: v.invalidFields.contains(
                                    FoundField.photos,
                                  ),
                                  semanticLabel: 'Elegir foto',
                                  onTap: enabled ? () => m.choosePhoto() : null,
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    TextButton.icon(
                      onPressed: enabled && v.photos.length < 3
                          ? () => m.choosePhoto(camera: true)
                          : null,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Tomar foto'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        if (!widget.petDetailsOnly)
          CaseReportFields(
            locationSearchBuilder: widget.locationSearchBuilder,
            dateTime: v.dateTimeDraft,
            latitude: v.latitude,
            longitude: v.longitude,
            placeController: _place,
            errorId: v.errorId,
            enabled: enabled,
            order: v.communitySearch ? 7 : 3,
            locationTitle: v.communitySearch
                ? 'Lugar donde la viste'
                : 'Lugar del aviso',
            dateInvalid: v.invalidFields.contains(FoundField.date),
            pointInvalid: v.invalidFields.contains(FoundField.point),
            placeInvalid: v.invalidFields.contains(FoundField.place),
            onDate: m.chooseDate,
            onTime: m.chooseTime,
            onPoint: (lat, lon) => m.edit(latitude: lat, longitude: lon),
            onPlace: (text) => m.edit(placeReference: text),
            onReview: m.preview,
          ),
      ],
    );
  }
}
