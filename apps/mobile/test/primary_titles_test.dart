import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_page_layout.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/collection_header.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/entity_screen_shell.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
    await font.load();
    final body = FontLoader('sans-serif')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    await body.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  for (final small in [false, true]) {
    testWidgets('Home section titles share the same origin; small=$small', (
      tester,
    ) async {
      tester.view.physicalSize = small
          ? const Size(320, 350)
          : const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(small ? 2 : 1),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: HomeScreen(
              profileAvatar: const SizedBox.square(dimension: 48),
              exploreContent: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CollectionHeader(
                  title: 'Explorar',
                  keepActionInline: true,
                  action: IconButton(
                    onPressed: () {},
                    tooltip: 'Guardados',
                    icon: const Icon(Icons.bookmark_border),
                  ),
                ),
              ),
              petsContent: const CollectionHeader(
                title: 'Mis mascotas',
                action: SizedBox.square(dimension: 56),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final origin = tester.getTopLeft(find.text('Su regreso'));
      for (final title in ['Explorar', 'Mis mascotas']) {
        await tester.tap(find.byTooltip(title));
        await tester.pumpAndSettle();
        final heading = find.descendant(
          of: find.byType(CollectionHeader),
          matching: find.text(title),
        );
        final position = tester.getTopLeft(heading);
        expect(position.dx, closeTo(origin.dx, .01), reason: title);
        expect(position.dy, closeTo(origin.dy, .01), reason: title);
      }
      expect(tester.takeException(), isNull);
    });

    for (final page in ['collections', 'saved', 'access']) {
      testWidgets('Primary headings keep content reachable: $page small=$small', (
        tester,
      ) async {
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final boundary = GlobalKey();
        var taps = 0;
        final action = TextButton(
          onPressed: () => taps++,
          child: const Text('Continuar'),
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(small ? 2 : 1),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: RepaintBoundary(
              key: boundary,
              child: switch (page) {
                'saved' => EntityScreenShell(
                  title: 'Guardados',
                  loading: false,
                  child: action,
                ),
                'access' => Scaffold(
                  body: AppPageLayout(
                    title: 'Recupera tu contraseña',
                    child: action,
                  ),
                ),
                _ => Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CollectionHeader(
                          title: 'Explorar',
                          keepActionInline: true,
                          action: IconButton(
                            tooltip: 'Guardados',
                            onPressed: () => taps++,
                            icon: const Icon(Icons.bookmark_border),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const CollectionHeader(
                          title: 'Mis mascotas',
                          action: SizedBox.square(dimension: 56),
                        ),
                        action,
                      ],
                    ),
                  ),
                ),
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (Platform.environment['CAPTURE_PRIMARY_TITLES'] == '1') {
          await tester.runAsync(() async {
            final render =
                boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary;
            final picture = await render.toImage();
            final bytes = await picture.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final target = File(
              'build/ui-preview/primary-titles/$page-${small ? 'small' : 'normal'}.png',
            );
            await target.parent.create(recursive: true);
            await target.writeAsBytes(bytes!.buffer.asUint8List());
            picture.dispose();
          });
        }
        await tester.ensureVisible(find.text('Continuar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continuar'));
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
