import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_page_transition.dart';

void main() {
  testWidgets(
    'Trigger identity morphs in both directions without early page interaction',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 320),
      );
      addTearDown(controller.dispose);
      var taps = 0;
      const origin = Rect.fromLTWH(320, 500, 56, 56);
      await tester.pumpWidget(
        MaterialApp(
          home: OriginPageTransition(
            animation: controller,
            origin: origin,
            source: const OriginPageSource(
              bounds: origin,
              color: Color(0xFF111111),
              radius: 28,
              child: Icon(Icons.add_rounded),
            ),
            child: Center(
              child: TextButton(
                onPressed: () => taps++,
                child: const Text('Destination'),
              ),
            ),
          ),
        ),
      );
      final surface = find.byKey(const ValueKey('origin-surface'));
      final source = find.byKey(const ValueKey('origin-page-source'));
      final content = find
          .ancestor(
            of: find.text('Destination'),
            matching: find.byType(Opacity),
          )
          .first;
      BoxDecoration decoration() =>
          tester
                  .widget<DecoratedBox>(
                    find
                        .ancestor(
                          of: surface,
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      expect(tester.getRect(surface), origin);
      expect(decoration().color, const Color(0xFF111111));
      expect(decoration().borderRadius, BorderRadius.circular(28));
      expect(tester.widget<Opacity>(source).opacity, 1);
      controller.value = .2;
      await tester.pump();
      final earlyRect = tester.getRect(surface);
      final earlyColor = decoration().color;
      final earlyOpacity = tester.widget<Opacity>(source).opacity;
      expect(earlyRect.width, greaterThan(56));
      // The source color remains underneath the fading page background.
      expect(earlyColor, const Color(0xFF111111));
      expect(earlyOpacity, inExclusiveRange(0, 1));
      expect(tester.widget<Opacity>(content).opacity, 0);
      await tester.tapAt(const Offset(200, 400));
      expect(taps, 0);
      controller.value = 1;
      await tester.pump();
      expect(source, findsNothing);
      expect(decoration().color, const Color(0xFF111111));
      expect(tester.widget<Opacity>(content).opacity, 1);
      await tester.tap(find.text('Destination'));
      expect(taps, 1);
      controller.reverse();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 256));
      expect(tester.getRect(surface), earlyRect);
      expect(decoration().color, earlyColor);
      expect(
        tester.widget<Opacity>(source).opacity,
        closeTo(earlyOpacity, .001),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(surface), origin);
      expect(decoration().color, const Color(0xFF111111));
      expect(tester.widget<Opacity>(source).opacity, 1);
    },
  );
  testWidgets(
    'Surface grows from the trigger and reverses without stretching page layout',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 480),
      );
      addTearDown(controller.dispose);
      const origin = Rect.fromLTWH(250, 700, 120, 48);
      await tester.pumpWidget(
        MaterialApp(
          home: OriginPageTransition(
            animation: controller,
            origin: origin,
            child: const SizedBox.expand(key: ValueKey('page-layout')),
          ),
        ),
      );
      final surface = find.byKey(const ValueKey('origin-surface'));
      final content = find
          .ancestor(
            of: find.byKey(const ValueKey('page-layout')),
            matching: find.byType(Opacity),
          )
          .first;
      expect(tester.getRect(surface), origin);
      expect(
        tester.getSize(find.byKey(const ValueKey('page-layout'))),
        const Size(400, 800),
      );
      controller.value = .5;
      await tester.pump();
      final middle = tester.getRect(surface);
      expect(tester.widget<Opacity>(content).opacity, 0);
      expect(middle.width, greaterThan(origin.width));
      expect(middle.width, lessThan(400));
      controller.value = 1;
      await tester.pump();
      expect(tester.getRect(surface), const Rect.fromLTWH(0, 0, 400, 800));
      expect(tester.widget<Opacity>(content).opacity, 1);
      controller.reverse();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 240));
      expect(tester.getRect(surface).width, closeTo(middle.width, .1));
      await tester.pumpAndSettle();
      expect(tester.getRect(surface), origin);
    },
  );
  testWidgets('Reduced motion displays the full page directly', (tester) async {
    final controller = AnimationController(
      vsync: tester,
      duration: const Duration(milliseconds: 480),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: OriginPageTransition(
            animation: controller,
            origin: const Rect.fromLTWH(100, 300, 100, 48),
            child: const Text('Full page'),
          ),
        ),
      ),
    );
    expect(find.text('Full page'), findsOneWidget);
    expect(find.byKey(const ValueKey('origin-surface')), findsNothing);
  });
}
