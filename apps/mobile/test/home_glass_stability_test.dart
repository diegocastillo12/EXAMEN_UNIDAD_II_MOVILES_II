import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/glass_surface.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_content.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/state/home_view_state.dart';

void main() {
  testWidgets(
    'Home glass fades and slides together, then keeps its final rim',
    (tester) async {
      final boundary = GlobalKey();
      HomeSection? selected;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: RepaintBoundary(
              key: boundary,
              child: ColoredBox(
                color: const Color(0xFFE5EFFF),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: StaggerReveal(
                      count: 4,
                      child: HomeContent(
                        onSelect: (value) => selected = value,
                        onReport: (_) {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final card = find.byType(GlassSurface).first;
      final rect = tester.getRect(card);
      final sample = Rect.fromLTWH(rect.right - 14, rect.top + 36, 10, 12);

      Future<Uint8List> borderPixels() async {
        late Uint8List result;
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final data = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!.buffer.asUint8List();
          final pixels = BytesBuilder();
          for (var y = sample.top.toInt(); y < sample.bottom.toInt(); y++) {
            final start = (y * image.width + sample.left.toInt()) * 4;
            pixels.add(data.sublist(start, start + sample.width.toInt() * 4));
          }
          result = pixels.toBytes();
          image.dispose();
        });
        return result;
      }

      final initial = await borderPixels();
      await tester.pump(const Duration(milliseconds: 200));
      final entering = await borderPixels();
      expect(
        entering,
        isNot(orderedEquals(initial)),
        reason: 'Glass must not appear as an empty shell before its content',
      );
      await tester.pumpAndSettle();
      final settledRect = tester.getRect(card);
      expect(settledRect.size, rect.size);
      expect(settledRect.top, closeTo(rect.top + 28, .01));
      final settled = await borderPixels();
      await tester.pump(const Duration(milliseconds: 200));
      expect(await borderPixels(), orderedEquals(settled));
      expect(
        find.image(const AssetImage('assets/illustrations/reunion.png')),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Mis mascotas'));
      await tester.tap(find.text('Mis mascotas'));
      expect(selected, HomeSection.pets);
      expect(tester.takeException(), isNull);
    },
  );
}
