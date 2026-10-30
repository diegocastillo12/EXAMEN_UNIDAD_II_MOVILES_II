import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/cover_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pet_screen_shell.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_screen_shell.dart';

void main() {
  for (final delay in [50, 2000]) {
    testWidgets('Report loading is not a new stage after ${delay}ms', (
      tester,
    ) async {
      var loading = true;
      Object stage = 'initial';
      var taps = 0;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return CaseScreenShell(
                title: 'Mascota perdida',
                loading: loading,
                stage: stage,
                child: StaggerRevealItem(
                  order: 0,
                  child: TextButton(
                    onPressed: () => taps++,
                    child: Text(loading ? 'Skeleton' : '$stage'),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump(Duration(milliseconds: delay));
      update(() {
        loading = false;
        stage = 'editing';
      });
      await tester.pump();
      expect(find.byType(CoverReveal), findsNothing);
      expect(find.text('Skeleton'), findsNothing);
      expect(
        tester
            .widget<Opacity>(
              find
                  .ancestor(
                    of: find.text('editing'),
                    matching: find.byType(Opacity),
                  )
                  .first,
            )
            .opacity,
        1,
      );
      await tester.tap(find.text('editing'));
      expect(taps, 1);
      update(() => stage = 'preview');
      await tester.pump();
      expect(find.byType(CoverReveal), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('editing'), findsNothing);
      expect(find.text('preview'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final delay in [50, 2000]) {
    for (final result in ['Datos', 'Vacío', 'Error']) {
      testWidgets(
        'Skeleton resolves immediately to $result after ${delay}ms without restarting entrance',
        (tester) async {
          var loading = true;
          var taps = 0;
          late StateSetter update;
          await tester.pumpWidget(
            MaterialApp(
              home: StatefulBuilder(
                builder: (context, setState) {
                  update = setState;
                  return PetScreenShell(
                    title: 'Ficha',
                    loading: loading,
                    count: 2,
                    child: StaggerRevealItem(
                      order: 1,
                      child: TextButton(
                        onPressed: loading ? null : () => taps++,
                        child: Text(loading ? 'Skeleton' : result),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
          expect(find.byType(CoverReveal), findsNothing);
          expect(
            tester
                .widget<Opacity>(
                  find
                      .ancestor(
                        of: find.text('Skeleton'),
                        matching: find.byType(Opacity),
                      )
                      .first,
                )
                .opacity,
            1,
          );
          await tester.pump();
          await tester.pump(Duration(milliseconds: delay));
          final previousCover = find.byType(CoverReveal).evaluate().isEmpty
              ? null
              : tester
                    .widget<CoverReveal>(find.byType(CoverReveal))
                    .animation
                    .value;
          update(() => loading = false);
          await tester.pump();
          expect(find.text('Skeleton'), findsNothing);
          expect(find.text(result), findsOneWidget);
          final opacity = tester.widget<Opacity>(
            find
                .ancestor(of: find.text(result), matching: find.byType(Opacity))
                .first,
          );
          expect(opacity.opacity, 1);
          final filter = tester.widget<ImageFiltered>(
            find
                .ancestor(
                  of: find.text(result),
                  matching: find.byType(ImageFiltered),
                )
                .first,
          );
          expect(filter.enabled, isFalse);
          if (previousCover == null) {
            expect(find.byType(CoverReveal), findsNothing);
          } else {
            expect(
              tester
                  .widget<CoverReveal>(find.byType(CoverReveal))
                  .animation
                  .value,
              previousCover,
            );
            await tester.pump(const Duration(milliseconds: 320));
          }
          expect(find.byType(CoverReveal), findsNothing);
          await tester.tap(find.text(result));
          expect(taps, 1);
          update(() => loading = true);
          await tester.pump();
          expect(find.byType(CoverReveal), findsNothing);
          update(() => loading = false);
          await tester.pump();
          expect(
            tester
                .widget<Opacity>(
                  find
                      .ancestor(
                        of: find.text(result),
                        matching: find.byType(Opacity),
                      )
                      .first,
                )
                .opacity,
            1,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  for (final reduced in [false, true]) {
    testWidgets('Cached content retains its first entrance; reduced=$reduced', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduced),
            child: const ContentReveal(
              loading: false,
              child: StaggerRevealItem(order: 0, child: Text('Disponible')),
            ),
          ),
        ),
      );
      final opacity = find.ancestor(
        of: find.text('Disponible'),
        matching: find.byType(Opacity),
      );
      expect(tester.widget<Opacity>(opacity).opacity, reduced ? 1 : 0);
      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(opacity).opacity, 1);
    });
  }
}
