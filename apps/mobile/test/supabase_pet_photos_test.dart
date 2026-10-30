import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/features/pets/data/data_sources/supabase_pet_photo_source.dart';
import 'package:flutter_application_entrehuellas/features/pets/data/data_sources/pet_photo_data_source.dart';

void main() {
  for (final scenario in [
    (edge: 200, storage: 200),
    (edge: 403, storage: 200),
    (edge: 422, storage: 200),
    (edge: 409, storage: 200),
    (edge: 200, storage: 403),
  ]) {
    final status = scenario.edge;
    test(
      'Photo upload uses authenticated Edge processing and private signed renditions; Edge=$status Storage=${scenario.storage}',
      () async {
        final bytes = img.encodeJpg(img.Image(width: 10, height: 10));
        final calls = <String>[];
        final row = {
          'id': 'photo',
          'pet_id': 'pet',
          'owner_id': 'owner',
          'status': 'published',
          'processed_at': '2026-10-10T00:00:00Z',
          'is_primary': true,
        };
        final mock = MockClient((request) async {
          final path = request.url.path;
          Object body;
          var responseStatus = 200;
          if (path == '/auth/v1/token') {
            body = {
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
            };
          } else {
            calls.add(path);
            if (path == '/functions/v1/pet-photo-process') {
              expect(request.headers['authorization'], startsWith('Bearer '));
              expect(request.headers['x-pet-id'], 'pet');
              expect(request.headers['x-photo-id'], 'photo');
              expect(request.headers['content-type'], 'image/jpeg');
              expect(request.bodyBytes, bytes);
              responseStatus = status;
              body = status == 200 ? row : {'error': 'photo_failed'};
            } else {
              responseStatus = scenario.storage;
              expect(
                path,
                anyOf(
                  '/storage/v1/object/sign/pet-photo-renditions/owner/pet/photo.jpg',
                  '/storage/v1/object/sign/pet-photo-thumbnails/owner/pet/photo.jpg',
                ),
              );
              body = scenario.storage == 200
                  ? {
                      'signedURL':
                          '/object/sign/${path.split('/sign/').last}?token=fake',
                    }
                  : {
                      'statusCode': '403',
                      'error': 'Forbidden',
                      'message': 'private SDK detail',
                    };
            }
          }
          return http.Response(
            jsonEncode(body),
            responseStatus,
            headers: {'content-type': 'application/json'},
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
        final source = SupabasePetPhotoSource(sdk);
        await expectLater(
          source.upload('owner', 'pet', 'photo', bytes),
          throwsA(isA<PetPhotoSourceFailure>()),
        );
        expect(calls, isEmpty);
        await sdk.auth.signInWithPassword(
          email: 'test@example.invalid',
          password: 'fake',
        );
        if (status == 200 && scenario.storage == 200) {
          final result = await source.upload('owner', 'pet', 'photo', bytes);
          expect(result.toEntity().isPrimary, true);
          expect(result.uri!.path, contains('pet-photo-renditions'));
          expect(result.thumbnailUri!.path, contains('pet-photo-thumbnails'));
        } else {
          final kind = switch (scenario.storage != 200
              ? scenario.storage
              : status) {
            403 => PetPhotoSourceFailureKind.forbidden,
            422 => PetPhotoSourceFailureKind.invalidPhoto,
            _ => PetPhotoSourceFailureKind.conflict,
          };
          await expectLater(
            source.upload('owner', 'pet', 'photo', bytes),
            throwsA(
              isA<PetPhotoSourceFailure>().having((e) => e.kind, 'kind', kind),
            ),
          );
        }
        expect(calls.first, '/functions/v1/pet-photo-process');
        expect(
          calls.length,
          status != 200
              ? 1
              : scenario.storage == 200
              ? 3
              : 2,
        );
        expect(
          calls.any((path) => path.contains('/rest/v1/rpc/publish_pet_photo')),
          false,
        );
      },
    );
  }
}
