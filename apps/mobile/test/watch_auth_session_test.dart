import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/use_cases/watch_auth_session.dart';

final class SessionRepository implements AuthRepository {
  SessionRepository(this.events);

  final Stream<AuthSession?> events;

  @override
  Stream<AuthSession?> watchSession() => events;
}

void main() {
  test(
    'Identity observation ignores duplicates and retains real transitions',
    () async {
      final repository = SessionRepository(
        Stream.fromIterable([
          null,
          null,
          const AuthSession(userId: 'user-1'),
          const AuthSession(userId: 'user-1'),
          const AuthSession(userId: 'user-2'),
          null,
          const AuthSession(userId: 'user-1'),
        ]),
      );
      expect(await WatchAuthSession(repository)().toList(), [
        null,
        const AuthSession(userId: 'user-1'),
        const AuthSession(userId: 'user-2'),
        null,
        const AuthSession(userId: 'user-1'),
      ]);
    },
  );

  test(
    'Observation failures propagate instead of becoming signed out',
    () async {
      final failure = StateError('Observation unavailable');
      final repository = SessionRepository(Stream.error(failure));
      await expectLater(
        WatchAuthSession(repository)(),
        emitsError(same(failure)),
      );
    },
  );

  test('The same identity after an error recovers observation', () async {
    final controller = StreamController<AuthSession?>();
    final failure = StateError('Temporarily unavailable');
    final result = expectLater(
      WatchAuthSession(SessionRepository(controller.stream))(),
      emitsInOrder([
        const AuthSession(userId: 'user-1'),
        emitsError(same(failure)),
        const AuthSession(userId: 'user-1'),
        null,
        emitsError(same(failure)),
        null,
        emitsDone,
      ]),
    );
    controller.add(const AuthSession(userId: 'user-1'));
    controller.addError(failure);
    controller.add(const AuthSession(userId: 'user-1'));
    controller.add(null);
    controller.addError(failure);
    controller.add(null);
    await controller.close();
    await result;
  });

  test('Independent subscriptions do not share deduplication state', () async {
    final stream = WatchAuthSession(
      SessionRepository(
        Stream.fromIterable([
          const AuthSession(userId: 'user-1'),
          const AuthSession(userId: 'user-1'),
        ]),
      ),
    )();
    final results = await Future.wait([stream.toList(), stream.toList()]);
    expect(results, [
      [const AuthSession(userId: 'user-1')],
      [const AuthSession(userId: 'user-1')],
    ]);
  });
}
