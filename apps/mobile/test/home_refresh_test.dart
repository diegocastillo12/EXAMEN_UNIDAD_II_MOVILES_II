import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/pull_to_refresh.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/state/home_view_state.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/view_models/home_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/view_models/profile_view_model.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/widgets/profile_avatar.dart';
import 'support/fake_profile.dart';

void main() {
  testWidgets('Profile refresh makes a real read and retains header initials', (
    tester,
  ) async {
    final repo = FakeProfile();
    final container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(repo),
        profileSessionProvider.overrideWith(
          (_) => Stream.value(const AuthSession(userId: 'one')),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: ProfileAvatar())),
      ),
    );
    await tester.pumpAndSettle();
    expect(repo.reads, 1);
    expect(find.text('A'), findsOneWidget);
    repo.pendingRead = Completer<void>();
    container.read(profileViewModelProvider.notifier).retry();
    await tester.pump();
    expect(repo.reads, 2);
    expect(find.text('A'), findsOneWidget);
    repo.pendingRead!.complete();
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets(
    'Home pull awaits work, blocks duplicates and keeps section targets',
    (tester) async {
      var homeCalls = 0;
      var exploreCalls = 0;
      final pending = Completer<void>();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: HomeScreen(
                profileAvatar: const SizedBox.square(dimension: 48),
                onHomeRefresh: () async {
                  homeCalls++;
                  await pending.future;
                },
                exploreContent: PullToRefreshTarget(
                  onRefresh: () async => exploreCalls++,
                  child: const SizedBox(height: 100),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.dragFrom(const Offset(400, 150), const Offset(0, 400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
      expect(homeCalls, 1);
      final refreshing = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Actualizando contenido',
      );
      expect(refreshing, findsOneWidget);
      await tester.dragFrom(const Offset(400, 150), const Offset(0, 400));
      await tester.pump(const Duration(milliseconds: 600));
      expect(homeCalls, 1);
      pending.complete();
      await tester.pumpAndSettle();
      expect(refreshing, findsNothing);
      await tester.tap(find.byTooltip('Explorar'));
      await tester.pumpAndSettle();
      await tester.dragFrom(const Offset(400, 150), const Offset(0, 400));
      await tester.pumpAndSettle();
      expect(exploreCalls, 1);
      expect(homeCalls, 1);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'Home refresh sanitizes failure, retries and ignores late section errors',
    () async {
      final container = ProviderContainer();
      final subscription = container.listen(homeViewModelProvider, (_, _) {});
      addTearDown(subscription.close);
      addTearDown(container.dispose);
      final model = container.read(homeViewModelProvider.notifier);
      await model.refresh(
        () async => throw StateError('sensitive backend detail'),
      );
      expect(container.read(homeViewModelProvider).refreshError, isTrue);
      await model.refresh(() async {});
      expect(container.read(homeViewModelProvider).refreshError, isFalse);
      final pending = Completer<void>();
      final refresh = model.refresh(() => pending.future);
      model.select(HomeSection.pets);
      pending.completeError(StateError('late failure'));
      await refresh;
      expect(container.read(homeViewModelProvider).section, HomeSection.pets);
      expect(container.read(homeViewModelProvider).refreshError, isFalse);
    },
  );
}
