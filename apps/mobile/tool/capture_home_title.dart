// Visual QA: flutter test tool/capture_home_title.dart
import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_scaffold.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_content.dart';

void main() {
  testWidgets('Render home title with real fonts at normal and enlarged sizes', (
    tester,
  ) async {
    await tester.runAsync(() async {
      for (final family in ['Poppins', 'sans-serif']) {
        final loader = FontLoader(family);
        for (final name
            in family == 'Poppins'
                ? ['Poppins-Regular', 'Poppins-SemiBold']
                : ['Roboto-Regular', 'Roboto-Bold']) {
          loader.addFont(
            File(
              'assets/fonts/$name.ttf',
            ).readAsBytes().then(ByteData.sublistView),
          );
        }
        await loader.load();
      }
      final configFile = File('.dart_tool/package_config.json').absolute;
      final config =
          jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
      final flutter = (config['packages'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((entry) => entry['name'] == 'flutter');
      final root = configFile.uri.resolve('${flutter['rootUri']}/');
      final icons = FontLoader('MaterialIcons')
        ..addFont(
          File.fromUri(
            root.resolve(
              '../../bin/cache/artifacts/material_fonts/materialicons-regular.otf',
            ),
          ).readAsBytes().then(ByteData.sublistView),
        );
      await icons.load();
    });
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final small in [false, true]) {
      final size = small ? const Size(320, 350) : const Size(390, 844);
      tester.view.physicalSize = size;
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'sans-serif'),
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              disableAnimations: true,
              textScaler: TextScaler.linear(small ? 2 : 1),
            ),
            child: RepaintBoundary(
              key: key,
              child: AppScaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: StaggerReveal(
                    count: 4,
                    child: HomeContent(onSelect: (_) {}, onReport: (_) {}),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final pixels = await image.toByteData(format: ui.ImageByteFormat.png);
        final directory = Directory('build/ui-preview/home-title')
          ..createSync(recursive: true);
        await File(
          '${directory.path}/${small ? 'small' : 'normal'}.png',
        ).writeAsBytes(pixels!.buffer.asUint8List());
        image.dispose();
      });
    }
  });
}
