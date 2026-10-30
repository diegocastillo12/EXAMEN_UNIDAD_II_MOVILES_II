import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_dialog_transition.dart';

void main() {
  for (final reduced in [false, true]) {
    testWidgets(
      'Dialog morphs from row before revealing interactive content; reduced=$reduced',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final animation = AnimationController(
          vsync: tester,
          duration: const Duration(milliseconds: 320),
        );
        addTearDown(animation.dispose);
        var taps = 0;
        const origin = Rect.fromLTWH(24, 170, 352, 96);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: OriginDialogTransition(
                animation: animation,
                origin: origin,
                source: const Center(child: Text('Ficha origen')),
                child: SizedBox(
                  height: 180,
                  child: TextButton(
                    onPressed: () => taps++,
                    child: const Text('Confirmar'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final surface = find.byKey(const ValueKey('origin-dialog-surface'));
        final content = find.byKey(const ValueKey('origin-dialog-content'));
        expect(
          tester.widget<Material>(surface).animationDuration,
          Duration.zero,
        );
        if (reduced) {
          expect(find.text('Ficha origen'), findsNothing);
          expect(
            tester.getRect(surface),
            const Rect.fromLTWH(24, 310, 352, 180),
          );
          expect(tester.widget<Opacity>(content).opacity, 1);
          await tester.tap(find.text('Confirmar'));
          expect(taps, 1);
        } else {
          expect(find.text('Ficha origen'), findsOneWidget);
          expect(tester.getRect(surface), origin);
          expect(tester.widget<Opacity>(content).opacity, 0);
          animation.value = .5;
          await tester.pump();
          expect(find.text('Ficha origen'), findsNothing);
          final middle = tester.getRect(surface);
          expect(middle.height, greaterThan(origin.height));
          expect(middle.height, lessThan(180));
          expect(tester.widget<Opacity>(content).opacity, 0);
          animation.value = .85;
          await tester.pump();
          expect(tester.widget<Opacity>(content).opacity, greaterThan(0));
          expect(tester.widget<Opacity>(content).opacity, lessThan(1));
          animation.value = 1;
          await tester.pump();
          expect(
            tester.getRect(surface),
            const Rect.fromLTWH(24, 310, 352, 180),
          );
          expect(tester.widget<Opacity>(content).opacity, 1);
          await tester.tap(find.text('Confirmar'));
          expect(taps, 1);
          animation.reverse();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
          expect(find.text('Ficha origen'), findsNothing);
          expect(
            tester
                .widget<Opacity>(
                  find.byKey(const ValueKey('origin-dialog-overlay')),
                )
                .opacity,
            lessThan(1),
          );
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<Opacity>(
                  find.byKey(const ValueKey('origin-dialog-overlay')),
                )
                .opacity,
            0,
          );
          expect(tester.getRect(surface), origin);
          expect(tester.widget<Opacity>(content).opacity, 0);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
