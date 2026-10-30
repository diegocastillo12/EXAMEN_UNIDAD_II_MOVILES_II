import 'package:flutter/material.dart';
import '../state/event_date_time_draft.dart';
import 'case_location_fields.dart';
import 'event_date_time_fields.dart';
import 'primary_action_button_style.dart';
import 'shake_field.dart';
import 'stagger_reveal.dart';
export 'case_location_fields.dart' show ReportLocationSearchBuilder;

/// One report block for search origins and linked notices.
class CaseReportFields extends StatelessWidget {
  const CaseReportFields({
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    required this.placeController,
    required this.onDate,
    required this.onTime,
    required this.onPoint,
    required this.onPlace,
    required this.onReview,
    required this.errorId,
    this.dateInvalid = false,
    this.pointInvalid = false,
    this.placeInvalid = false,
    this.enabled = true,
    this.order = 7,
    this.locationTitle = 'Lugar del reporte',
    this.locationSearchBuilder,
    super.key,
  });
  final EventDateTimeDraft dateTime;
  final double? latitude, longitude;
  final TextEditingController placeController;
  final ValueChanged<DateTime> onDate;
  final void Function(int, int) onTime;
  final void Function(double, double) onPoint;
  final ValueChanged<String> onPlace;
  final VoidCallback onReview;
  final int errorId, order;
  final bool dateInvalid, pointInvalid, placeInvalid, enabled;
  final String locationTitle;
  final ReportLocationSearchBuilder? locationSearchBuilder;

  Future<void> _date(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: dateTime.date ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (context.mounted && day != null) onDate(day);
  }

  Future<void> _time(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final time = await showTimePicker(
      context: context,
      initialTime: dateTime.hour == null
          ? TimeOfDay.now()
          : TimeOfDay(hour: dateTime.hour!, minute: dateTime.minute!),
    );
    if (context.mounted && time != null) onTime(time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      StaggerRevealItem(
        order: order,
        child: ShakeField(
          errorId: errorId,
          hasError: dateInvalid,
          child: EventDateTimeFields(
            value: dateTime,
            invalid: dateInvalid,
            onDate: enabled ? () => _date(context) : null,
            onTime: enabled ? () => _time(context) : null,
          ),
        ),
      ),
      const SizedBox(height: 20),
      CaseLocationFields(
        locationSearchBuilder: locationSearchBuilder,
        title: locationTitle,
        order: order + 1,
        latitude: latitude,
        longitude: longitude,
        placeController: placeController,
        errorId: errorId,
        pointInvalid: pointInvalid,
        placeInvalid: placeInvalid,
        onSelect: enabled ? onPoint : null,
        onPlaceChanged: enabled ? onPlace : null,
      ),
      const SizedBox(height: 20),
      StaggerRevealItem(
        order: order + 5,
        child: FilledButton(
          style: primaryActionButtonStyle(context),
          onPressed: enabled ? onReview : null,
          child: const Text('Revisar publicación'),
        ),
      ),
    ],
  );
}
