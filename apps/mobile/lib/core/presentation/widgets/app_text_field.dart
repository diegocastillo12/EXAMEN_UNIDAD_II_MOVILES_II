import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import 'app_field_surface.dart';

/// Editable content with a label that remains inside the field, even when empty.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    required this.controller,
    this.icon,
    this.hint,
    this.invalid = false,
    this.footer,
    this.enabled = true,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    super.key,
  }) : assert(minLines > 0),
       assert(maxLines >= minLines);

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final String? hint;
  final bool invalid;
  final Widget? footer;
  final bool enabled;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _ownFocus = FocusNode();
  FocusNode get _focus => widget.focusNode ?? _ownFocus;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_focusChanged);
  }

  void _focusChanged() => setState(() {});

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocus).removeListener(_focusChanged);
      _focus.addListener(_focusChanged);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_focusChanged);
    _ownFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppFieldSurface(
    label: widget.label,
    icon: widget.icon,
    invalid: widget.invalid,
    footer: widget.footer,
    enabled: widget.enabled,
    focused: _focus.hasFocus,
    child: Semantics(
      label: widget.label,
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        enabled: widget.enabled,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        autofillHints: widget.autofillHints,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 16,
          height: 27 / 16,
          color: widget.invalid
              ? AppColors.error
              : widget.enabled
              ? AppColors.ink
              : AppColors.secondary,
        ),
        decoration: InputDecoration.collapsed(
          hintText: _focus.hasFocus ? widget.hint : null,
          hintStyle: const TextStyle(color: AppColors.secondary),
        ),
      ),
    ),
  );
}
