import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/data/data_sources/supabase_interest_zone_data_source.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/data/repositories/interest_zone_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/domain/entities/interest_zone.dart';
import 'package:flutter_application_entrehuellas/features/interest_zones/domain/failures/zone_failure.dart';

void main() {
  test(
    'SDK reads private column projection with owner filter; stable RPC parameters and safe failures',
    () async {
      var calls = 0;
      var conflict = false;
      const headers = {'content-type': 'application/json'};
      final row = {
        'id': 'zone',
        'owner_id': 'owner',
        'name': 'Casa',
        'latitude': -12.0,
        'longitude': -77.0,
        'radius_meters': 1000,
        'version': 1,
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
                'created_at': '2026-10-09T00:00:00Z',
              },
            }),
            200,
            headers: headers,
            request: request,
          );
        }
        calls++;
        if (request.method == 'GET') {
          expect(request.url.path, '/rest/v1/interest_zones');
          expect(request.url.queryParameters['owner_id'], 'eq.owner');
          expect(
            request.url.queryParameters['select'],
            'id,owner_id,name,latitude,longitude,radius_meters,version',
          );
          expect(
            request.url.queryParameters['order'],
            'created_at.asc.nullslast,id.asc.nullslast',
          );
          return http.Response(
            jsonEncode([row]),
            200,
            headers: headers,
            request: request,
          );
        }
        expect(request.method, 'POST');
        final payload = jsonDecode(request.body) as Map;
        expect(payload['p_id'], 'zone');
        if (request.url.path.endsWith('/save_interest_zone')) {
          expect(payload['p_expected_version'], 0);
          expect(payload['p_name'], 'Casa');
          expect(payload['p_latitude'], -12);
          expect(payload['p_longitude'], -77);
          expect(payload['p_radius_meters'], 1000);
          if (conflict) {
            return http.Response(
              jsonEncode({'code': '40001', 'message': 'sensitive SDK details'}),
              409,
              headers: headers,
              request: request,
            );
          }
          return http.Response(
            jsonEncode(row),
            200,
            headers: headers,
            request: request,
          );
        }
        expect(request.url.path, '/rest/v1/rpc/delete_interest_zone');
        expect(payload['p_expected_version'], 1);
        return http.Response('null', 200, headers: headers, request: request);
      });
      final client = SupabaseClient(
        'https://example.test',
        'public-test-key',
        httpClient: mock,
      );
      addTearDown(client.dispose);
      final repository = InterestZoneRepositoryImpl(
        SupabaseInterestZoneDataSource(client),
      );
      await expectLater(
        repository.list('owner'),
        throwsA(
          isA<ZoneFailure>().having(
            (e) => e.kind,
            'kind',
            ZoneFailureKind.signedOut,
          ),
        ),
      );
      expect(calls, 0);
      await client.auth.signInWithPassword(
        email: 'test@example.test',
        password: 'fake',
      );
      expect((await repository.list('owner')).single.name, 'Casa');
      const draft = ZoneDraft(
        id: 'zone',
        name: 'Casa',
        latitude: -12,
        longitude: -77,
        radiusMeters: 1000,
      );
      final saved = await repository.save('owner', draft);
      await repository.delete('owner', saved);
      conflict = true;
      await expectLater(
        repository.save('owner', draft),
        throwsA(
          isA<ZoneFailure>().having(
            (e) => e.kind,
            'kind',
            ZoneFailureKind.conflict,
          ),
        ),
      );
      final before = calls;
      await expectLater(repository.list('other'), throwsA(isA<ZoneFailure>()));
      expect(calls, before);
    },
  );
}
