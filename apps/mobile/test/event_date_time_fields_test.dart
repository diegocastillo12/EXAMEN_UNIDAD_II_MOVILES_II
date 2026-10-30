import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/state/event_date_time_draft.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/event_date_time_fields.dart';

void main() {
  test(
    'Time can be selected first; existing timestamps retain UTC and seconds until edited',
    () {
      const empty = EventDateTimeDraft();
      final time = empty.withTime(9, 15);
      expect(time.date, isNull);
      expect(time.value, isNull);
      expect(
        time.withDate(DateTime(2026, 10, 9)).value,
        DateTime(2026, 10, 9, 9, 15),
      );
      final original = DateTime.utc(2026, 10, 9, 12, 34, 56, 123);
      expect(EventDateTimeDraft.from(original).value, same(original));
    },
  );
  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'Independent fields use shared surfaces and remain reachable; scale=$scale',
      (tester) async {
        tester.view.physicalSize = Size(scale == 1 ? 390 : 320, 350);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var dates = 0, times = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: EventDateTimeFields(
                    value: EventDateTimeDraft(
                      date: DateTime(2026, 10, 9),
                      hour: 14,
                      minute: 25,
                    ),
                    onDate: () => dates++,
                    onTime: () => times++,
                  ),
                ),
              ),
            ),
          ),
        );
        final date = find.text('09/10/2026'), time = find.text('14:25');
        if (scale == 1) {
          expect(tester.getTopLeft(date).dy, tester.getTopLeft(time).dy);
          expect(
            tester.getTopLeft(time).dx,
            greaterThan(tester.getTopLeft(date).dx),
          );
        }
        await tester.ensureVisible(date);
        await tester.tap(date);
        await tester.ensureVisible(time);
        await tester.tap(time);
        expect(dates, 1);
        expect(times, 1);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: EventDateTimeFields(
                value: const EventDateTimeDraft(),
                onDate: null,
                onTime: null,
              ),
            ),
          ),
        );
        await tester.tap(find.text('Seleccionar').first);
        expect(dates, 1);
      },
    );
  }
}
