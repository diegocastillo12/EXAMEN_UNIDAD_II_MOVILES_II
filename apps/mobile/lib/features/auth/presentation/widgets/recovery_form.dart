import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';

import '../../../../core/presentation/widgets/shake_field.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../state/password_recovery_view_state.dart';
import 'auth_input_decoration.dart';
import 'auth_primary_button_style.dart';

class RecoveryForm extends StatefulWidget {
  const RecoveryForm({
    required this.state,
    required this.onEdited,
    required this.onSubmit,
    required this.onLogin,
    this.reset = false,
    super.key,
  });
  final PasswordRecoveryViewState state;
  final void Function(RecoveryField) onEdited;
  final void Function(String, String) onSubmit;
  final VoidCallback onLogin;
  final bool reset;
  @override
  State<RecoveryForm> createState() => _RecoveryFormState();
}

class _RecoveryFormState extends State<RecoveryForm> {
  final _first = TextEditingController();

  final _second = TextEditingController();
  bool _hideFirst = true;
  bool _hideSecond = true;
  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSubmit(_first.text, _second.text);
  }

  Widget _input(
    RecoveryField field,
    TextEditingController controller,
    String hint,
    int order, {
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    final invalid = widget.state.errorField == field;
    return StaggerRevealItem(
      order: order,
      child: Semantics(
        liveRegion: invalid,
        child: ShakeField(
          hasError: invalid,
          errorId: widget.state.errorId,
          child: TextField(
            key: ValueKey('recovery-${field.name}'),
            controller: controller,
            enabled: !widget.state.isBusy,
            style: TextStyle(
              fontSize: 16,
              height: 27 / 16,
              color: invalid ? const Color(0xFFB53F48) : null,
            ),
            keyboardType: field == RecoveryField.email
                ? TextInputType.emailAddress
                : TextInputType.text,
            autofillHints: field == RecoveryField.email
                ? const [AutofillHints.email]
                : const [AutofillHints.newPassword],
            autocorrect: false,
            enableSuggestions: field == RecoveryField.email,
            obscureText: obscure,
            textInputAction: widget.reset && field == RecoveryField.password
                ? TextInputAction.next
                : TextInputAction.done,
            onChanged: (_) => widget.onEdited(field),
            onSubmitted:
                widget.state.isBusy ||
                    (widget.reset && field == RecoveryField.password)
                ? null
                : (_) => _submit(),
            decoration: authInputDecoration(
              hint,
              field == RecoveryField.email
                  ? Icons.mail_outline_rounded
                  : Icons.lock_outline_rounded,
              invalid: invalid,
              suffix: toggle == null
                  ? null
                  : IconButton(
                      tooltip: obscure
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      onPressed: widget.state.isBusy ? null : toggle,
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 22,
                      ),
                    ),
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
        StaggerRevealItem(
          order: 3,
          child: Text(
            widget.reset
                ? 'Elige una contraseña nueva para tu cuenta.'
                : 'Te enviaremos un código para restablecer tu contraseña.',
            style: const TextStyle(
              fontSize: 18,
              height: 1.4,
              color: Color(0xFF6E6E73),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _input(
          widget.reset ? RecoveryField.password : RecoveryField.email,
          _first,
          widget.reset ? 'Nueva contraseña' : 'Correo electrónico',
          4,
          obscure: widget.reset && _hideFirst,
          toggle: widget.reset
              ? () => setState(() => _hideFirst = !_hideFirst)
              : null,
        ),
        if (widget.reset) ...[
          const SizedBox(height: 12),
          _input(
            RecoveryField.confirmation,
            _second,
            'Confirmar contraseña',
            5,
            obscure: _hideSecond,
            toggle: () => setState(() => _hideSecond = !_hideSecond),
          ),
          const SizedBox(height: 12),
        ],

        const SizedBox(height: 24),
        StaggerRevealItem(
          order: widget.reset ? 7 : 5,
          child: LoadingShimmer(
            isLoading: widget.state.isBusy,
            loadingLabel: widget.reset
                ? 'Guardando contraseña'
                : 'Enviando código',
            child: FilledButton(
              style: authPrimaryButtonStyle(
                context,
                isLoading: widget.state.isBusy,
              ),
              onPressed:
                  widget.state.isBusy ||
                      (!widget.reset && widget.state.resendSeconds > 0)
                  ? null
                  : _submit,
              child: Text(
                widget.reset ? 'Guardar contraseña' : 'Enviar código',
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        StaggerRevealItem(
          order: widget.reset ? 8 : 6,
          child: TextButton(
            onPressed: widget.state.isBusy ? null : widget.onLogin,
            child: const Text(
              'Volver a iniciar sesión',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    ),
  );
}
