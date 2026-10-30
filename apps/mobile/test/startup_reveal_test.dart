import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/startup_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/brand_mark.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/brand_name.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/cover_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';

void main() {
  testWidgets(
    'Startup moves the icon left, reveals text, then starts cover/stagger',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StartupReveal(
            child: AuthStageTransition(
              stage: 'login',
              startCovered: true,
              builder: (play) => StaggerReveal(
                play: play,
                count: 3,
                child: const StaggerRevealItem(
                  order: 2,
                  child: Text('Iniciar sesión'),
                ),
              ),
            ),
          ),
        ),
      );
      final iconStart = tester.getTopLeft(find.byType(BrandMark));
      expect(find.text('Iniciar sesión'), findsNothing);
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);
      await tester.pump(const Duration(milliseconds: 550));
      expect(
        tester.getTopLeft(find.byType(BrandMark)).dx,
        lessThan(iconStart.dx),
      );
      final opacity = tester.widget<Opacity>(find.byType(Opacity)).opacity;
      expect(opacity, inExclusiveRange(0, 1));
      await tester.pump(const Duration(milliseconds: 200));
      final iconOvershoot = tester.getTopLeft(find.byType(BrandMark));
      final textOvershoot = tester.getTopLeft(find.byType(BrandName));
      await tester.pump(const Duration(milliseconds: 200));
      final iconSettled = tester.getTopLeft(find.byType(BrandMark));
      final textSettled = tester.getTopLeft(find.byType(BrandName));
      expect(iconOvershoot.dx, lessThan(iconSettled.dx));
      expect(textOvershoot.dx, greaterThan(textSettled.dx));
      expect(iconOvershoot.dy, iconStart.dy);
      expect(iconSettled.dy, iconStart.dy);
      expect(textOvershoot.dy, textSettled.dy);
      expect(find.text('Iniciar sesión'), findsNothing);
      await tester.pump(const Duration(milliseconds: 151));
      expect(find.byType(BrandMark), findsNothing);
      expect(
        tester.widget<StaggerReveal>(find.byType(StaggerReveal)).play,
        false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 321));
      expect(
        tester.widget<StaggerReveal>(find.byType(StaggerReveal)).play,
        true,
      );
      await tester.pumpAndSettle();
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
    },
  );

  testWidgets(
    'Startup skips motion when requested and fits small enlarged layout',
    (tester) async {
      tester.view.physicalSize = const Size(240, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        const MaterialApp(home: StartupReveal(child: Text('Destino'))),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: StartupReveal(key: ValueKey('reduced'), child: Text('Destino')),
        ),
      );
      expect(find.text('Destino'), findsOneWidget);
      expect(find.byType(BrandMark), findsNothing);
    },
  );
}
