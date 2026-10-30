import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal_text.dart';

void main() {
  testWidgets(
    'Explicit lines reveal separately and retain a complete semantic label',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StaggerReveal(
            count: 3,
            child: StaggerRevealText(
              text: 'First\nSecond\nThird',
              startOrder: 0,
              style: TextStyle(fontSize: 22),
            ),
          ),
        ),
      );
      double opacity(String line) => tester
          .widget<Opacity>(
            find.ancestor(of: find.text(line), matching: find.byType(Opacity)),
          )
          .opacity;
      await tester.pump(const Duration(milliseconds: 60));
      expect(opacity('First'), greaterThan(0));
      expect(opacity('Second'), 0);
      expect(opacity('Third'), 0);
      await tester.pump(const Duration(milliseconds: 60));
      expect(opacity('Second'), greaterThan(0));
      expect(opacity('Third'), 0);
      expect(find.bySemanticsLabel('First\nSecond\nThird'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(opacity('Third'), 1);
    },
  );
  for (final reducedMotion in [false, true]) {
    testWidgets('Entrance respects reduced motion: $reducedMotion', (
      tester,
    ) async {
      Widget screen() => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reducedMotion),
          child: const StaggerReveal(
            child: Column(
              children: [
                StaggerRevealItem(order: 0, child: Text('Header')),
                StaggerRevealItem(order: 1, child: Text('Action')),
              ],
            ),
          ),
        ),
      );
      double opacity(String label) => tester
          .widget<Opacity>(
            find.ancestor(of: find.text(label), matching: find.byType(Opacity)),
          )
          .opacity;
      await tester.pumpWidget(screen());
      if (reducedMotion) {
        expect(opacity('Header'), 1);
        expect(opacity('Action'), 1);
        await tester.pump();
        expect(tester.binding.hasScheduledFrame, isFalse);
      } else {
        expect(opacity('Header'), 0);
        expect(opacity('Action'), 0);
        await tester.pump(const Duration(milliseconds: 60));
        expect(opacity('Header'), greaterThan(0));
        expect(opacity('Action'), 0);
        final filter = tester.widget<ImageFiltered>(
          find.ancestor(
            of: find.text('Header'),
            matching: find.byType(ImageFiltered),
          ),
        );
        expect(filter.enabled, isTrue);
        await tester.pump(const Duration(milliseconds: 790));
        expect(opacity('Header'), 1);
        expect(opacity('Action'), lessThan(1));
        await tester.pump(const Duration(milliseconds: 90));
        expect(opacity('Action'), 1);
        await tester.pumpAndSettle();
        expect(opacity('Header'), 1);
        expect(opacity('Action'), 1);
      }
      // A state rebuild does not replay an entrance that already finished.
      await tester.pumpWidget(screen());
      expect(opacity('Header'), 1);
      expect(opacity('Action'), 1);
      expect(
        tester
            .widgetList<ImageFiltered>(find.byType(ImageFiltered))
            .every((filter) => !filter.enabled),
        isTrue,
      );
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }
}
