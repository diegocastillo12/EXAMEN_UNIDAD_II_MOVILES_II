// Local rendering harness: flutter test tool/capture_toast_preview.dart.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/confirmation_toast.dart';

void main() {
  testWidgets('Capture mobile toast entry, glass, drag and enlarged text', (
    tester,
  ) async {
    final boundary = GlobalKey();
    await tester.runAsync(() async {
      final configFile = File('.dart_tool/package_config.json').absolute;
      final config =
          jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
      final flutter = (config['packages'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((p) => p['name'] == 'flutter');
      final fontRoot = configFile.uri
          .resolve('${flutter['rootUri']}/')
          .resolve('../../bin/cache/artifacts/material_fonts/');
      for (final entry in {
        'Roboto': 'roboto-regular.ttf',
        'MaterialIcons': 'materialicons-regular.otf',
      }.entries) {
        final loader = FontLoader(entry.key)
          ..addFont(
            File.fromUri(
              fontRoot.resolve(entry.value),
            ).readAsBytes().then((b) => ByteData.sublistView(b)),
          );
        await loader.load();
      }
    });
    Future<void> capture(String name) async {
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('build/ui-preview/mobile-toast/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    for (final small in [false, true]) {
      await tester.binding.setSurfaceSize(
        small ? const Size(320, 350) : const Size(390, 844),
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Roboto'),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(small ? 2 : 1)),
              child: child!,
            ),
            home: Scaffold(
              backgroundColor: const Color(0xFFF3F8FF),
              body: ConfirmationToastHost(
                key: ValueKey(small),
                confirmed: true,
                message: small
                    ? 'No pudimos confirmar la operación. Conservamos los datos para reintentar sin duplicar el envío.'
                    : 'No pudimos actualizar el caso.',
                isError: true,
                actionLabel: 'Reintentar',
                onAction: () {},
                child: const Center(
                  child: Text('Entre Huellas', style: TextStyle(fontSize: 24)),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      if (!small) {
        await capture('entry-start');
        await tester.pump(const Duration(milliseconds: 140));
        await capture('entry-middle');
      }
      await tester.pumpAndSettle();
      await capture(small ? 'small-text200' : 'normal');
      expect(tester.takeException(), isNull);
      if (!small) {
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('No pudimos actualizar el caso.')),
        );
        await gesture.moveBy(
          const Offset(0, -24),
          timeStamp: const Duration(seconds: 1),
        );
        await tester.pump();
        await capture('drag');
        await gesture.up(timeStamp: const Duration(seconds: 2));
        await tester.pumpAndSettle();
        await capture('returned');
      }
      await tester.pumpWidget(const SizedBox());
    }
    await tester.binding.setSurfaceSize(null);
  });
}
