import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/models/auth_session_dto.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/failures/auth_failure.dart';

final class FakeRemote implements AuthRemoteDataSource {
  FakeRemote(this.events);
  final Stream<AuthSessionDto?> events;

  @override
  Stream<AuthSessionDto?> watchSession() => events;
}

final class ThrowingRemote implements AuthRemoteDataSource {
  @override
  Stream<AuthSessionDto?> watchSession() => throw StateError('SDK credentials');
}

void main() {
  test(
    'Repository maps remote sessions and logout to domain identities',
    () async {
      final repo = AuthRepositoryImpl(
        FakeRemote(
          Stream.fromIterable([
            null,
            const AuthSessionDto(userId: 'user-1'),
            null,
          ]),
        ),
      );
      expect(await repo.watchSession().toList(), [
        null,
        const AuthSession(userId: 'user-1'),
        null,
      ]);
    },
  );

  test(
    'Stream errors become safe domain failures; observation continues',
    () async {
      final controller = StreamController<AuthSessionDto?>();
      final repo = AuthRepositoryImpl(FakeRemote(controller.stream));
      final result = expectLater(
        repo.watchSession(),
        emitsInOrder([
          const AuthSession(userId: 'user-1'),
          emitsError(isA<AuthFailure>()),
          null,
          emitsDone,
        ]),
      );
      controller.add(const AuthSessionDto(userId: 'user-1'));
      controller.addError(StateError('secret from SDK'));
      controller.add(null);
      await controller.close();
      await result;
    },
  );

  test('Synchronous adapter errors also become a stream failure', () async {
    final repo = AuthRepositoryImpl(ThrowingRemote());
    await expectLater(repo.watchSession(), emitsError(isA<AuthFailure>()));
  });

  test(
    'Cancelling repository observation cancels the source subscription',
    () async {
      var cancelled = false;
      final controller = StreamController<AuthSessionDto?>(
        onCancel: () {
          cancelled = true;
        },
      );
      final subscription = AuthRepositoryImpl(
        FakeRemote(controller.stream),
      ).watchSession().listen((_) {});
      await subscription.cancel();
      expect(cancelled, isTrue);
      await controller.close();
    },
  );
}
