import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/loading_shimmer.dart';

void main() {
  testWidgets('Each loading sweep starts at the edge after clicking again', (
    tester,
  ) async {
    final loading = ValueNotifier(false);
    addTearDown(loading.dispose);
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: ColoredBox(
              color: Colors.white,
              child: ValueListenableBuilder<bool>(
                valueListenable: loading,
                builder: (context, busy, _) => LoadingShimmer(
                  isLoading: busy,
                  loadingLabel: 'Ingresando',
                  radius: 0,
                  child: const SizedBox(
                    width: 200,
                    height: 60,
                    child: ColoredBox(color: Color(0xFF24282A)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Future<int> redAtStart() async {
      final boundary =
          boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final raster = await boundary.toImage();
      final bytes = await raster.toByteData(format: ui.ImageByteFormat.rawRgba);
      raster.dispose();
      return bytes!.getUint8((30 * 200 + 20) * 4);
    }

    loading.value = true;
    await tester.pump();
    final initial = await tester.runAsync(redAtStart);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    final swept = await tester.runAsync(redAtStart);
    expect(swept!, greaterThan(initial!));
    loading.value = false;
    await tester.pumpAndSettle();
    loading.value = true;
    await tester.pump();
    final restarted = await tester.runAsync(redAtStart);
    expect(restarted, initial);
    await tester.pumpWidget(const SizedBox());
  });
  for (final reduced in [false, true]) {
    testWidgets(
      'Shimmer preserves label/size, disables action and stops; reduced=$reduced',
      (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            FakeAccessibilityFeatures(disableAnimations: reduced);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        final semantics = tester.ensureSemantics();
        final loading = ValueNotifier(false);
        addTearDown(loading.dispose);
        var calls = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 280,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: loading,
                    builder: (context, busy, _) => LoadingShimmer(
                      isLoading: busy,
                      loadingLabel: 'Enviando código',
                      child: FilledButton(
                        onPressed: busy ? null : () => calls++,
                        child: const Text('Enviar código'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final size = tester.getSize(find.byType(FilledButton));
        loading.value = true;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.getSize(find.byType(FilledButton)), size);
        expect(find.text('Enviar código'), findsOneWidget);
        expect(
          tester
              .widget<Opacity>(
                find.descendant(
                  of: find.byType(LoadingShimmer),
                  matching: find.byType(Opacity),
                ),
              )
              .opacity,
          .72,
        );
        expect(find.bySemanticsLabel('Enviando código'), findsOneWidget);
        expect(tester.binding.hasScheduledFrame, !reduced);
        await tester.tap(find.text('Enviar código'), warnIfMissed: false);
        expect(calls, 0);
        loading.value = false;
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('Enviando código'), findsNothing);
        expect(tester.binding.hasScheduledFrame, false);
        await tester.tap(find.text('Enviar código'));
        expect(calls, 1);
        await tester.pumpAndSettle();
        loading.value = true;
        await tester.pump();
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );
  }
}
