import 'package:country_picker/country_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import 'app_field_surface.dart';
import 'app_text_field.dart';

final _phoneCountries = CountryService()
    .getAll()
    .where((country) => country.phoneCode.isNotEmpty && country.geographic)
    .toList();
final _spanishCountries = CountryLocalizations(const Locale('es'));
String _countryName(Country country) =>
    _spanishCountries.countryName(countryCode: country.countryCode) ??
    country.name;
String _searchable(String value) {
  var result = value.toLowerCase().trim();
  for (final pair in [
    ('á', 'a'),
    ('é', 'e'),
    ('í', 'i'),
    ('ó', 'o'),
    ('ú', 'u'),
    ('ü', 'u'),
    ('ñ', 'n'),
  ]) {
    result = result.replaceAll(pair.$1, pair.$2);
  }
  return result;
}

/// Displays national digits while the controller keeps the full international
/// value. Selecting a country alone never creates a nonempty phone number.
class InternationalPhoneField extends StatefulWidget {
  const InternationalPhoneField({
    required this.controller,
    required this.label,
    this.enabled = true,
    this.invalid = false,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });
  final TextEditingController controller;
  final String label;
  final bool enabled, invalid;
  final ValueChanged<String>? onChanged, onSubmitted;
  @override
  State<InternationalPhoneField> createState() =>
      _InternationalPhoneFieldState();
}

class _InternationalPhoneFieldState extends State<InternationalPhoneField> {
  final _national = TextEditingController();
  final _focus = FocusNode();
  Country? _country = CountryService().findByCode('PE');
  String _prefix = '+51';
  bool _writing = false, _opening = false;

  @override
  void initState() {
    super.initState();
    _readValue();
    widget.controller.addListener(_externalChanged);
    _focus.addListener(_focusChanged);
  }

  @override
  void didUpdateWidget(InternationalPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_externalChanged);
      widget.controller.addListener(_externalChanged);
      _readValue();
    }
  }

  void _focusChanged() {
    if (mounted) setState(() {});
  }

  void _externalChanged() {
    if (_writing) return;
    setState(_readValue);
  }

  void _readValue() {
    final value = widget.controller.text.trim().replaceAll(
      RegExp(r'[ ()-]'),
      '',
    );
    String local = value;
    if (value.isEmpty) {
      _country = CountryService().findByCode('PE');
      _prefix = '+51';
    } else if (value.startsWith('+')) {
      final matches =
          _phoneCountries
              .where((country) => value.startsWith('+${country.phoneCode}'))
              .toList()
            ..sort((a, b) => b.phoneCode.length.compareTo(a.phoneCode.length));
      if (matches.isNotEmpty) {
        final code = matches.first.phoneCode;
        final sameCode = matches
            .where((country) => country.phoneCode == code)
            .toList();
        // A shared code alone cannot identify the country of an existing number.
        _country = sameCode.contains(_country)
            ? _country
            : sameCode.length == 1
            ? sameCode.single
            : null;
        _prefix = '+$code';
        local = value.substring(_prefix.length);
      } else {
        _country = null;
        _prefix = '';
      }
    }
    if (_national.text != local) {
      _national.value = TextEditingValue(
        text: local,
        selection: TextSelection.collapsed(offset: local.length),
      );
    }
  }

  void _emit() {
    final local = _national.text.trim();
    final value = local.isEmpty
        ? ''
        : local.startsWith('+')
        ? local
        : '$_prefix$local';
    _writing = true;
    widget.controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _writing = false;
    widget.onChanged?.call(value);
  }

  void _edit(String value) {
    if (value.trimLeft().startsWith('+')) {
      _writing = true;
      widget.controller.text = value;
      _writing = false;
      setState(_readValue);
    }
    _emit();
  }

  Future<void> _selectCountry() async {
    if (_opening || !widget.enabled) return;
    _opening = true;
    FocusScope.of(context).unfocus();
    try {
      final country = await showModalBottomSheet<Country>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
            ? AnimationStyle.noAnimation
            : null,
        builder: (context) => _PhoneCountrySheet(selected: _country),
      );
      if (!mounted || !widget.enabled || country == null) return;
      setState(() {
        _country = country;
        _prefix = '+${country.phoneCode}';
      });
      _emit();
    } finally {
      _opening = false;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_externalChanged);
    _focus.removeListener(_focusChanged);
    _focus.dispose();
    _national.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countryLabel = _country == null
        ? _prefix.isEmpty
              ? 'Seleccionar país'
              : 'Código compartido $_prefix. Seleccionar país'
        : '${_countryName(_country!)} $_prefix. Cambiar país';
    final countryButton = Semantics(
      label: countryLabel,
      button: true,
      child: Tooltip(
        message: countryLabel,
        child: TextButton(
          onPressed: widget.enabled ? _selectCountry : null,
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            foregroundColor: widget.invalid ? AppColors.error : AppColors.ink,
          ),
          child: ExcludeSemantics(
            child: Wrap(
              spacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (_country == null)
                  const Icon(Icons.public_rounded, size: 24)
                else
                  SvgPicture.asset(
                    'packages/circle_flags/assets/svg/${_country!.countryCode.toLowerCase()}.svg',
                    key: ValueKey('phone-country-${_country!.countryCode}'),
                    width: 24,
                    height: 24,
                  ),
                Text(
                  _prefix.isEmpty ? 'País' : _prefix,
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.expand_more_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
    final input = Semantics(
      label: '${widget.label}. Número sin código de país',
      child: TextField(
        controller: _national,
        focusNode: _focus,
        enabled: widget.enabled,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.telephoneNumber],
        onChanged: _edit,
        onSubmitted: (_) => widget.onSubmitted?.call(widget.controller.text),
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
        decoration: const InputDecoration.collapsed(hintText: 'Tu número'),
      ),
    );
    return AppFieldSurface(
      label: widget.label,
      invalid: widget.invalid,
      enabled: widget.enabled,
      focused: _focus.hasFocus,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 260 ||
              MediaQuery.textScalerOf(context).scale(16) > 22) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(alignment: Alignment.centerLeft, child: countryButton),
                const SizedBox(height: 4),
                input,
              ],
            );
          }
          return Row(
            children: [
              countryButton,
              const SizedBox(width: 12),
              Expanded(child: input),
            ],
          );
        },
      ),
    );
  }
}

class _PhoneCountrySheet extends StatefulWidget {
  const _PhoneCountrySheet({this.selected});
  final Country? selected;
  @override
  State<_PhoneCountrySheet> createState() => _PhoneCountrySheetState();
}

class _PhoneCountrySheetState extends State<_PhoneCountrySheet> {
  final _query = TextEditingController();
  late final _countries = [..._phoneCountries]
    ..sort((a, b) {
      if (a == widget.selected) return -1;
      if (b == widget.selected) return 1;
      return _countryName(a).compareTo(_countryName(b));
    });
  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchable(_query.text);
    final countries = _countries
        .where(
          (country) =>
              query.isEmpty ||
              _searchable(_countryName(country)).contains(query) ||
              _searchable(country.name).contains(query) ||
              country.countryCode.toLowerCase() == query ||
              '+${country.phoneCode}'.contains(query),
        )
        .toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .8,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('País', style: AppTypography.primaryTitle),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Buscar país o código',
                        hint: 'Perú, PE o +51',
                        controller: _query,
                        icon: Icons.search_rounded,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                if (countries.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No hay países que coincidan. Prueba otro nombre o código.',
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final country = countries[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ExcludeSemantics(
                          child: SvgPicture.asset(
                            'packages/circle_flags/assets/svg/${country.countryCode.toLowerCase()}.svg',
                            width: 28,
                            height: 28,
                          ),
                        ),
                        title: Text(_countryName(country)),
                        subtitle: Text('+${country.phoneCode}'),
                        selected: country == widget.selected,
                        trailing: country == widget.selected
                            ? const Icon(Icons.check_rounded)
                            : null,
                        onTap: () => Navigator.of(context).pop(country),
                      );
                    }, childCount: countries.length),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
