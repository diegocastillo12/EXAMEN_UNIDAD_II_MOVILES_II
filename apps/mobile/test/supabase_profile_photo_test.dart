import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/features/profile/data/data_sources/supabase_profile_data_source.dart';
import 'package:flutter_application_entrehuellas/features/profile/data/data_sources/profile_data_source.dart';

void main() {
  const headers = {'content-type': 'application/json'};
  for (final denied in [false, true]) {
    test(
      'Private JPEG upload uses stable own path/upsert and requires signed-read acknowledgement; denied=$denied',
      () async {
        final bytes = img.encodeJpg(img.Image(width: 10, height: 10));
        var uploads = 0;
        final mock = MockClient((request) async {
          Map<String, Object?> body;
          var status = 200;
          if (request.url.path == '/auth/v1/token') {
            body = {
              'access_token':
                  'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJvd25lciIsImV4cCI6MjAwMDAwMDAwMH0.fake',
              'refresh_token': 'fake-refresh',
              'token_type': 'bearer',
              'expires_in': 3600,
              'user': {
                'id': 'owner',
                'email': 'ana@example.invalid',
                'aud': 'authenticated',
                'app_metadata': {},
                'user_metadata': {},
                'created_at': '2026-10-08T00:00:00Z',
              },
            };
          } else if (request.url.path ==
              '/storage/v1/object/profile-avatars/owner/avatar.jpg') {
            expect(request.method, 'POST');
            expect(
              request.headers['content-type'],
              startsWith('multipart/form-data'),
            );
            expect(
              latin1.decode(request.bodyBytes).toLowerCase(),
              contains('content-type: image/jpeg'),
            );
            expect(request.headers['x-upsert'], 'true');
            expect(
              latin1.decode(request.bodyBytes),
              contains(latin1.decode(bytes)),
            );
            uploads++;
            body = {'Key': 'profile-avatars/owner/avatar.jpg'};
          } else if (request.url.path == '/rest/v1/profiles') {
            expect(request.url.queryParameters['id'], 'eq.owner');
            body = {'id': 'owner', 'display_name': 'Ana', 'city': 'Lima'};
          } else {
            expect(
              request.url.path,
              '/storage/v1/object/sign/profile-avatars/owner/avatar.jpg',
            );
            status = denied ? 403 : 200;
            body = denied
                ? {
                    'statusCode': '403',
                    'error': 'forbidden',
                    'message': 'private SDK detail',
                  }
                : {
                    'signedURL':
                        '/object/sign/profile-avatars/owner/avatar.jpg?token=fake',
                  };
          }
          return http.Response(
            jsonEncode(body),
            status,
            headers: headers,
            request: request,
          );
        });
        final sdk = SupabaseClient(
          'https://example.supabase.co',
          'sb_publishable_test',
          httpClient: mock,
        );
        addTearDown(() async {
          await sdk.dispose();
          mock.close();
        });
        await sdk.auth.signInWithPassword(
          email: 'ana@example.invalid',
          password: 'fake',
        );
        final source = SupabaseProfileDataSource(sdk);
        if (denied) {
          await expectLater(
            source.uploadAvatar('owner', bytes),
            throwsA(isA<ProfileSourceFailure>()),
          );
        } else {
          final saved = await source.uploadAvatar('owner', bytes);
          expect(saved.email, 'ana@example.invalid');
          expect(
            saved.avatarUri!.path,
            contains('profile-avatars/owner/avatar.jpg'),
          );
          await source.uploadAvatar('owner', bytes);
          expect(uploads, 2);
        }
      },
    );
  }
}
