import 'auth_primary_button_style.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import 'auth_input_decoration.dart';
import '../../../../core/presentation/widgets/shake_field.dart';
import '../state/login_view_state.dart';
import 'package:flutter/material.dart';

class LoginCredentialsForm extends StatefulWidget {
  const LoginCredentialsForm({
    required this.isBusy,
    required this.onSubmit,
    required this.onRecover,
    this.feedback = const LoginViewState(),
    this.onFieldEdited,
    this.reveal = false,
    super.key,
  });
  final bool isBusy;
  final bool reveal;
  final void Function(String email, String password) onSubmit;
  final void Function(Rect?) onRecover;
  final LoginViewState feedback;
  final void Function(LoginField)? onFieldEdited;
  @override
  State<LoginCredentialsForm> createState() => _LoginCredentialsFormState();
}

class _LoginCredentialsFormState extends State<LoginCredentialsForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  Widget _reveal(int order, Widget child) =>
      widget.reveal ? StaggerRevealItem(order: order, child: child) : child;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Widget _input(LoginField field, Widget child) {
    final invalid = field == LoginField.email
        ? widget.feedback.emailInvalid
        : widget.feedback.passwordInvalid;
    return _reveal(
      3 + field.index,
      Semantics(
        liveRegion: invalid,
        hint: invalid ? 'Revisa este campo' : null,
        child: ShakeField(
          errorId: widget.feedback.errorId,
          hasError: invalid,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AutofillGroup(
    child: Column(
      children: [
        _input(
          LoginField.email,
          TextField(
            key: const ValueKey('login-email'),
            controller: _email,
            onChanged: (_) => widget.onFieldEdited?.call(LoginField.email),
            style: TextStyle(
              fontSize: 16,
              height: 27 / 16,
              color: widget.feedback.emailInvalid
                  ? const Color(0xFFB53F48)
                  : null,
            ),
            enabled: !widget.isBusy,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            autocorrect: false,
            decoration: authInputDecoration(
              'Correo electrónico',
              Icons.mail_outline_rounded,
              invalid: widget.feedback.emailInvalid,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _input(
          LoginField.password,
          TextField(
            key: const ValueKey('login-password'),
            controller: _password,
            onChanged: (_) => widget.onFieldEdited?.call(LoginField.password),
            style: TextStyle(
              fontSize: 16,
              height: 27 / 16,
              color: widget.feedback.passwordInvalid
                  ? const Color(0xFFB53F48)
                  : null,
            ),
            enabled: !widget.isBusy,
            obscureText: _obscure,
            enableSuggestions: false,
            autocorrect: false,
            autofillHints: const [AutofillHints.password],
            onSubmitted: widget.isBusy
                ? null
                : (_) => widget.onSubmit(_email.text, _password.text),
            decoration: authInputDecoration(
              'Contraseña',
              Icons.lock_outline_rounded,
              invalid: widget.feedback.passwordInvalid,
              suffix: IconButton(
                tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
                onPressed: widget.isBusy
                    ? null
                    : () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
        _reveal(
          5,
          Align(
            alignment: Alignment.centerRight,
            child: Builder(
              builder: (buttonContext) => TextButton(
                onPressed: widget.isBusy
                    ? null
                    : () {
                        final box = buttonContext.findRenderObject();
                        final navigator = Navigator.of(
                          buttonContext,
                        ).context.findRenderObject();
                        final origin = box is RenderBox && box.hasSize
                            ? box.localToGlobal(
                                    Offset.zero,
                                    ancestor: navigator,
                                  ) &
                                  box.size
                            : null;
                        widget.onRecover(origin);
                      },
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(fontSize: 16, color: Color(0xFF343942)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        _reveal(
          6,
          SizedBox(
            width: double.infinity,
            child: LoadingShimmer(
              isLoading: widget.isBusy,
              loadingLabel: 'Iniciando sesión',
              child: FilledButton(
                onPressed: widget.isBusy
                    ? null
                    : () => widget.onSubmit(_email.text, _password.text),
                style: authPrimaryButtonStyle(
                  context,
                  isLoading: widget.isBusy,
                ),
                child: const Text('Ingresar'),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
