import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/app/secure_route_surface.dart';

void main() {
  testWidgets(
    'Sensitive content waits for protection and releases its lease on disposal',
    (tester) async {
      final acquired = Completer<void>();
      final events = <(String, bool)>[];
      await tester.pumpWidget(
        MaterialApp(
          home: SecureRouteSurface(
            protection: (token, enabled) async {
              events.add((token, enabled));
              if (enabled) await acquired.future;
            },
            child: const Text('private-data'),
          ),
        ),
      );
      expect(find.text('private-data'), findsNothing);
      acquired.complete();
      await tester.pump();
      expect(find.text('private-data'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(events.map((event) => event.$2), [true, false]);
      expect(events.first.$1, events.last.$1);
    },
  );

  testWidgets('Disposed route still releases a late successful acquisition', (
    tester,
  ) async {
    final acquired = Completer<void>();
    final events = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        home: SecureRouteSurface(
          protection: (token, enabled) async {
            events.add(enabled);
            if (enabled) await acquired.future;
          },
          child: const Text('private-data'),
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    acquired.complete();
    await tester.pump();
    expect(events, [true, false]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Failed protection never renders the sensitive child', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SecureRouteSurface(
          protection: (token, enabled) async =>
              throw StateError('native unavailable'),
          child: const Text('private-data'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('private-data'), findsNothing);
    expect(find.text('Reintentar'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
