import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/data_sources/supabase_registration_data_source.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/data_sources/registration_data_source.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/repositories/registration_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/registration_outcome.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/failures/registration_failure.dart';

class MemoryPkceStorage extends GotrueAsyncStorage {
  final _items = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => _items[key];
  @override
  Future<void> setItem({required String key, required String value}) async {
    _items[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _items.remove(key);
  }
}

void main() {
  const callback = 'entrehuellas://login-callback/';
  const headers = {
    'content-type': 'application/json',
    'x-supabase-api-version': '2024-01-01',
  };
  for (final withSession in [false, true]) {
    test(
      'Signup maps confirmation/session=$withSession and sends name/callback correctly',
      () async {
        final httpClient = MockClient((request) async {
          expect(request.url.path, '/auth/v1/signup');
          expect(request.url.queryParameters['redirect_to'], callback);
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['email'], 'a@example.com');
          expect(body['password'], 'fake password');
          expect(body['data'], {'full_name': 'Ana'});
          final user = {
            'id': 'signup-user',
            'aud': 'authenticated',
            'app_metadata': <String, Object?>{},
            'user_metadata': {'full_name': 'Ana'},
            'created_at': '2026-10-07T00:00:00Z',
          };
          return http.Response(
            jsonEncode(
              withSession
                  ? {
                      'access_token': 'fake-access-token',
                      'refresh_token': 'fake-refresh-token',
                      'token_type': 'bearer',
                      'expires_in': 3600,
                      'user': user,
                    }
                  : user,
            ),
            200,
            headers: headers,
          );
        });
        final sdk = SupabaseClient(
          'https://example.supabase.co',
          'sb_publishable_test',
          httpClient: httpClient,
          authOptions: AuthClientOptions(pkceAsyncStorage: MemoryPkceStorage()),
        );
        addTearDown(() async {
          await sdk.dispose();
          httpClient.close();
        });
        final repo = RegistrationRepositoryImpl(
          SupabaseRegistrationDataSource(sdk, redirectUri: callback),
        );
        final outcome = await repo.register(
          name: 'Ana',
          email: 'a@example.com',
          password: 'fake password',
        );
        expect(
          outcome,
          withSession
              ? RegistrationOutcome.authenticated
              : RegistrationOutcome.confirmationRequired,
        );
        expect(sdk.auth.currentSession != null, withSession);
      },
    );
  }
  test('Resend uses signup and the mobile callback', () async {
    final httpClient = MockClient((request) async {
      expect(request.url.path, '/auth/v1/resend');
      expect(request.url.queryParameters['redirect_to'], callback);
      expect(jsonDecode(request.body), containsPair('type', 'signup'));
      expect(jsonDecode(request.body), containsPair('email', 'a@example.com'));
      return http.Response('{}', 200, headers: headers);
    });
    final sdk = SupabaseClient(
      'https://example.supabase.co',
      'sb_publishable_test',
      httpClient: httpClient,
      authOptions: AuthClientOptions(pkceAsyncStorage: MemoryPkceStorage()),
    );
    addTearDown(() async {
      await sdk.dispose();
      httpClient.close();
    });
    await SupabaseRegistrationDataSource(
      sdk,
      redirectUri: callback,
    ).resendConfirmation('a@example.com');
  });
  for (final entry in {
    'weak_password': RegistrationFailureKind.weakPassword,
    'user_already_exists': RegistrationFailureKind.alreadyRegistered,
    'over_email_send_rate_limit': RegistrationFailureKind.rateLimited,
    'unexpected_failure': RegistrationFailureKind.unavailable,
  }.entries) {
    test('SDK ${entry.key} becomes safe domain failure', () async {
      final httpClient = MockClient(
        (_) async => http.Response(
          jsonEncode({'code': entry.key, 'msg': 'private detail'}),
          400,
          headers: headers,
        ),
      );
      final sdk = SupabaseClient(
        'https://example.supabase.co',
        'sb_publishable_test',
        httpClient: httpClient,
        authOptions: AuthClientOptions(pkceAsyncStorage: MemoryPkceStorage()),
      );
      addTearDown(() async {
        await sdk.dispose();
        httpClient.close();
      });
      final repo = RegistrationRepositoryImpl(
        SupabaseRegistrationDataSource(sdk),
      );
      await expectLater(
        repo.register(
          name: 'Ana',
          email: 'a@example.com',
          password: 'fake password',
        ),
        throwsA(
          isA<RegistrationFailure>().having((e) => e.kind, 'kind', entry.value),
        ),
      );
    });
  }
  test('Empty signup user is not treated as successful registration', () async {
    final httpClient = MockClient(
      (_) async => http.Response('{}', 200, headers: headers),
    );
    final sdk = SupabaseClient(
      'https://example.supabase.co',
      'sb_publishable_test',
      httpClient: httpClient,
      authOptions: AuthClientOptions(pkceAsyncStorage: MemoryPkceStorage()),
    );
    addTearDown(() async {
      await sdk.dispose();
      httpClient.close();
    });
    await expectLater(
      SupabaseRegistrationDataSource(sdk).register(
        name: 'Ana',
        email: 'a@example.com',
        password: 'fake password',
      ),
      throwsA(isA<RegistrationSourceFailure>()),
    );
  });
}
