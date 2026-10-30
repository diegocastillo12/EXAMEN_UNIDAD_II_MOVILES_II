import 'package:flutter/material.dart';
import '../state/event_date_time_draft.dart';
import 'app_field_surface.dart';

class EventDateTimeFields extends StatelessWidget {
  const EventDateTimeFields({
    required this.value,
    required this.onDate,
    required this.onTime,
    this.invalid = false,
    super.key,
  });
  final EventDateTimeDraft value;
  final VoidCallback? onDate, onTime;
  final bool invalid;
  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    final date = value.date;
    final dateField = _PickerField(
      label: 'Fecha',
      value: date == null
          ? 'Seleccionar'
          : '${two(date.day)}/${two(date.month)}/${date.year}',
      icon: Icons.calendar_today_outlined,
      invalid: invalid && date == null,
      onTap: onDate,
    );
    final timeField = _PickerField(
      label: 'Hora',
      value: value.hour == null
          ? 'Seleccionar'
          : '${two(value.hour!)}:${two(value.minute!)}',
      icon: Icons.schedule,
      invalid: invalid && (value.hour == null || date != null),
      onTap: onTime,
    );
    if (MediaQuery.textScalerOf(context).scale(16) > 22) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [dateField, const SizedBox(height: 12), timeField],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: dateField),
        const SizedBox(width: 12),
        Expanded(child: timeField),
      ],
    );
  }
}

class _PickerField extends StatefulWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.invalid,
    required this.onTap,
  });
  final String label, value;
  final IconData icon;
  final bool invalid;
  final VoidCallback? onTap;
  @override
  State<_PickerField> createState() => _PickerFieldState();
}

class _PickerFieldState extends State<_PickerField> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.label,
    value: widget.value,
    button: true,
    enabled: widget.onTap != null,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: widget.onTap,
        onFocusChange: (value) {
          if (mounted) setState(() => _focused = value);
        },
        borderRadius: BorderRadius.circular(22),
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        child: AppFieldSurface(
          label: widget.label,
          enabled: widget.onTap != null,
          focused: _focused,
          invalid: widget.invalid,
          suffix: ExcludeSemantics(
            child: Icon(widget.icon, size: 20, color: const Color(0xFF6E6E73)),
          ),
          child: Text(
            widget.value,
            style: const TextStyle(
              fontSize: 16,
              height: 1.7,
              color: Color(0xFF111111),
            ),
          ),
        ),
      ),
    ),
  );
}
