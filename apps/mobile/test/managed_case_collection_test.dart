import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/managed_case_collection.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/swipe_action_card.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/entity_card_content.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/collection_header.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/collection_add_button.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_screen_shell.dart';

void main() {
  for (final small in [false, true]) {
    testWidgets(
      'Shared case cards filter, cancel/confirm swipe and remain usable; small=$small',
      (tester) async {
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (Platform.environment['CAPTURE_CASE_COLLECTIONS'] == '1') {
          await tester.runAsync(() async {
            final configFile = File('.dart_tool/package_config.json');
            final config =
                jsonDecode(await configFile.readAsString())
                    as Map<String, dynamic>;
            final flutter = (config['packages'] as List)
                .cast<Map<String, dynamic>>()
                .firstWhere((p) => p['name'] == 'flutter');
            final root = configFile.uri
                .resolve('${flutter['rootUri']}/')
                .resolve('../../bin/cache/artifacts/material_fonts/');
            for (final entry in {
              'sans-serif': [
                'roboto-regular.ttf',
                'roboto-medium.ttf',
                'roboto-bold.ttf',
              ],
              'MaterialIcons': ['materialicons-regular.otf'],
            }.entries) {
              final loader = FontLoader(entry.key);
              for (final file in entry.value) {
                loader.addFont(
                  File.fromUri(
                    root.resolve(file),
                  ).readAsBytes().then(ByteData.sublistView),
                );
              }
              await loader.load();
            }
          });
        }
        final deleted = <String>[];
        final opened = <String>[];
        final boundary = GlobalKey();
        var items = const [
          ManagedCaseItem(id: 'open', title: 'Luna', status: 'active'),
          ManagedCaseItem(id: 'done', title: 'Sol', status: 'resolved'),
        ];
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: MaterialApp(
              theme: AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(small ? 2 : 1)),
                child: child!,
              ),
              home: StatefulBuilder(
                builder: (context, setState) => CaseScreenShell(
                  title: 'Mis casos',
                  header: const CollectionHeader(
                    title: 'Mis casos',
                    action: CollectionAddButton(
                      label: 'Reportar mascota perdida',
                      route: '/home/lost-cases/new',
                      compact: true,
                    ),
                  ),
                  child: ManagedCaseCollection(
                    items: items,
                    onOpen: (id, origin) => opened.add(id),
                    onDelete: (id) async {
                      deleted.add(id);
                      setState(
                        () => items = items.where((i) => i.id != id).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        Future<void> shot(String label) async {
          if (Platform.environment['CAPTURE_CASE_COLLECTIONS'] != '1') return;
          await tester.pump();
          await tester.runAsync(() async {
            final render =
                boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final img = await render.toImage();
            final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
            final folder = Directory('build/ui-preview/case-collections')
              ..createSync(recursive: true);
            await File(
              '${folder.path}/${small ? 320 : 390}-$label.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            img.dispose();
          });
        }

        expect(find.text('Luna'), findsOneWidget);
        expect(find.text('Sol'), findsNothing);
        expect(find.byType(EntityCardContent), findsOneWidget);
        expect(find.byType(SwipeActionCard), findsOneWidget);
        await shot('open');
        await tester.ensureVisible(find.byType(SwipeActionCard));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Luna'));
        expect(opened, ['open']);
        await tester.drag(find.byType(SwipeActionCard), const Offset(-250, 0));
        await tester.pumpAndSettle();
        expect(find.text('¿Eliminar caso?'), findsOneWidget);
        await shot('confirm');
        await tester.ensureVisible(find.text('Cancelar'));
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(deleted, isEmpty);
        expect(find.text('Luna'), findsOneWidget);
        await tester.ensureVisible(find.text('Resueltos'));
        await tester.tap(find.text('Resueltos'));
        await tester.pumpAndSettle();
        expect(find.text('Luna'), findsNothing);
        expect(find.text('Sol'), findsOneWidget);
        await shot('resolved');
        await tester.ensureVisible(find.byType(SwipeActionCard));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(SwipeActionCard), const Offset(-250, 0));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Eliminar').last);
        await tester.tap(find.text('Eliminar').last);
        await tester.pumpAndSettle();
        expect(deleted, ['done']);
        expect(find.text('No tienes casos resueltos'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
