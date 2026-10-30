import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/unicode_length_limiting_formatter.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/shake_field.dart';
import '../../domain/entities/pet.dart';
import '../../domain/failures/pet_failure.dart';
import '../state/pet_editor_state.dart';
import '../view_models/pet_editor_view_model.dart';
import '../widgets/pet_screen_shell.dart';
import '../widgets/pet_discard_dialog.dart';
import '../widgets/pet_load_feedback.dart';
import '../widgets/pet_labels.dart';
import '../../../../core/presentation/widgets/app_select_field.dart';
import '../widgets/pet_skeleton.dart';
import '../widgets/pet_size_selector.dart';
import '../widgets/pet_photo_gallery.dart';
import '../view_models/pet_photos_view_model.dart';

class PetEditorScreen extends ConsumerStatefulWidget {
  const PetEditorScreen({required this.petId, super.key});
  final String petId;
  @override
  ConsumerState<PetEditorScreen> createState() => _PetEditorScreenState();
}

class _PetEditorScreenState extends ConsumerState<PetEditorScreen> {
  bool _allowExit = false;
  bool _confirming = false;
  String get petId => widget.petId;

  bool get _busy {
    final editor = ref.read(petEditorViewModelProvider(petId)).asData?.value;
    return editor?.busy == true ||
        (editor != null &&
            ref.read(petPhotosViewModelProvider(editor.id)).busy);
  }

  bool get _hasChanges {
    final editor = ref.read(petEditorViewModelProvider(petId)).asData?.value;
    return editor != null &&
        (editor.hasUnsavedChanges ||
            ref.read(petPhotosViewModelProvider(editor.id)).hasPendingChanges);
  }

  Future<void> _requestExit() async {
    if (_confirming || _allowExit || _busy) return;
    if (_hasChanges) {
      _confirming = true;
      FocusManager.instance.primaryFocus?.unfocus();
      final discard = await confirmPetDiscard(context);
      _confirming = false;
      if (!mounted || !discard || _busy) return;
      final editor = ref.read(petEditorViewModelProvider(petId)).asData?.value;
      if (editor != null) {
        ref
            .read(petPhotosViewModelProvider(editor.id).notifier)
            .discardPending();
      }
    }
    await _leave();
  }

  Future<void> _leave({Pet? saved}) async {
    if (!mounted || _allowExit) return;
    setState(() => _allowExit = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    if (saved != null && petId == 'new') {
      context.replace('/home/pets/${saved.id}', extra: saved);
    } else if (context.canPop()) {
      context.pop(saved);
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(petEditorViewModelProvider(petId));
    ref.listen(petEditorViewModelProvider(petId), (previous, next) {
      final saved = next.asData?.value.saved;
      if (saved != null &&
          previous?.asData?.value.saved == null &&
          context.mounted) {
        _leave(saved: saved);
      }
    });
    final editor = value.asData?.value;
    final photos = editor == null
        ? null
        : ref.watch(petPhotosViewModelProvider(editor.id));
    final busy = editor?.busy == true || photos?.busy == true;
    final changed =
        editor?.hasUnsavedChanges == true || photos?.hasPendingChanges == true;
    return PopScope(
      canPop: _allowExit || (!busy && !changed),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestExit();
      },
      child: PetScreenShell(
        onBack: _requestExit,
        title: petId == 'new' ? 'Registrar mascota' : 'Editar mascota',
        loading: value.isLoading,
        child: value.isLoading
            ? const PetSkeleton(layout: PetSkeletonLayout.editor)
            : value.hasError
            ? PetLoadFeedback(
                error: value.error,
                onRetry: () => ref
                    .read(petEditorViewModelProvider(petId).notifier)
                    .reload(),
              )
            : _PetForm(
                key: ValueKey(value.requireValue.id),
                value: value.requireValue,
                model: ref.read(petEditorViewModelProvider(petId).notifier),
              ),
      ),
    );
  }
}

class _PetForm extends ConsumerStatefulWidget {
  const _PetForm({required this.value, required this.model, super.key});
  final PetEditorState value;
  final PetEditorViewModel model;
  @override
  ConsumerState<_PetForm> createState() => _PetFormState();
}

class _PetFormState extends ConsumerState<_PetForm> {
  late final _name = TextEditingController(text: widget.value.name);
  late final _age = TextEditingController(text: widget.value.age);
  late final _traits = TextEditingController(text: widget.value.traits);
  late final _speciesDetail = TextEditingController(
    text: widget.value.speciesDetail,
  );
  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _traits.dispose();
    _speciesDetail.dispose();
    super.dispose();
  }

  Widget _field(int order, Widget field, {String? label}) => StaggerRevealItem(
    order: order,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null)
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Color(0xFF111111)),
            ),
          if (label != null) const SizedBox(height: 8),
          field,
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final model = widget.model;
    final issue = value.issue;
    final nameError = value.invalidFields.contains(PetFailureKind.invalidName);
    final speciesError = value.invalidFields.contains(
      PetFailureKind.invalidSpecies,
    );
    final ageError = value.invalidFields.contains(PetFailureKind.invalidAge);
    final traitsError = value.invalidFields.contains(
      PetFailureKind.invalidTraits,
    );
    final detailError = value.invalidFields.contains(
      PetFailureKind.invalidSpeciesDetail,
    );
    final sizeError = value.invalidFields.contains(PetFailureKind.invalidSize);
    final photos = ref.watch(petPhotosViewModelProvider(value.id));
    return ConfirmationToastHost(
      confirmed: issue != null,
      isError: true,
      noticeId: value.errorId,
      message: switch (issue) {
        PetFailureKind.invalidName =>
          value.name.trim().isEmpty
              ? 'Completa los campos obligatorios.'
              : 'El nombre admite hasta 80 caracteres.',
        PetFailureKind.invalidSpecies ||
        PetFailureKind.invalidSize => 'Completa los campos obligatorios.',
        PetFailureKind.invalidSpeciesDetail =>
          value.speciesDetail.trim().isEmpty
              ? 'Completa los campos obligatorios.'
              : 'El tipo admite hasta 60 caracteres.',
        PetFailureKind.invalidAge =>
          value.age.trim().isEmpty
              ? 'Completa los campos obligatorios.'
              : 'Introduce una edad de 0 a 600 meses.',
        PetFailureKind.invalidTraits =>
          value.traits.trim().isEmpty
              ? 'Completa los campos obligatorios.'
              : 'Los rasgos admiten hasta 200 caracteres.',
        PetFailureKind.conflict =>
          'La ficha cambió. Revisa la versión actual antes de guardar.',
        _ => 'No se pudo guardar la mascota. Tus cambios siguen aquí.',
      },
      actionLabel: issue == PetFailureKind.conflict ? 'Ver ficha actual' : null,
      onAction: issue == PetFailureKind.conflict
          ? () {
              model.refreshDetail();
              context.push('/home/pets/${value.id}', extra: 'inspect');
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StaggerRevealItem(
            order: 0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: LayoutBuilder(
                builder: (context, constraints) => PetPhotoGallery(
                  petId: value.id,
                  existing: value.original != null,
                  editable: true,
                  locked: value.busy,
                  tileSize: constraints.maxWidth.clamp(0, 160).toDouble(),
                ),
              ),
            ),
          ),
          _field(
            1,
            ShakeField(
              errorId: value.errorId,
              hasError: nameError,
              child: AppTextField(
                label: 'Nombre',
                controller: _name,
                enabled: !value.busy,
                textCapitalization: TextCapitalization.words,
                onChanged: (text) => model.edit(name: text),
                hint: 'Nombre de tu mascota',
                icon: Icons.pets_outlined,
                invalid: nameError,
              ),
            ),
          ),
          _field(
            2,
            ShakeField(
              errorId: value.errorId,
              hasError: speciesError,
              child: AppSelectField<PetSpecies>(
                label: 'Especie',
                hint: 'Seleccionar',
                icon: Icons.category_outlined,
                value: value.species,
                invalid: speciesError,
                options: [
                  for (final species in PetSpecies.values)
                    AppSelectOption(
                      value: species,
                      label: speciesLabel(species),
                      icon: species == PetSpecies.other
                          ? Icons.category_outlined
                          : Icons.pets_outlined,
                    ),
                ],
                onChanged: value.busy
                    ? null
                    : (species) => model.edit(species: species),
              ),
            ),
          ),
          if (value.species == PetSpecies.other)
            _field(
              3,
              ShakeField(
                errorId: value.errorId,
                hasError: detailError,
                child: AppTextField(
                  label: 'Tipo de mascota',
                  controller: _speciesDetail,
                  enabled: !value.busy,
                  onChanged: (text) => model.edit(speciesDetail: text),
                  hint: 'Por ejemplo, conejo o loro',
                  icon: Icons.pets_outlined,
                  invalid: detailError,
                ),
              ),
            ),
          _field(
            4,
            AppSelectField<PetSex?>(
              label: 'Sexo (opcional)',
              hint: 'No lo sé',
              icon: Icons.info_outline_rounded,
              value: value.sex,
              options: [
                const AppSelectOption<PetSex?>(
                  value: null,
                  label: 'No lo sé',
                  icon: Icons.help_outline_rounded,
                ),
                for (final sex in PetSex.values)
                  AppSelectOption<PetSex?>(
                    value: sex,
                    label: sexLabel(sex),
                    icon: sex == PetSex.male
                        ? Icons.male_rounded
                        : Icons.female_rounded,
                  ),
              ],
              onChanged: value.busy
                  ? null
                  : (sex) => model.edit(sex: sex, clearSex: sex == null),
            ),
          ),
          _field(
            5,
            ShakeField(
              errorId: value.errorId,
              hasError: sizeError,
              child: PetSizeSelector(
                value: value.size,
                invalid: sizeError,
                onChanged: value.busy
                    ? null
                    : (size) => model.edit(size: size, clearSize: size == null),
              ),
            ),
            label: 'Tamaño',
          ),
          _field(
            6,
            ShakeField(
              errorId: value.errorId,
              hasError: ageError,
              child: AppTextField(
                label: 'Edad aproximada (meses)',
                controller: _age,
                enabled: !value.busy,
                keyboardType: TextInputType.number,
                onChanged: (text) => model.edit(age: text),
                hint: 'Edad en meses',
                icon: Icons.cake_outlined,
                invalid: ageError,
              ),
            ),
          ),
          _field(
            7,
            ShakeField(
              errorId: value.errorId,
              hasError: traitsError,
              child: AppTextField(
                label: 'Rasgos o descripción',
                controller: _traits,
                enabled: !value.busy,
                minLines: 2,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) => model.edit(traits: text),
                hint: 'Color, marcas u otros detalles',
                icon: Icons.notes_rounded,
                invalid: traitsError,
                inputFormatters: const [UnicodeLengthLimitingFormatter(200)],
                footer: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _traits,
                  builder: (context, text, _) => Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${text.text.runes.length}/200',
                      semanticsLabel:
                          '${text.text.runes.length} de 200 caracteres',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6E6E73),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          StaggerRevealItem(
            order: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShakeField(
                  errorId: value.errorId,
                  hasError: issue != null && value.invalidFields.isEmpty,
                  child: LoadingShimmer(
                    isLoading: value.busy,
                    loadingLabel: 'Guardando mascota',
                    radius: 22,
                    child: FilledButton(
                      style:
                          primaryActionButtonStyle(
                            context,
                            isLoading: value.busy,
                          ).copyWith(
                            side: issue != null && value.invalidFields.isEmpty
                                ? const WidgetStatePropertyAll(
                                    BorderSide(
                                      color: Color(0xFFB53F48),
                                      width: 3.5,
                                    ),
                                  )
                                : null,
                          ),
                      onPressed:
                          value.busy ||
                              photos.busy ||
                              photos.loading ||
                              (!value.dirty && !photos.hasPendingChanges)
                          ? null
                          : model.save,
                      child: Text(
                        value.original == null
                            ? 'Registrar mascota'
                            : 'Guardar cambios',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
