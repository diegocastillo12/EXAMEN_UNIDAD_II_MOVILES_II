import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_text_field.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/international_phone_field.dart';
import 'alert_preferences_test.dart' show loadFonts;

Finder get number => find.descendant(
  of: find.byType(InternationalPhoneField),
  matching: find.byType(TextField),
);
Finder get countryButton => find.descendant(
  of: find.byType(InternationalPhoneField),
  matching: find.byType(TextButton),
);
Finder get search => find.descendant(
  of: find.widgetWithText(AppTextField, 'Buscar país o código'),
  matching: find.byType(TextField),
);

Future<void> openAndSelect(
  WidgetTester tester,
  String query,
  String name,
) async {
  await tester.ensureVisible(countryButton);
  await tester.tap(countryButton);
  await tester.pumpAndSettle();
  await tester.enterText(search, query);
  await tester.pumpAndSettle();
  final row = find.widgetWithText(ListTile, name);
  await tester.scrollUntilVisible(
    row,
    180,
    scrollable: find
        .descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
  await tester.tap(row);
  await tester.pumpAndSettle();
}

Future<void> mount(
  WidgetTester tester,
  TextEditingController controller, {
  ValueChanged<String>? onChanged,
  bool enabled = true,
  double scale = 1,
  GlobalKey? capture,
}) async {
  await tester.runAsync(() async {
    for (final iso in ['PE', 'CO', 'ES', 'CL', 'CA', 'IT']) {
      await SvgAssetLoader(
        'packages/circle_flags/assets/svg/${iso.toLowerCase()}.svg',
      ).loadBytes(null);
    }
  });
  await tester.pumpWidget(
    RepaintBoundary(
      key: capture,
      child: MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: scale > 1,
          ),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: InternationalPhoneField(
              label: 'Celular de contacto',
              controller: controller,
              enabled: enabled,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Default country does not write a prefix-only value; search/select, national digits, full paste and clear',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final changes = <String>[];
      await mount(tester, controller, onChanged: changes.add);
      expect(controller.text, isEmpty);
      expect(changes, isEmpty);
      expect(find.byKey(const ValueKey('phone-country-PE')), findsOneWidget);
      await openAndSelect(tester, 'colombia', 'Colombia');
      expect(controller.text, isEmpty);
      await tester.enterText(number, '300 123 4567');
      expect(controller.text, '+57300 123 4567');
      await openAndSelect(tester, '+34', 'España');
      expect(controller.text, '+34300 123 4567');
      await tester.enterText(number, '+51 900 000 000');
      await tester.pumpAndSettle();
      expect(controller.text, '+51900000000');
      expect(tester.widget<TextField>(number).controller!.text, '900000000');
      expect(find.byKey(const ValueKey('phone-country-PE')), findsOneWidget);
      await tester.enterText(number, '');
      expect(controller.text, isEmpty);
      await openAndSelect(tester, 'CL', 'Chile');
      await tester.enterText(number, '911111111');
      expect(controller.text, '+56911111111');
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Existing values round-trip; ambiguous/shared and unsupported codes never invent a country or rewrite storage',
    (tester) async {
      final controller = TextEditingController(text: '+51900000000');
      addTearDown(controller.dispose);
      final changes = <String>[];
      await mount(tester, controller, onChanged: changes.add);
      expect(tester.widget<TextField>(number).controller!.text, '900000000');
      controller.text = '+14165551234';
      await tester.pump();
      expect(find.byIcon(Icons.public_rounded), findsOneWidget);
      expect(controller.text, '+14165551234');
      expect(changes, isEmpty);
      await openAndSelect(tester, 'CA', 'Canadá');
      expect(controller.text, '+14165551234');
      expect(find.byKey(const ValueKey('phone-country-CA')), findsOneWidget);
      controller.text = '+999123456789';
      await tester.pump();
      expect(
        tester.widget<TextField>(number).controller!.text,
        '+999123456789',
      );
      expect(controller.text, '+999123456789');
      controller.text = '+390612345678';
      await tester.pump();
      expect(tester.widget<TextField>(number).controller!.text, '0612345678');
      await tester.enterText(number, '0612345679');
      expect(controller.text, '+390612345679');
      await tester.pumpWidget(const SizedBox());
      controller.text =
          ''; // disposed field leaves no controller listener behind
    },
  );

  testWidgets(
    'Disabled control, cancel and changing controllers preserve the draft',
    (tester) async {
      final controller = TextEditingController(text: '+51900000000');
      final other = TextEditingController(text: '+573001234567');
      addTearDown(controller.dispose);
      addTearDown(other.dispose);
      await mount(tester, controller, enabled: false);
      expect(tester.widget<TextButton>(countryButton).onPressed, isNull);
      expect(tester.widget<TextField>(number).enabled, isFalse);
      await mount(tester, controller);
      await tester.tap(countryButton);
      await tester.pumpAndSettle();
      await tester.enterText(search, 'zzzzzz');
      await tester.pumpAndSettle();
      expect(find.textContaining('No hay países'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(controller.text, '+51900000000');
      await mount(tester, other);
      await tester.pump();
      expect(find.byKey(const ValueKey('phone-country-CO')), findsOneWidget);
      expect(tester.widget<TextField>(number).controller!.text, '3001234567');
      controller.text = '';
      await tester.pump();
      expect(tester.widget<TextField>(number).controller!.text, '3001234567');
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final small in [false, true]) {
    testWidgets(
      'Country panel fits and scrolls with enlarged text and keyboard; small=$small',
      (tester) async {
        await tester.runAsync(() async {
          await loadFonts();
          final fonts = FontLoader('Poppins')
            ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
          await fonts.load();
        });
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        final controller = TextEditingController(text: '+51900000000');
        addTearDown(controller.dispose);
        final capture = GlobalKey();
        await mount(tester, controller, scale: small ? 2 : 1, capture: capture);
        await tester.pumpAndSettle();
        await tester.tap(countryButton);
        await tester.pumpAndSettle();
        await tester.enterText(search, 'peru');
        await tester.pumpAndSettle();
        if (Platform.environment['CAPTURE_COUNTRY_PHONE'] == '1') {
          await tester.runAsync(() async {
            final image =
                await (capture.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final folder = Directory('build/ui-preview/country-phone')
              ..createSync(recursive: true);
            await File(
              '${folder.path}/${small ? 'small' : 'normal'}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        tester.view.viewInsets = FakeViewPadding(bottom: small ? 140 : 300);
        await tester.pumpAndSettle();
        final row = find.widgetWithText(ListTile, 'Perú');
        await tester.ensureVisible(row);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(row);
        await tester.pumpAndSettle();
        expect(controller.text, '+51900000000');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
