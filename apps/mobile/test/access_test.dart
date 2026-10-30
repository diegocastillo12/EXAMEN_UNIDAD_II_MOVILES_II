import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/social_provider.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/failures/access_failure.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/repositories/access_repository.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/use_cases/sign_in.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/presentation/view_models/login_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/data_sources/auth_access_data_source.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/repositories/access_repository_impl.dart';

final class FakeAccess implements AccessRepository {
  var calls = 0;
  String? email;
  String? password;
  SocialProvider? provider;
  Completer<void>? pending;
  Object? failure;
  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    calls++;
    this.email = email;
    this.password = password;
    if (failure != null) throw failure!;
    await pending?.future;
  }

  @override
  Future<void> signInWithProvider(SocialProvider provider) async {
    this.provider = provider;
  }

  @override
  Future<void> signOut() async {
    calls++;
  }
}

final class FailingAccessSource implements AuthAccessDataSource {
  FailingAccessSource(this.failure);
  final Object failure;
  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async => throw failure;
  @override
  Future<void> signInWithProvider(SocialProvider provider) async =>
      throw failure;
  @override
  Future<void> signOut() async => throw failure;
}

void main() {
  test(
    'Email confirmation remains distinct from rejected credentials in the repository',
    () async {
      final repo = AccessRepositoryImpl(
        FailingAccessSource(
          const AccessSourceFailure(AccessSourceFailureKind.emailNotConfirmed),
        ),
      );
      await expectLater(
        repo.signInWithPassword(
          email: 'user@example.com',
          password: 'password',
        ),
        throwsA(
          isA<AccessFailure>().having(
            (failure) => failure.kind,
            'kind',
            AccessFailureKind.emailNotConfirmed,
          ),
        ),
      );
    },
  );
  test(
    'Invalid form data never reaches auth; password whitespace is preserved',
    () async {
      final repository = FakeAccess();
      final signIn = SignIn(repository);
      await expectLater(
        signIn.withPassword(email: 'invalid', password: 'value'),
        throwsA(isA<AccessFailure>()),
      );
      await expectLater(
        signIn.withPassword(email: 'user@example.com', password: ''),
        throwsA(isA<AccessFailure>()),
      );
      expect(repository.calls, 0);
      await signIn.withPassword(
        email: ' user@example.com ',
        password: ' password with spaces ',
      );
      expect(repository.email, 'user@example.com');
      expect(repository.password, ' password with spaces ');
    },
  );

  test(
    'ViewModel blocks duplicate submits and restores controls after failure',
    () async {
      final repository = FakeAccess()..pending = Completer<void>();
      final container = ProviderContainer(
        overrides: [accessRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(loginViewModelProvider, (_, _) {});
      addTearDown(subscription.close);
      final vm = container.read(loginViewModelProvider.notifier);
      final first = vm.password('user@example.com', 'password');
      await vm.password('user@example.com', 'password');
      expect(repository.calls, 1);
      expect(container.read(loginViewModelProvider).isBusy, isTrue);
      repository.pending!.completeError(
        const AccessFailure(AccessFailureKind.rejected),
      );
      await first;
      expect(container.read(loginViewModelProvider).isBusy, isFalse);
      expect(container.read(loginViewModelProvider).isError, isTrue);
      repository.pending = null;
      await vm.password('user@example.com', 'password');
      expect(container.read(loginViewModelProvider).isError, isFalse);
      expect(repository.calls, 2);
    },
  );

  test('Starting Google OAuth does not claim a completed session', () async {
    final repository = FakeAccess();
    final container = ProviderContainer(
      overrides: [accessRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(loginViewModelProvider, (_, _) {});
    addTearDown(subscription.close);
    await container
        .read(loginViewModelProvider.notifier)
        .social(SocialProvider.google);
    expect(repository.provider, SocialProvider.google);
    expect(
      container.read(loginViewModelProvider).message,
      contains('navegador'),
    );
    expect(container.read(loginViewModelProvider).isBusy, isFalse);
  });

  test(
    'Auth failure mapping is typed and never includes SDK messages',
    () async {
      for (final failure in [
        const AccessSourceFailure(AccessSourceFailureKind.rejected),
        StateError('private secret'),
      ]) {
        final repo = AccessRepositoryImpl(FailingAccessSource(failure));
        await expectLater(
          repo.signInWithPassword(email: 'user@example.com', password: 'pass'),
          throwsA(isA<AccessFailure>()),
        );
        await expectLater(
          repo.signInWithProvider(SocialProvider.google),
          throwsA(isA<AccessFailure>()),
        );
        await expectLater(repo.signOut(), throwsA(isA<AccessFailure>()));
      }
    },
  );

  test(
    'Disposing the login view during a request does not write to disposed state',
    () async {
      final repository = FakeAccess()..pending = Completer<void>();
      final container = ProviderContainer(
        overrides: [accessRepositoryProvider.overrideWithValue(repository)],
      );
      container.listen(loginViewModelProvider, (_, _) {});
      final request = container
          .read(loginViewModelProvider.notifier)
          .password('user@example.com', 'password');
      container.dispose();
      repository.pending!.complete();
      await request;
    },
  );
}
