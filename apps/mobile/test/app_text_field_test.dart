import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_text_field.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_select_field.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';

void main() {
  for (final small in [false, true]) {
    testWidgets(
      'Internal labels survive editing, reset, errors and disabled fields; small=$small',
      (tester) async {
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final semantics = tester.ensureSemantics();
        final name = TextEditingController();
        final description = TextEditingController();
        final city = TextEditingController(text: 'Lima');
        addTearDown(name.dispose);
        addTearDown(description.dispose);
        addTearDown(city.dispose);
        final boundary = GlobalKey();
        var enabled = true;
        var invalid = false;
        var edits = 0;
        String? species;
        late StateSetter update;

        if (const bool.fromEnvironment('CAPTURE_FIELDS')) {
          await tester.runAsync(() async {
            final configFile = File('.dart_tool/package_config.json').absolute;
            final config =
                jsonDecode(await configFile.readAsString())
                    as Map<String, dynamic>;
            final flutter = (config['packages'] as List)
                .cast<Map<String, dynamic>>()
                .firstWhere((p) => p['name'] == 'flutter');
            final fontRoot = configFile.uri
                .resolve('${flutter['rootUri']}/')
                .resolve('../../bin/cache/artifacts/material_fonts/');
            for (final entry in {
              'sans-serif': ['roboto-regular.ttf', 'roboto-medium.ttf'],
              'MaterialIcons': ['materialicons-regular.otf'],
            }.entries) {
              final loader = FontLoader(entry.key);
              for (final file in entry.value) {
                loader.addFont(
                  File.fromUri(
                    fontRoot.resolve(file),
                  ).readAsBytes().then(ByteData.sublistView),
                );
              }
              await loader.load();
            }
          });
        }
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(small ? 2 : 1),
                disableAnimations: small,
              ),
              child: RepaintBoundary(
                key: boundary,
                child: Scaffold(
                  body: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          update = setState;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppTextField(
                                label: 'Nombre',
                                controller: name,
                                enabled: enabled,
                                invalid: invalid,
                                onChanged: (_) => edits++,
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                label: 'Descripción',
                                controller: description,
                                minLines: 3,
                                maxLines: 5,
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                label: 'Ciudad',
                                controller: city,
                                icon: Icons.location_city_outlined,
                              ),
                              const SizedBox(height: 16),
                              AppSelectField<String>(
                                label: 'Especie',
                                value: species,
                                options: const [
                                  AppSelectOption(
                                    value: 'dog',
                                    label: 'Perro',
                                    icon: Icons.pets_outlined,
                                  ),
                                ],
                                onChanged: enabled
                                    ? (value) => setState(() => species = value)
                                    : null,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        Future<void> capture(String stage) async {
          if (!const bool.fromEnvironment('CAPTURE_FIELDS')) return;
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final raster =
                await (boundary.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary)
                    .toImage(pixelRatio: 2);
            final bytes = await raster.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final folder = Directory('build/ui-preview');
            await folder.create(recursive: true);
            await File(
              '${folder.path}/fields_${stage}_${small ? 'small' : 'normal'}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            raster.dispose();
          });
        }

        final nameInput = find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is AppTextField && w.label == 'Nombre',
          ),
          matching: find.byType(TextField),
        );
        final descriptionInput = find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is AppTextField && w.label == 'Descripción',
          ),
          matching: find.byType(TextField),
        );
        await capture('empty');
        await tester.enterText(nameInput, 'Reyin');
        expect(edits, 1);
        expect(find.text('Nombre'), findsOneWidget);
        expect(find.bySemanticsLabel('Nombre'), findsOneWidget);
        semantics.dispose();
        await tester.ensureVisible(descriptionInput);
        await tester.enterText(
          descriptionInput,
          'Esta es una descripción para Reyin.\nSegunda línea.',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.ensureVisible(nameInput);
        await capture('filled');
        expect(description.text, contains('\n'));
        final select = find.byType(AppSelectField<String>);
        await tester.ensureVisible(select);
        await tester.tap(select);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Perro'));
        await tester.pumpAndSettle();
        expect(species, 'dog');
        expect(find.text('Especie'), findsOneWidget);
        expect(find.text('Perro'), findsOneWidget);
        await capture('selected');
        update(() => invalid = true);
        await tester.pumpAndSettle();
        await tester.ensureVisible(nameInput);
        expect(find.text('Revisa el nombre.'), findsNothing);
        final surface = tester.widget<InputDecorator>(
          find
              .ancestor(of: nameInput, matching: find.byType(InputDecorator))
              .first,
        );
        expect(surface.decoration.errorText, isNull);
        expect(
          (surface.decoration.enabledBorder! as OutlineInputBorder)
              .borderSide
              .width,
          3.5,
        );
        await capture('error');
        name.clear();
        await tester.pumpAndSettle();
        expect(find.text('Nombre'), findsOneWidget);
        expect(name.text, isEmpty);
        expect(edits, 1);
        update(() {
          invalid = false;
          enabled = false;
        });
        await tester.pumpAndSettle();
        await tester.tap(nameInput);
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(nameInput).focusNode!.hasFocus,
          isFalse,
        );
        await tester.ensureVisible(select);
        await tester.tap(select);
        await tester.pumpAndSettle();
        expect(find.byTooltip('Cerrar opciones'), findsNothing);
        expect(species, 'dog');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        name.text = 'Cambio externo tras desmontar';
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
