import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/features/profile/data/data_sources/supabase_profile_data_source.dart';
import 'package:flutter_application_entrehuellas/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/profile/domain/failures/profile_failure.dart';

void main() {
  const headers = {'content-type': 'application/json'};
  for (final failure in [false, true]) {
    test(
      'SDK reads own projection and writes only editable columns; failure=$failure',
      () async {
        var calls = 0;
        final httpClient = MockClient((request) async {
          if (request.url.path == '/auth/v1/token') {
            return http.Response(
              jsonEncode({
                'access_token':
                    'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJvd25lciIsImV4cCI6MjAwMDAwMDAwMH0.fake',
                'refresh_token': 'fake-refresh',
                'token_type': 'bearer',
                'expires_in': 3600,
                'user': {
                  'id': 'owner',
                  'aud': 'authenticated',
                  'email': 'ana@example.invalid',
                  'app_metadata': {},
                  'user_metadata': {
                    'avatar_url': failure
                        ? 'file:///private.png'
                        : 'https://images.example.invalid/avatar.png',
                  },
                  'created_at': '2026-10-08T00:00:00Z',
                },
              }),
              200,
              headers: headers,
              request: request,
            );
          }
          if (request.url.path.startsWith('/storage/')) {
            return http.Response(
              '{"statusCode":"404","error":"not_found","message":"No photo"}',
              404,
              headers: headers,
              request: request,
            );
          }
          calls++;
          expect(request.url.path, '/rest/v1/profiles');
          expect(request.url.queryParameters['id'], 'eq.owner');
          expect(
            request.url.queryParameters['select'],
            'id,display_name,city,contact_phone',
          );
          if (request.method == 'PATCH') {
            expect(jsonDecode(request.body), {
              'display_name': 'Ana',
              'city': 'Cusco',
              'contact_phone': '+51900000000',
            });
            expect(
              request.headers['prefer'],
              contains('return=representation'),
            );
            if (failure) {
              return http.Response(
                jsonEncode({
                  'code': '42501',
                  'message': 'sensitive SQL detail',
                }),
                403,
                headers: headers,
                request: request,
              );
            }
          } else {
            expect(request.method, 'GET');
          }
          return http.Response(
            jsonEncode({
              'id': 'owner',
              'display_name': 'Ana',
              'city': request.method == 'PATCH' ? 'Cusco' : 'Lima',
              'contact_phone': '+51900000000',
            }),
            200,
            headers: headers,
            request: request,
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
        final repo = ProfileRepositoryImpl(SupabaseProfileDataSource(sdk));
        await expectLater(
          repo.read('owner'),
          throwsA(
            isA<ProfileFailure>().having(
              (e) => e.kind,
              'kind',
              ProfileFailureKind.signedOut,
            ),
          ),
        );
        expect(calls, 0);
        await sdk.auth.signInWithPassword(
          email: 'test@example.invalid',
          password: 'fake-password',
        );
        final read = await repo.read('owner');
        expect(read.city, 'Lima');
        expect(read.contactPhone, '+51900000000');
        expect(
          (await repo.read('owner')).avatarUri?.toString(),
          failure ? null : 'https://images.example.invalid/avatar.png',
        );
        await expectLater(
          repo.read('someone-else'),
          throwsA(
            isA<ProfileFailure>().having(
              (e) => e.kind,
              'kind',
              ProfileFailureKind.signedOut,
            ),
          ),
        );
        expect(calls, 2);
        if (failure) {
          await expectLater(
            repo.update(
              'owner',
              displayName: 'Ana',
              city: 'Cusco',
              contactPhone: '+51900000000',
            ),
            throwsA(
              isA<ProfileFailure>().having(
                (e) => e.kind,
                'kind',
                ProfileFailureKind.forbidden,
              ),
            ),
          );
        } else {
          expect(
            (await repo.update(
              'owner',
              displayName: 'Ana',
              city: 'Cusco',
              contactPhone: '+51900000000',
            )).city,
            'Cusco',
          );
        }
      },
    );
  }
}
