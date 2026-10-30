import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';

final class ObservedRepository implements AuthRepository {
  var subscriptions = 0;
  var cancellations = 0;
  late final controller = StreamController<AuthSession?>(
    onListen: () {
      subscriptions++;
    },
    onCancel: () {
      cancellations++;
    },
  );

  @override
  Stream<AuthSession?> watchSession() => controller.stream;
}

void main() {
  test(
    'Unconfigured UI does not attempt to resolve or observe a repository',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(authViewModelProvider);
      expect(state.startup.isReady, isFalse);
      expect(state.session.hasError, isFalse);
      expect(state.session.requireValue, isNull);
    },
  );

  test(
    'ViewModel exposes loading, identity, errors and recovery; disposal cancels',
    () async {
      final repository = ObservedRepository();
      final container = ProviderContainer(
        overrides: [
          startupStateProvider.overrideWithValue(
            const StartupState(StartupStatus.ready),
          ),
          authRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(repository.controller.close);
      Future<void> flushEvents() async {
        await Future<void>.delayed(Duration.zero);
        await container.pump();
      }

      final listener = container.listen(authViewModelProvider, (_, _) {});
      expect(container.read(authViewModelProvider).session.isLoading, isTrue);
      await flushEvents();
      expect(repository.subscriptions, 1);
      repository.controller.add(const AuthSession(userId: 'user-1'));
      await flushEvents();
      expect(
        container.read(authViewModelProvider).session.requireValue?.userId,
        'user-1',
      );
      repository.controller.addError(const AuthFailure.sessionObservation());
      await flushEvents();
      expect(container.read(authViewModelProvider).session.hasError, isTrue);
      repository.controller.add(null);
      await flushEvents();
      expect(
        container.read(authViewModelProvider).session.requireValue,
        isNull,
      );
      expect(repository.subscriptions, 1);
      listener.close();
      container.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(repository.cancellations, 1);
    },
  );
}
