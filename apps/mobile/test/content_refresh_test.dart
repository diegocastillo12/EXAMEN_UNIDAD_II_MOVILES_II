import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/content_refresh.dart';

void main() {
  testWidgets('Refresh preserves child state at start and completion', (
    tester,
  ) async {
    var refreshing = false;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (_, change) {
            update = change;
            return ContentRefresh(
              refreshing: refreshing,
              label: 'Actualizando mascotas',
              child: const _StateProbe(),
            );
          },
        ),
      ),
    );
    final original = tester.state(find.byType(_StateProbe));
    update(() => refreshing = true);
    await tester.pump();
    expect(identical(tester.state(find.byType(_StateProbe)), original), isTrue);
    update(() => refreshing = false);
    await tester.pumpAndSettle();
    expect(identical(tester.state(find.byType(_StateProbe)), original), isTrue);
  });
  for (final reduced in [false, true]) {
    testWidgets(
      'Refresh retains geometry, content semantics and actions; reduced=$reduced',
      (tester) async {
        var refreshing = false;
        var taps = 0;
        late StateSetter update;
        final contentKey = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: StatefulBuilder(
                builder: (context, change) {
                  update = change;
                  return ContentRefresh(
                    refreshing: refreshing,
                    label: 'Actualizando casos',
                    child: SizedBox(
                      key: contentKey,
                      width: 240,
                      height: 100,
                      child: TextButton(
                        onPressed: () => taps++,
                        child: const Text('Abrir ficha'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        final before = tester.getRect(find.byKey(contentKey));
        update(() => refreshing = true);
        await tester.pump();
        expect(tester.getRect(find.byKey(contentKey)), before);
        expect(find.text('Abrir ficha'), findsOneWidget);
        final semantics = tester.ensureSemantics();
        expect(find.bySemanticsLabel('Actualizando casos'), findsOneWidget);
        expect(find.bySemanticsLabel('Abrir ficha'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 1500));
        expect(tester.getRect(find.byKey(contentKey)), before);
        expect(tester.hasRunningAnimations, !reduced);
        await tester.tap(find.text('Abrir ficha'));
        expect(taps, 1);
        update(() => refreshing = false);
        await tester.pumpAndSettle();
        expect(tester.hasRunningAnimations, isFalse);
        semantics.dispose();
      },
    );
  }
}

class _StateProbe extends StatefulWidget {
  const _StateProbe();
  @override
  State<_StateProbe> createState() => _StateProbeState();
}

class _StateProbeState extends State<_StateProbe> {
  @override
  Widget build(BuildContext context) => const Text('Ficha conservada');
}
