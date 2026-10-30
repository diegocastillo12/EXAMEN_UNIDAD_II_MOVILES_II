import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/data/data_sources/supabase_alert_preference_data_source.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/data/repositories/alert_preference_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/domain/entities/alert_preferences.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/domain/failures/preference_failure.dart';
import 'package:flutter_application_entrehuellas/features/alert_preferences/domain/use_cases/manage_alert_preferences.dart';

void main() {
  test(
    'Real SDK uses account projection/RPC version, distinguishes absence/failure and sanitizes errors',
    () async {
      var calls = 0;
      var absent = true;
      String? errorCode;
      const headers = {'content-type': 'application/json'};
      final row = {
        'owner_id': 'owner',
        'version': 1,
        'enabled': true,
        'lost_pets': true,
        'found_pets': false,
        'case_updates': true,
        'in_app': false,
        'push': true,
      };
      final mock = MockClient((request) async {
        if (request.url.path == '/auth/v1/token') {
          return http.Response(
            jsonEncode({
              'access_token':
                  'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJvd25lciIsImV4cCI6MjAwMDAwMDAwMH0.fake',
              'refresh_token': 'fake',
              'token_type': 'bearer',
              'expires_in': 3600,
              'user': {
                'id': 'owner',
                'aud': 'authenticated',
                'app_metadata': {},
                'user_metadata': {},
                'created_at': '2026-10-10T00:00:00Z',
              },
            }),
            200,
            headers: headers,
            request: request,
          );
        }
        calls++;
        if (request.method == 'GET') {
          expect(request.url.path, '/rest/v1/alert_preferences');
          expect(request.url.queryParameters['owner_id'], 'eq.owner');
          expect(
            request.url.queryParameters['select'],
            'owner_id,version,enabled,lost_pets,found_pets,case_updates,in_app,push',
          );
          if (errorCode == null) {
            return http.Response(
              jsonEncode(absent ? [] : [row]),
              200,
              headers: headers,
              request: request,
            );
          }
        } else {
          expect(request.url.path, '/rest/v1/rpc/save_alert_preferences');
          expect(jsonDecode(request.body), {
            'p_expected_version': 0,
            'p_enabled': true,
            'p_lost_pets': true,
            'p_found_pets': false,
            'p_case_updates': true,
            'p_in_app': false,
            'p_push': true,
          });
          if (errorCode == null) {
            return http.Response(
              jsonEncode(row),
              200,
              headers: headers,
              request: request,
            );
          }
        }
        return http.Response(
          jsonEncode({
            'code': errorCode,
            'message': 'PRIVATE TOKEN sdk details',
          }),
          409,
          headers: headers,
          request: request,
        );
      });
      final client = SupabaseClient(
        'https://example.test',
        'public-test-key',
        httpClient: mock,
      );
      addTearDown(client.dispose);
      final repository = AlertPreferenceRepositoryImpl(
        SupabaseAlertPreferenceDataSource(client),
      );
      final read = ReadAlertPreferences(repository);
      await expectLater(
        read('owner'),
        throwsA(
          isA<PreferenceFailure>().having(
            (e) => e.kind,
            'kind',
            PreferenceFailureKind.signedOut,
          ),
        ),
      );
      expect(calls, 0);
      await client.auth.signInWithPassword(
        email: 'test@example.test',
        password: 'fake',
      );
      expect((await read('owner')).version, 0);
      absent = false;
      expect((await read('owner')).push, true);
      const draft = AlertPreferences(
        ownerId: 'owner',
        enabled: true,
        foundPets: false,
        inApp: false,
        push: true,
      );
      expect((await SaveAlertPreferences(repository)(draft)).version, 1);
      errorCode = '40001';
      await expectLater(
        repository.save(draft),
        throwsA(
          isA<PreferenceFailure>().having(
            (e) => e.kind,
            'kind',
            PreferenceFailureKind.conflict,
          ),
        ),
      );
      errorCode = '42501';
      await expectLater(
        read('owner'),
        throwsA(
          isA<PreferenceFailure>().having(
            (e) => e.kind,
            'kind',
            PreferenceFailureKind.unavailable,
          ),
        ),
      );
      final before = calls;
      await expectLater(read('other'), throwsA(isA<PreferenceFailure>()));
      expect(calls, before);
    },
  );
}
