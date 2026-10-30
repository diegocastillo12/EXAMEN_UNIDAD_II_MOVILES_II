import '../../../../core/presentation/widgets/failure_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/international_phone_field.dart';
import '../../../../core/presentation/widgets/app_field_surface.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/shake_field.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../domain/failures/profile_failure.dart';
import '../state/profile_edit_state.dart';
import '../view_models/profile_view_model.dart';

typedef ProfileCityFieldBuilder =
    Widget Function(
      String city,
      bool enabled,
      bool invalid,
      ValueChanged<String> onQuery,
      ValueChanged<String> onSelect,
    );

class ProfileEditor extends ConsumerWidget {
  const ProfileEditor({this.cityFieldBuilder, super.key});
  final ProfileCityFieldBuilder? cityFieldBuilder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileViewModelProvider);
    if (profile.isLoading && !profile.hasError) {
      return const LoadingShimmer(
        isLoading: true,
        loadingLabel: 'Cargando tu perfil',
        radius: 22,
        child: SkeletonFormFields(fieldCount: 4),
      );
    }
    if (profile.hasError) {
      return FailureFeedback(
        message: 'No se pudo cargar tu perfil. Reintenta.',
        noticeId: profile.error,
        onRetry: () => ref.read(profileViewModelProvider.notifier).retry(),
      );
    }
    final value = profile.requireValue;
    final model = ref.read(profileViewModelProvider.notifier);
    return ConfirmationToastHost(
      key: ValueKey(value.profile.userId),
      confirmed: value.saved || value.issue != null,
      isError: value.issue != null,
      noticeId: (value.errorId, value.saved),
      message: value.issue == null
          ? 'Cambios guardados'
          : profileFailureLabel(value.issue!),
      child: _ProfileFields(
        value: value,
        onEdit: model.edit,
        onSave: model.save,
        onDiscard: model.discard,
        cityFieldBuilder: cityFieldBuilder,
        onSelectCity: model.selectCity,
      ),
    );
  }
}

class _ProfileFields extends StatefulWidget {
  const _ProfileFields({
    required this.value,
    required this.onEdit,
    required this.onSave,
    required this.onDiscard,
    required this.onSelectCity,
    this.cityFieldBuilder,
  });
  final ProfileEditState value;
  final void Function({String? displayName, String? city, String? contactPhone})
  onEdit;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final ValueChanged<String> onSelectCity;
  final ProfileCityFieldBuilder? cityFieldBuilder;
  @override
  State<_ProfileFields> createState() => _ProfileFieldsState();
}

class _ProfileFieldsState extends State<_ProfileFields> {
  late final _name = TextEditingController(text: widget.value.displayName);
  late final _phone = TextEditingController(text: widget.value.contactPhone);
  late final _city = TextEditingController(text: widget.value.city);
  @override
  void didUpdateWidget(_ProfileFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final pair in [
      (_name, widget.value.displayName),
      (_city, widget.value.city),
      (_phone, widget.value.contactPhone),
    ]) {
      if (pair.$1.text != pair.$2) {
        pair.$1.value = TextEditingValue(
          text: pair.$2,
          selection: TextSelection.collapsed(offset: pair.$2.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.value;
    final nameError = state.issue == ProfileFailureKind.invalidName;
    final phoneError = state.issue == ProfileFailureKind.invalidPhone;
    final cityError = state.issue == ProfileFailureKind.invalidCity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFieldSurface(
          label: 'Correo electrónico',
          icon: Icons.mail_outline_rounded,
          child: Semantics(
            label: 'Correo electrónico',
            child: SelectableText(
              state.profile.email ?? 'Correo no disponible',
              style: const TextStyle(
                fontSize: 16,
                height: 27 / 16,
                color: Color(0xFF6E6E73),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ShakeField(
          errorId: state.errorId,
          hasError: nameError,
          child: AppTextField(
            label: 'Nombre',
            controller: _name,
            enabled: !state.isBusy,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            hint: 'Tu nombre',
            icon: Icons.person_outline_rounded,
            invalid: nameError,
            onChanged: (value) => widget.onEdit(displayName: value),
          ),
        ),
        const SizedBox(height: 20),
        ShakeField(
          errorId: state.errorId,
          hasError: cityError,
          child:
              widget.cityFieldBuilder?.call(
                state.city,
                !state.isBusy,
                cityError,
                (value) => widget.onEdit(city: value),
                widget.onSelectCity,
              ) ??
              AppTextField(
                label: 'Ciudad',
                controller: _city,
                enabled: !state.isBusy,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.addressCity],
                hint: 'Tu ciudad',
                icon: Icons.location_city_outlined,
                invalid: cityError,
                onChanged: (value) => widget.onEdit(city: value),
                onSubmitted: (_) {
                  if (state.isDirty && !state.isBusy) widget.onSave();
                },
              ),
        ),
        const SizedBox(height: 20),
        ShakeField(
          errorId: state.errorId,
          hasError: phoneError,
          child: InternationalPhoneField(
            label: 'Celular de contacto (opcional)',
            controller: _phone,
            enabled: !state.isBusy,
            invalid: phoneError,
            onChanged: (value) => widget.onEdit(contactPhone: value),
            onSubmitted: (_) {
              if (state.isDirty && !state.isBusy) widget.onSave();
            },
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Elige el país y escribe tu número. Se guarda en privado; tú eliges en qué fichas compartirlo. Cambiarlo aquí no modifica contactos ya publicados.',
          style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF626975)),
        ),
        const SizedBox(height: 24),
        LoadingShimmer(
          isLoading: state.isBusy,
          loadingLabel: 'Guardando perfil',
          child: FilledButton(
            style: primaryActionButtonStyle(context, isLoading: state.isBusy),
            onPressed: state.isBusy || !state.isDirty ? null : widget.onSave,
            child: const Text('Guardar cambios'),
          ),
        ),

        if (state.isDirty)
          TextButton(
            onPressed: state.isBusy ? null : widget.onDiscard,
            child: const Text('Descartar cambios'),
          ),
      ],
    );
  }
}

String profileFailureLabel(ProfileFailureKind kind) => switch (kind) {
  ProfileFailureKind.invalidPhone =>
    'Celular: incluye + y entre 8 y 15 dígitos con código de país.',
  ProfileFailureKind.invalidName => 'Nombre: usa hasta 120 caracteres.',
  ProfileFailureKind.invalidCity =>
    'Selecciona una ciudad de las sugerencias (hasta 120 caracteres).',
  ProfileFailureKind.signedOut => 'Tu sesión cambió. Vuelve a ingresar.',
  ProfileFailureKind.missing => 'Tu perfil no está disponible. Reintenta.',
  _ => 'No se pudo guardar. Conservamos tus cambios para reintentar.',
};
