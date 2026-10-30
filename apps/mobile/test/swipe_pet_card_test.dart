import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/swipe_pet_card.dart';

void main() {
  for (final reduced in [false, true]) {
    testWidgets(
      'Continuous left swipe returns before confirmation and blocks duplicates; reduced=$reduced',
      (tester) async {
        var confirms = 0;
        var opens = 0;
        var disabled = false;
        Completer<void>? pending;
        Rect? rectAtConfirmation;
        late StateSetter update;
        final material = find.descendant(
          of: find.byType(SwipePetCard),
          matching: find.byType(Material),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 200,
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        update = setState;
                        return SwipePetCard(
                          disabled: disabled,
                          onOpen: () => opens++,
                          onDelete: (origin) async {
                            rectAtConfirmation = tester.getRect(material);
                            expect(origin, rectAtConfirmation);
                            confirms++;
                            await pending?.future;
                          },
                          contentBuilder: (foreground, secondary) => Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Icon(Icons.pets_outlined, color: secondary),
                                const SizedBox(width: 8),
                                const Image(
                                  image: AssetImage(
                                    'assets/branding/app_icon.png',
                                  ),
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Luna',
                                  style: TextStyle(color: foreground),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final baseline = tester.getRect(material);
        await tester.tap(find.text('Luna'));
        expect(opens, 1);
        await tester.drag(find.byType(SwipePetCard), const Offset(-40, 0));
        await tester.pumpAndSettle();
        expect(confirms, 0);
        expect(tester.getRect(material), baseline);
        final startColor = tester.widget<Material>(material).color!;
        final tint = find.byType(ColorFiltered);
        final normalFilter = tester.widget<ColorFiltered>(tint).colorFilter;
        final normalTextColor = tester
            .widget<Text>(find.text('Luna'))
            .style!
            .color!;
        final imageElement = tester.element(find.byType(Image));
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(SwipePetCard)),
        );
        await gesture.moveBy(const Offset(-60, 0));
        await tester.pump();
        final partialColor = tester.widget<Material>(material).color!;
        final partialTextColor = tester
            .widget<Text>(find.text('Luna'))
            .style!
            .color!;
        expect(partialTextColor.r, greaterThan(normalTextColor.r));
        expect(partialTextColor.r, greaterThan(partialTextColor.g));
        expect(tint, findsOneWidget);
        expect(
          tester.widget<ColorFiltered>(tint).colorFilter,
          isNot(normalFilter),
        );
        expect(tester.element(find.byType(Image)), same(imageElement));
        for (final descendant in [
          find.text('Luna'),
          find.byType(Image),
          find.byIcon(Icons.pets_outlined),
        ]) {
          expect(find.ancestor(of: descendant, matching: tint), findsOneWidget);
        }
        expect(
          partialColor.r - partialColor.g,
          greaterThan(startColor.r - startColor.g),
        );
        expect(tester.getRect(material).left, lessThan(baseline.left));
        await gesture.moveBy(const Offset(-240, 0));
        await tester.pump();
        final endColor = tester.widget<Material>(material).color!;
        expect(endColor, const Color(0xFFC12F3D));
        expect(
          tester.widget<Text>(find.text('Luna')).style!.color,
          const Color(0xFFFFE3E6),
        );
        expect(
          tester.widget<Icon>(find.byIcon(Icons.pets_outlined)).color,
          const Color(0xFFFFE3E6),
        );
        expect(
          endColor.r - endColor.g,
          greaterThan(partialColor.r - partialColor.g),
        );
        expect(
          tester.getRect(material).left,
          closeTo(baseline.left - baseline.width * .7, .1),
        );
        expect(find.text('Eliminar'), findsNothing);
        expect(confirms, 0);
        pending = Completer<void>();
        await gesture.up();
        await tester.pump();
        if (!reduced) expect(confirms, 0);
        await tester.pumpAndSettle();
        expect(confirms, 1);
        expect(rectAtConfirmation, baseline);
        expect(tester.getRect(material), baseline);
        expect(tester.widget<ColorFiltered>(tint).colorFilter, normalFilter);
        expect(
          tester.widget<Text>(find.text('Luna')).style!.color,
          normalTextColor,
        );
        expect(tester.element(find.byType(Image)), same(imageElement));
        await tester.longPress(find.byType(SwipePetCard));
        await tester.pumpAndSettle();
        expect(confirms, 1);
        pending.complete();
        pending = null;
        await tester.pumpAndSettle();
        await tester.longPress(find.byType(SwipePetCard));
        await tester.pumpAndSettle();
        expect(confirms, 1);
        await tester.drag(find.byType(SwipePetCard), const Offset(-160, 0));
        await tester.pumpAndSettle();
        expect(confirms, 2);
        update(() => disabled = true);
        await tester.pump();
        await tester.drag(find.byType(SwipePetCard), const Offset(-300, 0));
        await tester.pumpAndSettle();
        expect(confirms, 2);
        expect(tester.getRect(material), baseline);
        update(() => disabled = false);
        await tester.pump();
        final cancel = await tester.startGesture(
          tester.getCenter(find.byType(SwipePetCard)),
        );
        await cancel.moveBy(const Offset(-160, 0));
        await cancel.cancel();
        await tester.pumpAndSettle();
        expect(confirms, 2);
        expect(tester.getRect(material), baseline);
        final disposed = await tester.startGesture(
          tester.getCenter(find.byType(SwipePetCard)),
        );
        await disposed.moveBy(const Offset(-160, 0));
        await disposed.up();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
