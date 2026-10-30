import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_select_field.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/cover_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';

void main() {
  for (final title in ['Especie', 'Sexo (opcional)']) {
    for (final reduced in [false, true]) {
      testWidgets('One options entrance for $title; reduced=$reduced', (
        tester,
      ) async {
        tester.view.physicalSize = reduced
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var changes = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                disableAnimations: reduced,
                textScaler: TextScaler.linear(reduced ? 2 : 1),
              ),
              child: Scaffold(
                body: AppSelectField<String>(
                  label: title,
                  value: null,
                  onChanged: (_) => changes++,
                  options: [
                    AppSelectOption(
                      value: 'first',
                      label: title == 'Especie' ? 'Perro' : 'Macho',
                      icon: Icons.pets,
                    ),
                    AppSelectOption(
                      value: 'second',
                      label: title == 'Especie' ? 'Gato' : 'Hembra',
                      icon: Icons.pets,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.byType(AppSelectField<String>));
        await tester.pump();
        expect(find.byType(CoverReveal), findsNothing);
        expect(find.byType(AuthStageTransition), findsNothing);
        expect(find.byType(StaggerReveal), findsOneWidget);
        final entrance = tester.state(find.byType(StaggerReveal));
        final option = find.text(title == 'Especie' ? 'Perro' : 'Macho');
        double opacity() => tester
            .widget<Opacity>(
              find.ancestor(of: option, matching: find.byType(Opacity)).first,
            )
            .opacity;
        expect(opacity(), reduced ? 1 : 0);
        if (!reduced) {
          await tester.pump(const Duration(milliseconds: 100));
          expect(opacity(), 0);
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.byType(CoverReveal), findsNothing);
          await tester.pump(const Duration(milliseconds: 100));
          final progress = opacity();
          expect(progress, greaterThan(0));
          expect(progress, lessThan(1));
          await tester.pump(const Duration(milliseconds: 100));
          expect(opacity(), greaterThan(progress));
        }
        await tester.pumpAndSettle();
        expect(tester.state(find.byType(StaggerReveal)), same(entrance));
        expect(opacity(), 1);
        await tester.tap(option);
        await tester.pumpAndSettle();
        expect(changes, 1);
        expect(find.byTooltip('Cerrar opciones'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
  for (final small in [false, true]) {
    testWidgets(
      'Select cancels without clearing, accepts unknown, and blocks when disabled; small=$small',
      (tester) async {
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        String? value = 'male';
        var changes = 0;
        var enabled = true;
        late StateSetter update;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                size: small ? const Size(320, 350) : const Size(390, 844),
                textScaler: TextScaler.linear(small ? 2 : 1),
                disableAnimations: small,
              ),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      update = setState;
                      return AppSelectField<String?>(
                        label: 'Sexo',
                        hint: 'No lo sé',
                        icon: Icons.info_outline_rounded,
                        value: value,
                        options: const [
                          AppSelectOption(
                            value: 'male',
                            label: 'Macho',
                            icon: Icons.male_rounded,
                          ),
                          AppSelectOption(
                            value: 'female',
                            label: 'Hembra',
                            icon: Icons.female_rounded,
                          ),
                          AppSelectOption(
                            value: null,
                            label: 'No lo sé',
                            icon: Icons.help_outline_rounded,
                          ),
                        ],
                        onChanged: enabled
                            ? (next) => setState(() {
                                value = next;
                                changes++;
                              })
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.byType(AppSelectField<String?>));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
        await tester.tap(find.byTooltip('Cerrar opciones'));
        await tester.pumpAndSettle();
        expect(value, 'male');
        expect(changes, 0);
        await tester.tap(find.byType(AppSelectField<String?>));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('No lo sé').last);
        await tester.tap(find.text('No lo sé').last);
        await tester.pumpAndSettle();
        expect(value, isNull);
        expect(changes, 1);
        expect(find.text('No lo sé'), findsOneWidget);
        update(() => enabled = false);
        await tester.pump();
        await tester.tap(find.byType(AppSelectField<String?>));
        await tester.pumpAndSettle();
        expect(find.byTooltip('Cerrar opciones'), findsNothing);
        expect(changes, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
