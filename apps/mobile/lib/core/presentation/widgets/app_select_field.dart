import 'package:flutter/material.dart';
import 'app_field_surface.dart';
import 'stagger_reveal.dart';

class AppSelectOption<T> {
  const AppSelectOption({
    required this.value,
    required this.label,
    required this.icon,
  });
  final T value;
  final String label;
  final IconData icon;
}

/// A controlled field; wrapped results distinguish cancellation from a null choice.
class AppSelectField<T> extends StatefulWidget {
  const AppSelectField({
    required this.label,
    this.hint,
    this.sheetTitle,
    this.icon,
    required this.options,
    required this.value,
    required this.onChanged,
    this.invalid = false,
    super.key,
  }) : assert(options.length > 0);
  final String label;
  final String? hint;

  /// Short heading for option panels when the field label is descriptive.
  final String? sheetTitle;
  final IconData? icon;
  final List<AppSelectOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final bool invalid;
  @override
  State<AppSelectField<T>> createState() => _AppSelectFieldState<T>();
}

class _AppSelectFieldState<T> extends State<AppSelectField<T>> {
  final _focus = FocusNode();
  bool _open = false;
  bool _focused = false;
  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  Future<void> _choose() async {
    if (_open || widget.onChanged == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _open = true);
    final media = MediaQuery.of(context);
    try {
      final result = await showModalBottomSheet<AppSelectOption<T>>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.white,
        elevation: 0,
        barrierColor: const Color(0x6624282A),
        constraints: const BoxConstraints(maxWidth: 440),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
        sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
            ? AnimationStyle.noAnimation
            : null,
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: media.textScaler,
            disableAnimations: media.disableAnimations,
            accessibleNavigation: media.accessibleNavigation,
          ),
          child: _SelectPanel<T>(
            label: widget.sheetTitle ?? widget.label,
            options: widget.options,
            value: widget.value,
          ),
        ),
      );
      if (mounted && result != null && widget.onChanged != null) {
        widget.onChanged!(result.value);
        _focus.requestFocus();
      }
    } finally {
      if (mounted) setState(() => _open = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.options
        .where((option) => option.value == widget.value)
        .firstOrNull;
    final invalid = widget.invalid;
    final enabled = widget.onChanged != null;
    return Semantics(
      label: widget.label,
      value: selected?.label ?? widget.hint ?? '',
      button: true,
      enabled: enabled,
      onTap: enabled ? _choose : null,
      hint: invalid ? 'Revisa este campo' : null,
      liveRegion: invalid,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          focusNode: _focus,
          onFocusChange: (value) {
            if (mounted) setState(() => _focused = value);
          },
          onTap: enabled ? _choose : null,
          borderRadius: BorderRadius.circular(22),
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          child: AppFieldSurface(
            label: widget.label,
            icon: widget.icon,
            focused: _focused || _open,
            enabled: enabled,
            invalid: invalid,
            suffix: AnimatedRotation(
              turns: _open ? .5 : 0,
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: invalid
                    ? const Color(0xFFB53F48)
                    : const Color(0xFF6E6E73),
              ),
            ),
            child: Text(
              selected?.label ?? widget.hint ?? 'Seleccionar',
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontSize: 16,
                height: 27 / 16,
                color: invalid
                    ? const Color(0xFFB53F48)
                    : selected == null || !enabled
                    ? const Color(0xFF6E6E73)
                    : const Color(0xFF111111),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectPanel<T> extends StatelessWidget {
  const _SelectPanel({
    required this.label,
    required this.options,
    required this.value,
  });
  final String label;
  final List<AppSelectOption<T>> options;
  final T? value;
  @override
  Widget build(BuildContext context) {
    final entrance =
        ModalRoute.of(context)?.animation ??
        const AlwaysStoppedAnimation<double>(1);
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .85,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar opciones',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF6E6E73),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: AnimatedBuilder(
                    animation: entrance,
                    builder: (context, _) => StaggerReveal(
                      count: options.length,
                      play:
                          entrance.status == AnimationStatus.completed ||
                          MediaQuery.disableAnimationsOf(context),
                      child: Column(
                        children: [
                          for (final entry in options.indexed)
                            StaggerRevealItem(
                              order: entry.$1,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _SelectRow<T>(
                                  option: entry.$2,
                                  selected: entry.$2.value == value,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectRow<T> extends StatelessWidget {
  const _SelectRow({required this.option, required this.selected});
  final AppSelectOption<T> option;
  final bool selected;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: Material(
      color: selected ? const Color(0xFF111111) : const Color(0xFFF5F5F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? const Color(0xFF111111) : const Color(0xFFE5E5EA),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(option),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Icon(
                    option.icon,
                    size: 22,
                    color: selected ? Colors.white : const Color(0xFF6E6E73),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    option.label,
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : const Color(0xFF111111),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (selected)
                  const ExcludeSemantics(
                    child: Icon(
                      Icons.check_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
