import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_page_background.dart';

void main() {
  testWidgets('Clouds move without rebuilding content, stop for accessibility '
      'and hidden routes, and release their ticker', (tester) async {
    final boundary = GlobalKey();
    var builds = 0;
    var reduced = false;
    var visible = true;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: TickerMode(
                enabled: visible,
                child: Center(
                  child: RepaintBoundary(
                    key: boundary,
                    child: SizedBox(
                      width: 96,
                      height: 192,
                      child: AppPageBackground(
                        animate: true,
                        child: Builder(
                          builder: (_) {
                            builds++;
                            return const SizedBox.expand();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    Future<Uint8List> pixels() async {
      late Uint8List bytes;
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        bytes = (await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!.buffer.asUint8List();
        image.dispose();
      });
      return bytes;
    }

    final first = await pixels();
    final initialBuilds = builds;
    await tester.pump(const Duration(seconds: 6));
    final moved = await pixels();
    expect(moved, isNot(orderedEquals(first)));
    expect(builds, initialBuilds);

    update(() => reduced = true);
    await tester.pump();
    final still = await pixels();
    await tester.pump(const Duration(seconds: 6));
    expect(await pixels(), orderedEquals(still));

    update(() {
      reduced = false;
      visible = false;
    });
    await tester.pump();
    final hidden = await pixels();
    await tester.pump(const Duration(seconds: 6));
    expect(await pixels(), orderedEquals(hidden));

    update(() => visible = true);
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    expect(await pixels(), isNot(orderedEquals(hidden)));
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
