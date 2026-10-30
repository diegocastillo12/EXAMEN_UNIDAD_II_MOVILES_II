import 'auth_primary_button_style.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';

import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/shake_field.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../state/registration_view_state.dart';
import 'auth_input_decoration.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({
    required this.state,
    required this.onEdited,
    required this.onSubmit,
    super.key,
  });
  final RegistrationViewState state;
  final void Function(RegistrationField) onEdited;
  final void Function(String, String, String, String) onSubmit;
  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _hidePassword = true;

  bool _hideConfirmation = true;

  @override
  void dispose() {
    for (final controller in [_name, _email, _password, _confirmation]) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _disabled => widget.state.isBusy || widget.state.authenticated;
  void _submit() {
    widget.onSubmit(
      _name.text,
      _email.text,
      _password.text,
      _confirmation.text,
    );
  }

  Widget _input(
    RegistrationField field,
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool password = false,
    bool obscure = false,
    VoidCallback? toggle,
    required Iterable<String> autofillHints,
  }) {
    final invalid = widget.state.errorField == field;
    return StaggerRevealItem(
      order: 3 + field.index,
      child: Semantics(
        liveRegion: invalid,
        child: ShakeField(
          hasError: invalid,
          errorId: widget.state.errorId,
          child: TextField(
            key: ValueKey('register-${field.name}'),
            controller: controller,
            enabled: !_disabled,
            style: TextStyle(
              fontSize: 16,
              height: 27 / 16,
              color: invalid ? const Color(0xFFB53F48) : null,
            ),
            keyboardType: field == RegistrationField.email
                ? TextInputType.emailAddress
                : TextInputType.text,
            textCapitalization: field == RegistrationField.name
                ? TextCapitalization.words
                : TextCapitalization.none,
            textInputAction: field == RegistrationField.confirmation
                ? TextInputAction.done
                : TextInputAction.next,
            obscureText: obscure,
            autocorrect: field == RegistrationField.name,
            enableSuggestions: !password,
            autofillHints: autofillHints,
            onChanged: (_) => widget.onEdited(field),
            onSubmitted: field == RegistrationField.confirmation && !_disabled
                ? (_) => _submit()
                : null,
            decoration: authInputDecoration(
              hint,
              icon,
              invalid: invalid,
              suffix: password
                  ? IconButton(
                      tooltip: obscure
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      onPressed: _disabled ? null : toggle,
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 22,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AutofillGroup(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _input(
          RegistrationField.name,
          _name,
          'Nombre completo',
          Icons.person_outline_rounded,
          autofillHints: const [AutofillHints.name],
        ),
        const SizedBox(height: 12),
        _input(
          RegistrationField.email,
          _email,
          'Correo electrónico',
          Icons.mail_outline_rounded,
          autofillHints: const [AutofillHints.newUsername],
        ),
        const SizedBox(height: 12),
        _input(
          RegistrationField.password,
          _password,
          'Contraseña',
          Icons.lock_outline_rounded,
          password: true,
          obscure: _hidePassword,
          toggle: () => setState(() => _hidePassword = !_hidePassword),
          autofillHints: const [AutofillHints.newPassword],
        ),
        const SizedBox(height: 12),
        _input(
          RegistrationField.confirmation,
          _confirmation,
          'Confirmar contraseña',
          Icons.lock_outline_rounded,
          password: true,
          obscure: _hideConfirmation,
          toggle: () => setState(() => _hideConfirmation = !_hideConfirmation),
          autofillHints: const [AutofillHints.newPassword],
        ),
        const SizedBox(height: 24),
        StaggerRevealItem(
          order: 7,
          child: LoadingShimmer(
            isLoading: widget.state.isBusy,
            loadingLabel: 'Creando cuenta',
            child: FilledButton(
              onPressed: _disabled ? null : _submit,
              style: authPrimaryButtonStyle(
                context,
                isLoading: widget.state.isBusy,
              ),
              child: const Text('Crear cuenta'),
            ),
          ),
        ),
      ],
    ),
  );
}
