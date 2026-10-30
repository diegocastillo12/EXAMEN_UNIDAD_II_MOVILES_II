import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/cover_reveal.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/domain/entities/alert_preferences.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/domain/failures/preference_failure.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/presentation/screens/alert_preferences_screen.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/providers/alert_preference_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/domain/entities/interest_zone.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/domain/failures/zone_failure.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/presentation/screens/interest_zones_screen.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/providers/interest_zone_providers.dart';

import 'app_test.dart' show FakeAuthRepository;
import 'interest_zones_test.dart' show FakeZones, zone;
import 'support/fake_alert_preferences.dart';

void main() {
  for (final preferences in [true, false]) {
    for (final delay in [50, 2000]) {
      for (final result in ['data', 'empty', 'error']) {
        for (final reduced in [false, true]) {
          testWidgets(
            '${preferences ? 'Preferences' : 'Locations'} keeps entrance on $result after ${delay}ms; reduced=$reduced',
            (tester) async {
              final auth = FakeAuthRepository()
                ..current = const AuthSession(userId: 'one');
              final alerts = FakeAlertPreferences()
                ..pendingRead = Completer<AlertPreferences?>();
              final zones = FakeZones()
                ..pendingRead = Completer<List<InterestZone>>();
              final container = ProviderContainer(
                overrides: [
                  authRepositoryProvider.overrideWithValue(auth),
                  alertPreferenceRepositoryProvider.overrideWithValue(alerts),
                  interestZoneRepositoryProvider.overrideWithValue(zones),
                ],
              );
              await tester.pumpWidget(
                UncontrolledProviderScope(
                  container: container,
                  child: MaterialApp(
                    home: MediaQuery(
                      data: MediaQueryData(disableAnimations: reduced),
                      child: preferences
                          ? const AlertPreferencesScreen()
                          : const InterestZonesScreen(),
                    ),
                  ),
                ),
              );
              final entrance = tester.state(find.byType(ContentReveal));
              expect(find.byType(CoverReveal), findsNothing);
              await tester.pump(Duration(milliseconds: delay));
              if (preferences) {
                if (result == 'error') {
                  alerts.pendingRead!.completeError(
                    const PreferenceFailure(PreferenceFailureKind.unavailable),
                  );
                } else {
                  alerts.pendingRead!.complete(
                    result == 'empty'
                        ? null
                        : const AlertPreferences(ownerId: 'one', version: 1),
                  );
                }
              } else if (result == 'error') {
                zones.pendingRead!.completeError(
                  const ZoneFailure(ZoneFailureKind.network),
                );
              } else {
                zones.pendingRead!.complete(result == 'empty' ? [] : [zone]);
              }
              for (var frame = 0; frame < 6; frame++) {
                await tester.pump();
              }
              expect(tester.state(find.byType(ContentReveal)), same(entrance));
              expect(find.byType(CoverReveal), findsNothing);
              final target = result == 'error'
                  ? find.text('Reintentar')
                  : preferences
                  ? find.text('Recibir alertas')
                  : result == 'empty'
                  ? find.text('Todavía no tienes ubicaciones de interés.')
                  : find.text('Parque');
              expect(target, findsOneWidget);
              for (final opacity in tester.widgetList<Opacity>(
                find.ancestor(of: target, matching: find.byType(Opacity)),
              )) {
                expect(opacity.opacity, 1);
              }
              expect(tester.takeException(), isNull);
              await tester.pumpWidget(const SizedBox.shrink());
              container.dispose();
              await auth.controller.close();
            },
          );
        }
      }
    }
  }
}
