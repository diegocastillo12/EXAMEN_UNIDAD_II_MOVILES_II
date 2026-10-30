import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/presentation/widgets/shake_field.dart';
import 'auth_primary_button_style.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';

/// A single editable input supports paste/autofill/backspace while six visual
/// cells match the mockup. The visual digits are excluded from semantics.
class EmailCodeInput extends StatefulWidget {
  const EmailCodeInput({
    required this.isBusy,
    this.isVerifying = false,
    required this.onVerify,
    required this.onEdited,
    required this.resendSeconds,
    this.errorHint,
    this.errorId = 0,
    super.key,
  });
  final bool isBusy;
  final bool isVerifying;
  final void Function(String) onVerify;
  final VoidCallback onEdited;
  final int resendSeconds;
  final String? errorHint;
  final int errorId;
  @override
  State<EmailCodeInput> createState() => _EmailCodeInputState();
}

class _EmailCodeInputState extends State<EmailCodeInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  @override
  void initState() {
    super.initState();
    _focus.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(EmailCodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resendSeconds > oldWidget.resendSeconds && !widget.isBusy) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_refresh);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _verify() {
    if (!widget.isBusy && _controller.text.length == 6) {
      widget.onVerify(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ShakeField(
        hasError: widget.errorHint != null,
        errorId: widget.errorId,
        child: SizedBox(
          height: math.max(56, MediaQuery.textScalerOf(context).scale(24) + 24),
          child: Stack(
            children: [
              Positioned.fill(
                child: ExcludeSemantics(
                  child: Row(
                    children: [
                      for (var i = 0; i < 6; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: widget.errorHint != null
                                    ? const Color(0xFFB53F48)
                                    : _focus.hasFocus &&
                                          i == _controller.text.length
                                    ? const Color(0xFF6E6E73)
                                    : const Color(0xFFD2D4DA),
                                width: widget.errorHint == null ? 1 : 3.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                i < _controller.text.length
                                    ? _controller.text[i]
                                    : '',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: widget.errorHint == null
                                      ? const Color(0xFF111111)
                                      : const Color(0xFFB53F48),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Semantics(
                  label: 'Código de verificación de seis dígitos',
                  child: TextField(
                    key: const ValueKey('email-code'),
                    controller: _controller,
                    focusNode: _focus,
                    enabled: !widget.isBusy,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    autocorrect: false,
                    enableSuggestions: false,
                    style: const TextStyle(
                      color: Colors.transparent,
                      fontSize: 24,
                    ),
                    cursorColor: Colors.transparent,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) {
                      setState(() {});
                      widget.onEdited();
                      if (_controller.text.length == 6) _verify();
                    },
                    onSubmitted: (_) => _verify(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Automatic verification on digit six, with an explicit retry for a
      // connection failure or a keyboard which does not send a done action.
      if (_controller.text.length == 6) ...[
        const SizedBox(height: 16),
        LoadingShimmer(
          isLoading: widget.isVerifying,
          loadingLabel: 'Verificando código',
          child: FilledButton(
            onPressed: widget.isBusy ? null : _verify,
            style: authPrimaryButtonStyle(
              context,
              isLoading: widget.isVerifying,
            ),
            child: const Text('Verificar código'),
          ),
        ),
      ],
    ],
  );
}
