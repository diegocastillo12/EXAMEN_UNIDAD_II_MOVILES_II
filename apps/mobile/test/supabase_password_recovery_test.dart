import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/data_sources/supabase_password_recovery_data_source.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/repositories/password_recovery_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/recovery_access.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/failures/recovery_failure.dart';
import 'supabase_registration_data_source_test.dart' show MemoryPkceStorage;

void main() {
  const headers = {'content-type': 'application/json'};
  const callback = 'entrehuellas://login-callback/';
  final user = {
    'id': 'recovery-user',
    'aud': 'authenticated',
    'role': 'authenticated',
    'email': 'ana@example.com',
    'created_at': '2026-10-08T00:00:00Z',
  };
  final session = {
    'access_token': 'fake-access-token',
    'refresh_token': 'fake-refresh-token',
    'token_type': 'bearer',
    'expires_in': 3600,
    'user': user,
  };

  for (final entry in {
    'weak_password': RecoveryFailureKind.weakPassword,
    'same_password': RecoveryFailureKind.samePassword,
    'session_not_found': RecoveryFailureKind.invalidLink,
  }.entries) {
    test(
      'Update maps SDK ${entry.key} safely and keeps recovery available',
      () async {
        final httpClient = MockClient(
          (request) async => request.method == 'PUT'
              ? http.Response(
                  jsonEncode({
                    'code': entry.key,
                    'error_code': entry.key,
                    'msg': 'private details',
                  }),
                  400,
                  headers: headers,
                )
              : http.Response(jsonEncode(session), 200, headers: headers),
        );
        final sdk = SupabaseClient(
          'https://example.supabase.co',
          'sb_publishable_test',
          httpClient: httpClient,
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        );
        addTearDown(() async {
          await sdk.dispose();
          httpClient.close();
        });
        await sdk.auth.signInWithPassword(
          email: 'ana@example.com',
          password: 'existing',
        );
        // ignore: invalid_use_of_internal_member
        sdk.auth.notifyAllSubscribers(AuthChangeEvent.passwordRecovery);
        final repo = PasswordRecoveryRepositoryImpl(
          SupabasePasswordRecoveryDataSource(sdk),
        );
        await repo.watchAccess().firstWhere(
          (access) => access == RecoveryAccess.ready,
        );
        await expectLater(
          repo.updatePassword('new-password'),
          throwsA(
            isA<RecoveryFailure>().having((f) => f.kind, 'kind', entry.value),
          ),
        );
      },
    );
  }

  for (final cold in [false, true]) {
    test(
      'Real SDK PKCE recovery request/callback/update/logout; cold=$cold',
      () async {
        final requests = <http.Request>[];
        final httpClient = MockClient((request) async {
          requests.add(request);
          switch (request.url.path) {
            case '/auth/v1/recover':
              expect(request.url.queryParameters['redirect_to'], callback);
              final body = jsonDecode(request.body) as Map;
              expect(body['email'], 'ana@example.com');
              expect(body['code_challenge'], isNotEmpty);
              expect(body['code_challenge_method'], 's256');
              return http.Response('{}', 200, headers: headers);
            case '/auth/v1/token':
              expect(request.url.queryParameters['grant_type'], 'pkce');
              expect(jsonDecode(request.body)['auth_code'], 'fake-code');
              return http.Response(jsonEncode(session), 200, headers: headers);
            case '/auth/v1/user':
              expect(request.method, 'PUT');
              expect(jsonDecode(request.body)['password'], '  new password  ');
              return http.Response(jsonEncode(user), 200, headers: headers);
            case '/auth/v1/logout':
              expect(request.url.queryParameters['scope'], 'local');
              return http.Response('{}', 200, headers: headers);
            default:
              fail('Unexpected request ${request.method} ${request.url.path}');
          }
        });
        final sdk = SupabaseClient(
          'https://example.supabase.co',
          'sb_publishable_test',
          httpClient: httpClient,
          authOptions: AuthClientOptions(
            pkceAsyncStorage: MemoryPkceStorage(),
            autoRefreshToken: false,
          ),
        );
        addTearDown(() async {
          await sdk.dispose();
          httpClient.close();
        });
        final source = SupabasePasswordRecoveryDataSource(
          sdk,
          redirectUri: callback,
        );
        final repo = PasswordRecoveryRepositoryImpl(source);
        final statuses = <RecoveryAccess>[];
        StreamSubscription<RecoveryAccess>? subscription;
        if (!cold) subscription = repo.watchAccess().listen(statuses.add);
        await repo.sendCode('ana@example.com');
        await sdk.auth.getSessionFromUrl(Uri.parse('$callback?code=fake-code'));
        // A late listener simulates the SDK processing a link before router mount.
        subscription ??= repo.watchAccess().listen(statuses.add);
        await Future<void>.delayed(Duration.zero);
        expect(statuses.last, RecoveryAccess.ready);
        // Token refresh and userUpdated do not dismiss the reset screen.
        // ignore: invalid_use_of_internal_member
        sdk.auth.notifyAllSubscribers(AuthChangeEvent.tokenRefreshed);
        await Future<void>.delayed(Duration.zero);
        expect(statuses.last, RecoveryAccess.ready);
        await repo.updatePassword('  new password  ');
        await Future<void>.delayed(Duration.zero);
        expect(statuses.last, RecoveryAccess.ready);
        await repo.endRecovery();
        await Future<void>.delayed(Duration.zero);
        expect(statuses.last, RecoveryAccess.idle);
        expect(sdk.auth.currentSession, isNull);
        expect(requests.map((r) => r.url.path), contains('/auth/v1/user'));
        await subscription.cancel();
      },
    );
  }

  test(
    'A normal login session cannot reset a password through this module',
    () async {
      final httpClient = MockClient(
        (_) async => http.Response(jsonEncode(session), 200, headers: headers),
      );
      final sdk = SupabaseClient(
        'https://example.supabase.co',
        'sb_publishable_test',
        httpClient: httpClient,
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      addTearDown(() async {
        await sdk.dispose();
        httpClient.close();
      });
      await sdk.auth.signInWithPassword(
        email: 'ana@example.com',
        password: 'existing',
      );
      final repo = PasswordRecoveryRepositoryImpl(
        SupabasePasswordRecoveryDataSource(sdk),
      );
      expect(await repo.watchAccess().first, RecoveryAccess.idle);
      await expectLater(
        repo.updatePassword('new-password'),
        throwsA(
          isA<RecoveryFailure>().having(
            (f) => f.kind,
            'kind',
            RecoveryFailureKind.invalidLink,
          ),
        ),
      );
    },
  );

  for (final code in [
    'user_not_found',
    'over_email_send_rate_limit',
    'unexpected_failure',
  ]) {
    test('Recovery request safely handles server $code', () async {
      final httpClient = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'code': code,
            'error_code': code,
            'msg': 'private server detail',
          }),
          400,
          headers: headers,
        ),
      );
      final sdk = SupabaseClient(
        'https://example.supabase.co',
        'sb_publishable_test',
        httpClient: httpClient,
        authOptions: AuthClientOptions(
          pkceAsyncStorage: MemoryPkceStorage(),
          autoRefreshToken: false,
        ),
      );
      addTearDown(() async {
        await sdk.dispose();
        httpClient.close();
      });
      final repo = PasswordRecoveryRepositoryImpl(
        SupabasePasswordRecoveryDataSource(sdk),
      );
      if (code == 'user_not_found') {
        await repo.sendCode('ana@example.com');
      } else {
        await expectLater(
          repo.sendCode('ana@example.com'),
          throwsA(
            isA<RecoveryFailure>().having(
              (f) => f.kind,
              'kind',
              code == 'over_email_send_rate_limit'
                  ? RecoveryFailureKind.rateLimited
                  : RecoveryFailureKind.unavailable,
            ),
          ),
        );
      }
    });
  }

  test(
    'Expired callback is safe; a subsequent auth event recovers the stream',
    () async {
      final sdk = SupabaseClient(
        'https://example.supabase.co',
        'sb_publishable_test',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      addTearDown(sdk.dispose);
      final repo = PasswordRecoveryRepositoryImpl(
        SupabasePasswordRecoveryDataSource(sdk),
      );
      final statuses = <RecoveryAccess>[];
      final subscription = repo.watchAccess().listen(statuses.add);
      await Future<void>.delayed(Duration.zero);
      // The Flutter SDK forwards callback errors to this exact stream.
      // ignore: invalid_use_of_internal_member
      sdk.auth.notifyException(
        const AuthException(
          'private details',
          code: 'access_denied',
          statusCode: 'otp_expired',
        ),
        StackTrace.current,
      );
      await Future<void>.delayed(Duration.zero);
      expect(statuses.last, RecoveryAccess.invalid);
      await repo.endRecovery();
      await Future<void>.delayed(Duration.zero);
      expect(statuses.last, RecoveryAccess.idle);
      await subscription.cancel();
    },
  );
}
