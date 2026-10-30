import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_page_layout.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_screen_shell.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pet_screen_shell.dart';

void main() {
  for (final page in ['report', 'pet', 'access']) {
    for (final keyboard in [false, true]) {
      testWidgets(
        '$page paints to bottom without sacrificing last action; keyboard=$keyboard',
        (tester) async {
          tester.view.physicalSize = const Size(320, 350);
          tester.view.devicePixelRatio = 1;
          tester.view.padding = FakeViewPadding(
            top: 24,
            bottom: keyboard ? 0 : 34,
          );
          tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 34);
          tester.view.viewInsets = FakeViewPadding(bottom: keyboard ? 150 : 0);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPadding);
          addTearDown(tester.view.resetViewPadding);
          addTearDown(tester.view.resetViewInsets);
          final boundary = GlobalKey();
          var taps = 0;
          final content = Column(
            children: [
              const ColoredBox(
                color: Color(0xFF546EFF),
                child: SizedBox(height: 1200, width: double.infinity),
              ),
              FilledButton(
                onPressed: () => taps++,
                child: const Text('Guardar'),
              ),
            ],
          );
          final screen = switch (page) {
            'report' => CaseScreenShell(
              title: 'Reporte',
              loading: true,
              child: content,
            ),
            'pet' => PetScreenShell(
              title: 'Mascota',
              loading: true,
              child: content,
            ),
            _ => Scaffold(
              body: AppPageLayout(title: 'Acceso', child: content),
            ),
          };
          await tester.pumpWidget(
            MaterialApp(
              home: RepaintBoundary(key: boundary, child: screen),
            ),
          );
          await tester.pumpAndSettle();
          final bottom = 350.0 - (keyboard ? 150 : 0);
          final viewport = find.byType(SingleChildScrollView).first;
          expect(tester.getRect(viewport).bottom, bottom);
          final scroll = tester.state<ScrollableState>(
            find
                .descendant(of: viewport, matching: find.byType(Scrollable))
                .first,
          );
          scroll.position.jumpTo(600);
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final render =
                boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary;
            final image = await render.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            );
            final index = ((bottom.toInt() - 3) * image.width + 160) * 4;
            expect(
              bytes!.buffer.asUint8List().sublist(index, index + 3),
              [0x54, 0x6E, 0xFF],
              reason:
                  'The gesture inset must show scrolling content, not a white band.',
            );
            image.dispose();
          });
          final region = tester
              .widgetList<AnnotatedRegion<SystemUiOverlayStyle>>(
                find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
              )
              .first;
          expect(region.value.systemNavigationBarColor, Colors.transparent);
          expect(region.value.systemNavigationBarContrastEnforced, false);
          scroll.position.jumpTo(scroll.position.maxScrollExtent);
          await tester.pumpAndSettle();
          expect(
            tester.getRect(find.text('Guardar')).bottom,
            lessThanOrEqualTo(bottom - (keyboard ? 0 : 34)),
          );
          await tester.tap(find.text('Guardar'));
          expect(taps, 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
