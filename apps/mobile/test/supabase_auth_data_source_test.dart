import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/config/app_config.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/social_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/data_sources/supabase_auth_data_source.dart';
import 'package:flutter_application_entrehuellas/features/auth/data/data_sources/auth_access_data_source.dart';

class MemoryPkceStorage extends GotrueAsyncStorage {
  final values = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => values[key];
  @override
  Future<void> setItem({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    values.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SupabaseClient client;

  setUp(() {
    client = SupabaseClient(
      'https://example.supabase.co',
      'sb_publishable_test',
      authOptions: AuthClientOptions(pkceAsyncStorage: MemoryPkceStorage()),
    );
  });
  tearDown(() => client.dispose());

  for (final provider in SocialProvider.values) {
    test(
      'OAuth launches ${provider.name} with the mobile callback without a session',
      () async {
        Uri? launched;
        const channel = MethodChannel('plugins.flutter.io/url_launcher');
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'launch') {
            launched = Uri.parse((call.arguments as Map)['url'] as String);
            return true;
          }
          return false;
        });
        addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
        await SupabaseAuthDataSource(
          client,
          redirectUri: AppConfig.authRedirectUri,
        ).signInWithProvider(provider);
        expect(launched?.path, '/auth/v1/authorize');
        expect(launched?.queryParameters['provider'], provider.name);
        expect(launched?.queryParameters['code_challenge'], isNotEmpty);
        expect(launched?.queryParameters['code_challenge_method'], 's256');
        expect(
          launched?.queryParameters['redirect_to'],
          AppConfig.authRedirectUri,
        );
        expect(client.auth.currentSession, isNull);
      },
    );
  }

  test('Facebook launch failure is safe and can be retried', () async {
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    var canLaunch = false;
    messenger.setMockMethodCallHandler(channel, (_) async => canLaunch);
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final source = SupabaseAuthDataSource(
      client,
      redirectUri: AppConfig.authRedirectUri,
    );
    await expectLater(
      source.signInWithProvider(SocialProvider.facebook),
      throwsA(
        isA<AccessSourceFailure>().having(
          (error) => error.kind,
          'kind',
          AccessSourceFailureKind.unavailable,
        ),
      ),
    );
    canLaunch = true;
    await source.signInWithProvider(SocialProvider.facebook);
    expect(client.auth.currentSession, isNull);
  });

  test(
    'Password adapter sends credentials to Auth and emits the returned identity',
    () async {
      final httpClient = MockClient((request) async {
        expect(request.url.path, '/auth/v1/token');
        expect(request.url.queryParameters['grant_type'], 'password');
        expect(
          jsonDecode(request.body),
          containsPair('email', 'test@example.com'),
        );
        expect(
          jsonDecode(request.body),
          containsPair('password', 'fake password'),
        );
        return http.Response(
          jsonEncode({
            'access_token': 'fake-access-token',
            'refresh_token': 'fake-refresh-token',
            'token_type': 'bearer',
            'expires_in': 3600,
            'user': {
              'id': 'password-user',
              'aud': 'authenticated',
              'app_metadata': <String, Object?>{},
              'user_metadata': <String, Object?>{},
              'created_at': '2026-10-07T00:00:00Z',
            },
          }),
          200,
          headers: {
            'content-type': 'application/json',
            'x-supabase-api-version': '2024-01-01',
          },
        );
      });
      final sdk = SupabaseClient(
        'https://example.supabase.co',
        'sb_publishable_test',
        httpClient: httpClient,
      );
      addTearDown(() async {
        await sdk.dispose();
        httpClient.close();
      });
      final source = SupabaseAuthDataSource(sdk);
      await source.signInWithPassword(
        email: 'test@example.com',
        password: 'fake password',
      );
      expect((await source.watchSession().first)?.userId, 'password-user');
    },
  );

  for (final entry in {
    'invalid_credentials': AccessSourceFailureKind.rejected,
    'email_not_confirmed': AccessSourceFailureKind.emailNotConfirmed,
  }.entries) {
    test(
      'Auth error ${entry.key} becomes the matching safe source failure',
      () async {
        final httpClient = MockClient(
          (_) async => http.Response(
            jsonEncode({'code': entry.key, 'msg': 'secret SDK detail'}),
            400,
            headers: {
              'content-type': 'application/json',
              'x-supabase-api-version': '2024-01-01',
            },
          ),
        );
        final sdk = SupabaseClient(
          'https://example.supabase.co',
          'sb_publishable_test',
          httpClient: httpClient,
        );
        addTearDown(() async {
          await sdk.dispose();
          httpClient.close();
        });
        await expectLater(
          SupabaseAuthDataSource(
            sdk,
          ).signInWithPassword(email: 'test@example.com', password: 'fake'),
          throwsA(
            isA<AccessSourceFailure>().having(
              (failure) => failure.kind,
              'kind',
              entry.value,
            ),
          ),
        );
        expect(sdk.auth.currentSession, isNull);
      },
    );
  }

  test('Adapter emits signed out when the SDK has no session', () async {
    expect(await SupabaseAuthDataSource(client).watchSession().first, isNull);
  });

  test(
    'Adapter projects restored SDK identity and subsequent auth events',
    () async {
      final source = SupabaseAuthDataSource(client);
      final nextIdentity = source
          .watchSession()
          .where((dto) => dto != null)
          .first;
      // Local SDK state only: this does not authenticate or call the backend.
      await client.auth.setInitialSession(
        jsonEncode({
          'access_token': 'fake-access-token',
          'refresh_token': 'fake-refresh-token',
          'token_type': 'bearer',
          'user': {
            'id': 'user-1',
            'aud': 'authenticated',
            'app_metadata': <String, Object?>{},
            'user_metadata': <String, Object?>{},
            'created_at': '2026-10-07T00:00:00Z',
          },
        }),
      );
      expect((await nextIdentity)?.userId, 'user-1');
      expect((await source.watchSession().first)?.userId, 'user-1');
    },
  );
}
