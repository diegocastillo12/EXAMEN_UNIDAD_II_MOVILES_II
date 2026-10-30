import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/zone_map_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/immersive_photo_sheet.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_screen_shell.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/cover_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/expandable_description.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/loading_shimmer.dart';

void main() {
  for (final small in [false, true]) {
    for (final reduced in [false, true]) {
      testWidgets(
        'Preview swipes, expands smoothly and keeps actions reachable; small=$small reduced=$reduced',
        (tester) async {
          tester.view.physicalSize = small
              ? const Size(320, 350)
              : const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          tester.view.padding = const FakeViewPadding(top: 24, bottom: 34);
          tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 34);
          addTearDown(tester.view.resetPadding);
          addTearDown(tester.view.resetViewPadding);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final capture =
              Platform.environment['CAPTURE_PUBLICATION_PREVIEW'] == '1';
          if (capture) {
            await tester.runAsync(() async {
              final configFile = File(
                '.dart_tool/package_config.json',
              ).absolute;
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
          final boundary = GlobalKey();
          var taps = 0;
          const description =
              'Tiene manchas blancas en el pecho, ojos grandes y una pequeña marca en la oreja izquierda. Lleva un collar oscuro. Es tímida al acercarse personas desconocidas y suele esconderse cerca de los árboles.';
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(small ? 2 : 1),
                  disableAnimations: reduced,
                ),
                child: child!,
              ),
              home: RepaintBoundary(
                key: boundary,
                child: CaseScreenShell(
                  title: 'Mascota perdida',
                  immersive: true,
                  child: ImmersivePhotoSheet(
                    name: small
                        ? 'Luna de nombre extraordinariamente largo sin espacio final abcdefghijklmnopqrstuvwxyz'
                        : 'Luna',
                    createMapTileProvider: () => NetworkTileProvider(
                      httpClient: MockClient(
                        (request) async => http.Response.bytes(
                          TileProvider.transparentImage,
                          200,
                          request: request,
                        ),
                      ),
                      cachingProvider: const DisabledMapCachingProvider(),
                    ),
                    latitude: -12.045,
                    longitude: -77.045,
                    photos: [
                      Image.asset(
                        'assets/illustrations/community_pets.png',
                        fit: BoxFit.cover,
                      ),
                      const ColoredBox(color: Color(0xFF998574)),
                    ],
                    facts: const [
                      PreviewFact(Icons.calendar_today_outlined, '24 meses'),
                      PreviewFact(Icons.pets_outlined, 'Gato'),
                      PreviewFact(Icons.female, 'Hembra'),
                      PreviewFact(Icons.straighten, 'Pequeño'),
                    ],
                    description: description,
                    occurredAt: 'Desaparición: 10/10/2026 15:30',
                    privacy:
                        'Ubicación pública aproximada. Punto y referencia privados. Al publicar, estos datos y fotos serán públicos; evita domicilio, documentos y datos personales.',
                    actions: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LoadingShimmer(
                          isLoading: false,
                          loadingLabel: 'Publicando caso',
                          child: FilledButton(
                            onPressed: () => taps++,
                            child: const Text('Publicar caso'),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Editar reporte'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.runAsync(
            () => precacheImage(
              const AssetImage('assets/illustrations/community_pets.png'),
              boundary.currentContext!,
            ),
          );
          await tester.pumpAndSettle();
          Future<void> shot(String name) async {
            if (!capture) return;
            await tester.runAsync(() async {
              final render =
                  boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary;
              final image = await render.toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final folder = Directory('build/ui-preview/publication-preview')
                ..createSync(recursive: true);
              File(
                '${folder.path}/${small ? 320 : 390}-$reduced-$name.png',
              ).writeAsBytesSync(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }

          expect(find.text('Ficha pública'), findsNothing);
          expect(find.text('Vista previa pública'), findsNothing);
          expect(find.byType(ZoneMapPicker), findsNothing);
          final name = tester.widget<Text>(
            find.text(
              small
                  ? 'Luna de nombre extraordinariamente largo sin espacio final abcdefghijklmnopqrstuvwxyz'
                  : 'Luna',
            ),
          );
          expect(name.maxLines, 2);
          expect(name.overflow, TextOverflow.ellipsis);
          expect(name.style?.fontFamily, isNull);
          expect(name.style?.fontSize, 48);
          expect(name.style?.fontWeight, FontWeight.w800);
          expect(name.style?.color, Colors.white);
          expect(name.style?.shadows, isNotEmpty);
          expect(find.text('Desaparición'), findsOneWidget);
          await shot('collapsed');
          await tester.dragFrom(
            Offset(170, small ? 40 : 135),
            const Offset(-320, 0),
          );
          await tester.pumpAndSettle();
          expect(find.bySemanticsLabel('Foto 2 de 2'), findsOneWidget);
          if (small) {
            final handle = find.byKey(const ValueKey('case-sheet-handle'));
            await tester.scrollUntilVisible(
              handle,
              200,
              scrollable: find.descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable),
              ),
            );
            await tester.pumpAndSettle();
            await tester.dragFrom(
              tester.getCenter(handle),
              const Offset(0, -220),
            );
          } else {
            await tester.tap(find.byKey(const ValueKey('case-sheet-handle')));
          }
          await tester.pumpAndSettle();
          final date = tester.widget<Text>(
            find.text('Desaparición: 10/10/2026 15:30'),
          );
          expect(date.style?.fontSize, 20);
          expect(date.style?.fontWeight, FontWeight.w700);
          await tester.ensureVisible(find.byType(ZoneMapPicker));
          await tester.pumpAndSettle();
          final map = tester.widget<ZoneMapPicker>(find.byType(ZoneMapPicker));
          expect(map.latitude, -12.045);
          expect(map.longitude, -77.045);
          expect(map.onSelect, isNull);
          expect(map.showCenterMarker, isFalse);
          await shot('sheet-expanded');
          final expandable = find.byType(ExpandableDescription);
          await Scrollable.ensureVisible(
            tester.element(expandable),
            alignment: .4,
          );
          await tester.pumpAndSettle();
          final before = tester.getSize(expandable).height;
          await tester.tap(find.text('Ver descripción completa'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 160));
          final middle = tester.getSize(expandable).height;
          await shot('expanding');
          await tester.pumpAndSettle();
          final after = tester.getSize(expandable).height;
          expect(after, greaterThan(before));
          if (!reduced) {
            expect(middle, greaterThan(before));
            expect(middle, lessThan(after));
          }
          expect(find.byType(CoverReveal), findsNothing);
          expect(find.bySemanticsLabel('Foto 2 de 2'), findsOneWidget);
          await shot('expanded');
          await tester.ensureVisible(find.text('Publicar caso'));
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Publicar caso'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Publicar caso'));
          expect(taps, 1);
          await tester.ensureVisible(find.text('Mostrar menos'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Mostrar menos'));
          await tester.pumpAndSettle();
          expect(tester.getSize(expandable).height, closeTo(before, .01));
          final panelScroll = tester.widget<CustomScrollView>(
            find.byType(CustomScrollView),
          );
          panelScroll.controller!.jumpTo(0);
          await tester.pumpAndSettle();
          await tester.dragFrom(const Offset(160, 220), const Offset(0, 400));
          await tester.pumpAndSettle();
          expect(find.byType(ZoneMapPicker, skipOffstage: false), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
