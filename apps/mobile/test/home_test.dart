import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/liquid_navigation.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/cover_reveal.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/state/home_view_state.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/view_models/profile_exit_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/repositories/access_repository.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/social_provider.dart';

class HomeAccess implements AccessRepository {
  int calls = 0;
  Completer<void>? pending;
  bool fail = false;
  @override
  Future<void> signOut() async {
    calls++;
    await pending?.future;
    if (fail) throw StateError('sensitive backend detail');
  }

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {}
  @override
  Future<void> signInWithProvider(SocialProvider provider) async {}
}

void main() {
  for (final reduced in [false, true]) {
    testWidgets(
      'Navigation keeps sliding through Explore with floating map action; reduced=$reduced',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(disableAnimations: reduced),
                child: const HomeScreen(
                  profileAvatar: SizedBox.square(dimension: 48),
                  petsContent: SizedBox(height: 100),
                  exploreContent: SizedBox(height: 100),
                  exploreFloatingAction: Text('Mapa'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final navigationState = tester.state(find.byType(LiquidNavigation));
        final indicator = find.byKey(
          const ValueKey('navigation-active-indicator'),
        );
        for (final label in [
          'Explorar',
          'Mis mascotas',
          'Explorar',
          'Inicio',
        ]) {
          final start = tester.getCenter(indicator).dx;
          final target = tester.getCenter(find.byTooltip(label)).dx;
          await tester.tap(find.byTooltip(label));
          await tester.pump();
          expect(
            tester.state(find.byType(LiquidNavigation)),
            same(navigationState),
          );
          expect(
            find.text('Mapa'),
            label == 'Explorar' ? findsOneWidget : findsNothing,
          );
          if (reduced) {
            expect(tester.getCenter(indicator).dx, closeTo(target, 1));
          } else {
            expect(tester.getCenter(indicator).dx, closeTo(start, 1));
            await tester.pump(const Duration(milliseconds: 160));
            expect(
              tester.getCenter(indicator).dx,
              allOf(
                greaterThan(start < target ? start : target),
                lessThan(start > target ? start : target),
              ),
            );
          }
          await tester.pumpAndSettle();
          expect(tester.getCenter(indicator).dx, closeTo(target, 1));
        }
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Home keeps navigation animation when switching sections; reduced=$reduced',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(disableAnimations: reduced),
                child: const HomeScreen(
                  profileAvatar: SizedBox.square(dimension: 48),
                  petsContent: SizedBox(height: 100),
                  exploreContent: SizedBox(height: 100),
                ),
              ),
            ),
          ),
        );
        expect(find.byType(CoverReveal), findsNothing);
        await tester.pump(const Duration(milliseconds: 160));
        expect(find.byType(CoverReveal), findsNothing);
        await tester.pumpAndSettle();
        final indicator = find.byKey(
          const ValueKey('navigation-active-indicator'),
        );
        final animation = find.descendant(
          of: find.byType(LiquidNavigation),
          matching: find.byType(TweenAnimationBuilder<double>),
        );
        final animationState = tester.state(animation);
        final start = tester.getRect(indicator);
        final target = tester.getCenter(find.byTooltip('Mis mascotas')).dx;
        await tester.tap(find.byTooltip('Mis mascotas'));
        await tester.pump();
        expect(tester.state(animation), same(animationState));
        if (reduced) {
          expect(tester.getRect(indicator).center.dx, closeTo(target, 1));
        } else {
          expect(tester.getRect(indicator).left, closeTo(start.left, 1));
          await tester.pump(const Duration(milliseconds: 160));
          final midway = tester.getRect(indicator);
          expect(midway.left, greaterThan(start.left));
          expect(midway.center.dx, lessThan(target));
          await tester.tap(find.byTooltip('Explorar'));
          await tester.pump();
          expect(tester.getRect(indicator).left, closeTo(midway.left, 1));
        }
        await tester.pumpAndSettle();
        expect(tester.state(animation), same(animationState));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Active indicator slides and retargets; reduced=$reduced', (
      tester,
    ) async {
      var selected = HomeSection.home;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduced),
            child: Scaffold(
              body: StatefulBuilder(
                builder: (context, update) => LiquidNavigation(
                  selected: selected,
                  onSelect: (section) => update(() => selected = section),
                  onReport: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      final indicator = find.byKey(
        const ValueKey('navigation-active-indicator'),
      );
      final start = tester.getRect(indicator);
      final target = tester.getCenter(find.byTooltip('Mis mascotas')).dx;
      await tester.tap(find.byTooltip('Mis mascotas'));
      await tester.pump();
      if (reduced) {
        expect(tester.getRect(indicator).center.dx, closeTo(target, 1));
      } else {
        expect(tester.getRect(indicator).left, closeTo(start.left, 1));
        await tester.pump(const Duration(milliseconds: 160));
        final midway = tester.getRect(indicator);
        expect(midway.left, greaterThan(start.left));
        expect(midway.center.dx, lessThan(target));
        await tester.tap(find.byTooltip('Inicio'));
        await tester.pump();
        expect(tester.getRect(indicator).left, closeTo(midway.left, 1));
        await tester.pumpAndSettle();
        expect(tester.getRect(indicator).left, closeTo(start.left, 1));
      }
      expect(tester.takeException(), isNull);
    });
  }
  test(
    'Home logout blocks duplicates, sanitizes errors and can retry',
    () async {
      final access = HomeAccess()
        ..pending = Completer<void>()
        ..fail = true;
      final container = ProviderContainer(
        overrides: [accessRepositoryProvider.overrideWithValue(access)],
      );
      final subscription = container.listen(
        profileExitViewModelProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      addTearDown(container.dispose);
      final model = container.read(profileExitViewModelProvider.notifier);
      final logout = model.signOut();
      await model.signOut();
      expect(access.calls, 1);

      access.pending!.complete();
      await logout;
      expect(container.read(profileExitViewModelProvider).isLoading, false);
      expect(
        container.read(profileExitViewModelProvider).error,
        isNot(contains('sensitive')),
      );
      access.fail = false;
      await model.signOut();
      expect(access.calls, 2);
      expect(container.read(profileExitViewModelProvider).error, isNull);
    },
  );

  for (final small in [false, true]) {
    testWidgets('Navigation remains usable; small=$small', (tester) async {
      tester.view.physicalSize = small
          ? const Size(320, 350)
          : const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [accessRepositoryProvider.overrideWithValue(HomeAccess())],
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: small ? const Size(320, 350) : const Size(390, 844),
                textScaler: TextScaler.linear(small ? 2 : 1),
                disableAnimations: small,
              ),
              child: const HomeScreen(
                profileAvatar: SizedBox(width: 48, height: 48),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Explorar'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('La búsqueda de casos aún no está disponible.'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Mis mascotas'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('El registro de mascotas aún no está disponible.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
