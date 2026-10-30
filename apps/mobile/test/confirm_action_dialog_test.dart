import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/confirm_action_dialog.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_dialog_transition.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/popup_dialog_transition.dart';

void main() {
  for (final reduced in [false, true]) {
    testWidgets('Discard popup opens and closes together; reduced=$reduced', (
      tester,
    ) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await confirmActionDialog(
                    context,
                    title: '¿Salir del reporte?',
                    description: 'Se descartarán los datos y fotos.',
                    action: 'Salir',
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(find.byType(OriginDialogTransition), findsNothing);
      final popup = find.byType(PopupDialogTransition);
      final fade = find.descendant(
        of: popup,
        matching: find.byType(FadeTransition),
      );
      final transform = find
          .descendant(of: popup, matching: find.byType(Transform))
          .first;
      final earlyRect = tester.getRect(find.text('¿Salir del reporte?'));
      expect(tester.widget<FadeTransition>(fade).opacity.value, greaterThan(0));
      expect(
        tester.widget<Transform>(transform).transform.entry(0, 0),
        inInclusiveRange(.96, 1.0),
      );
      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.widget<FadeTransition>(fade).opacity.value, 1);
      final finalRect = tester.getRect(find.text('¿Salir del reporte?'));
      expect(earlyRect.width / finalRect.width, inInclusiveRange(.96, 1.0));
      await tester.tap(find.text('Cancelar'));
      await tester.pump();
      if (!reduced) {
        await tester.pump(const Duration(milliseconds: 40));
        expect(
          tester.widget<FadeTransition>(fade).opacity.value,
          inExclusiveRange(0, 1),
        );
        expect(find.text('¿Salir del reporte?'), findsOneWidget);
      }
      await tester.pumpAndSettle();
      expect(result, false);
      expect(popup, findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  for (final small in [false, true]) {
    for (final action in [
      'Salir',
      'Archivar',
      'Eliminar mascota',
      'Salir sin guardar',
    ]) {
      testWidgets('Shared confirmation $action; small=$small', (tester) async {
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final capture = Platform.environment['CAPTURE_CONFIRMATIONS'] == '1';
        if (capture) {
          await tester.runAsync(() async {
            final configFile = File('.dart_tool/package_config.json').absolute;
            final config =
                jsonDecode(await configFile.readAsString())
                    as Map<String, dynamic>;
            final flutterPackage = (config['packages'] as List)
                .cast<Map<String, dynamic>>()
                .firstWhere((package) => package['name'] == 'flutter');
            final fontRoot = configFile.uri
                .resolve('${flutterPackage['rootUri']}/')
                .resolve('../../bin/cache/artifacts/material_fonts/');
            final loader = FontLoader('sans-serif');
            for (final name in [
              'roboto-regular.ttf',
              'roboto-medium.ttf',
              'roboto-bold.ttf',
            ]) {
              loader.addFont(
                File.fromUri(
                  fontRoot.resolve(name),
                ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
              );
            }
            await loader.load();
            final icons = FontLoader('MaterialIcons')
              ..addFont(
                File.fromUri(
                  fontRoot.resolve('materialicons-regular.otf'),
                ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
              );
            await icons.load();
          });
        }
        final captureKey = GlobalKey();
        bool? result;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => RepaintBoundary(
              key: captureKey,
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(small ? 2 : 1)),
                child: child!,
              ),
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await confirmActionDialog(
                      context,
                      title: '¿Confirmar acción?',
                      description: 'Los cambios se aplicarán a la ficha.',
                      action: action,
                    );
                  },
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();
        final cancel = find.widgetWithText(OutlinedButton, 'Cancelar');
        final confirm = find.widgetWithText(FilledButton, action);
        expect(tester.getSize(cancel), tester.getSize(confirm));
        final cancelRect = tester.getRect(cancel),
            confirmRect = tester.getRect(confirm);
        if (cancelRect.top == confirmRect.top) {
          expect(cancelRect.right, lessThan(confirmRect.left));
        } else {
          expect(cancelRect.right, closeTo(confirmRect.right, .01));
        }
        await tester.ensureVisible(confirm);
        await tester.pumpAndSettle();
        if (capture) {
          await tester.runAsync(() async {
            final boundary =
                captureKey.currentContext!.findRenderObject()
                    as RenderRepaintBoundary;
            final image = await boundary.toImage();
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            final folder = Directory('build/ui-preview/confirmations')
              ..createSync(recursive: true);
            File(
              '${folder.path}/${small ? 320 : 390}-$action.png',
            ).writeAsBytesSync(data!.buffer.asUint8List());
            image.dispose();
          });
        }
        // At large text both actions remain reachable through the same scroll.
        await tester.ensureVisible(confirm);
        await tester.tap(confirm);
        await tester.pumpAndSettle();
        expect(result, true);
        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(cancel);
        await tester.tap(cancel);
        await tester.pumpAndSettle();
        expect(result, false);
        expect(find.byType(OriginDialogTransition), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
