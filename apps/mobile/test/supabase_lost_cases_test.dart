import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/entities/lost_case.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/use_cases/publish_lost_case.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/use_cases/read_lost_cases.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/data/data_sources/supabase_lost_case_data_source.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/data/repositories/lost_case_repository_impl.dart';

void main() {
  test(
    'Real SDK sends stable command without owner parameter, projects public DTO and sanitizes errors',
    () async {
      var calls = 0;
      String? failure;
      bool missing = false;
      Completer<http.Response>? pendingPublication;
      const headers = {'content-type': 'application/json'};
      final mock = MockClient((request) async {
        Object response;
        if (request.url.path == '/auth/v1/token') {
          response = {
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
          calls++;
          if (failure != null) {
            return http.Response(
              jsonEncode({
                'code': switch (failure) {
                  'case_already_active' => '23505',
                  'PRIVATE LOCK DETAILS' => '55P03',
                  'NEW CONFLICT PRIVATE DETAILS' => 'PT409',
                  _ => '40001',
                },
                'message': failure,
              }),
              409,
              headers: headers,
              request: request,
            );
          }
          if (request.url.path == '/rest/v1/rpc/list_my_lost_case_cards') {
            expect(request.method, 'POST');
            response = [
              {
                'id': 'case',
                'pet_id': 'pet',
                'owner_id': 'owner',
                'status': 'active',
                'pet_name': 'Luna',
                'cover_path': 'opaque/photo.jpg',
              },
            ];
          } else if (request.url.path == '/rest/v1/rpc/delete_lost_case') {
            expect(jsonDecode(request.body), {'p_id': 'case'});
            response = [];
          } else if (request.url.path == '/rest/v1/rpc/publish_lost_case') {
            expect(jsonDecode(request.body), {
              'p_id': 'case',
              'p_pet_id': 'pet',
              'p_pet_version': 3,
              'p_occurred_at': '2026-10-09T00:00:00.000Z',
              'p_latitude': -12.04,
              'p_longitude': -77.04,
              'p_place_reference': 'Privada',
              'p_photo_ids': ['photo'],
            });
            if (pendingPublication != null) return pendingPublication.future;
            response = [
              {
                'id': 'case',
                'pet_id': 'pet',
                'owner_id': 'owner',
                'status': 'active',
              },
            ];
          } else if (request.url.path ==
              '/rest/v1/rpc/read_recovery_pet_case') {
            expect(jsonDecode(request.body), {'p_id': 'case'});
            response = missing
                ? []
                : [
                    {
                      'id': 'case',
                      'status': 'active',
                      'occurred_at': '2026-10-09T00:00:00Z',
                      'latitude': -12.045,
                      'longitude': -77.045,
                      'pet_name': 'Luna',
                      'species': 'dog',
                      'size': 'small',
                      'age_months': 12,
                      'traits': 'Blanca',
                      'photos': [
                        {'id': 'photo', 'path': 'opaque/photo.jpg'},
                      ],
                    },
                  ];
          } else {
            expect(
              request.url.path,
              '/storage/v1/object/sign/pet-photo-renditions/opaque/photo.jpg',
            );
            expect(jsonDecode(request.body), {'expiresIn': 300});
            response = {
              'signedURL':
                  '/object/sign/pet-photo-renditions/opaque/photo.jpg?token=fake',
            };
          }
        }
        return http.Response(
          jsonEncode(response),
          200,
          headers: headers,
          request: request,
        );
      });
      final client = SupabaseClient(
        'https://example.test',
        'public-key',
        httpClient: mock,
      );
      addTearDown(client.dispose);
      final repo = LostCaseRepositoryImpl(
        SupabaseLostCaseDataSource(
          client,
          publicationTimeout: const Duration(milliseconds: 50),
        ),
      );
      final draft = LostCaseDraft(
        id: 'case',
        petId: 'pet',
        petVersion: 3,
        occurredAt: DateTime.utc(2026, 10, 9),
        latitude: -12.04,
        longitude: -77.04,
        placeReference: ' Privada ',
        photoIds: ['photo'],
      );
      await expectLater(
        PublishLostCase(repo)('owner', draft),
        throwsA(
          isA<CaseFailure>().having(
            (e) => e.kind,
            'kind',
            CaseFailureKind.forbidden,
          ),
        ),
      );
      expect(calls, 0);
      await client.auth.signInWithPassword(
        email: 'test@example.test',
        password: 'fake',
      );
      try {
        expect((await PublishLostCase(repo)('owner', draft)).status, 'active');
      } on CaseFailure catch (e) {
        fail('Publication failed with ${e.kind}');
      }
      PublicLostCase? pub;
      final cards = await ListMyLostCases(repo)('owner');
      expect(cards.single.petName, 'Luna');
      expect(cards.single.coverUri, isNotNull);
      await repo.delete('owner', 'case');
      try {
        pub = await ReadPublicLostCase(repo)('case');
      } on CaseFailure catch (e) {
        fail('Public read failed with ${e.kind}');
      }
      expect(pub!.fields.name, 'Luna');
      expect(pub.latitude, -12.045);
      expect(pub.photos.single.uri, isNotNull);
      failure = 'case_already_active';
      await expectLater(
        PublishLostCase(repo)('owner', draft),
        throwsA(
          isA<CaseFailure>().having(
            (e) => e.kind,
            'kind',
            CaseFailureKind.activeCase,
          ),
        ),
      );
      failure = 'PRIVATE SDK TOKEN';
      await expectLater(
        PublishLostCase(repo)('owner', draft),
        throwsA(
          isA<CaseFailure>().having(
            (e) => e.kind,
            'kind',
            CaseFailureKind.conflict,
          ),
        ),
      );
      failure = 'NEW CONFLICT PRIVATE DETAILS';
      await expectLater(
        PublishLostCase(repo)('owner', draft),
        throwsA(
          isA<CaseFailure>().having(
            (error) => error.kind,
            'kind',
            CaseFailureKind.conflict,
          ),
        ),
      );
      failure = 'PRIVATE LOCK DETAILS';
      await expectLater(
        PublishLostCase(repo)('owner', draft),
        throwsA(
          isA<CaseFailure>().having(
            (e) => e.kind,
            'kind',
            CaseFailureKind.busy,
          ),
        ),
      );
      failure = null;
      missing = true;
      expect(await ReadPublicLostCase(repo)('case'), null);
      pendingPublication = Completer<http.Response>();
      final lateResponse = pendingPublication;
      await expectLater(
        PublishLostCase(repo)('owner', draft),
        throwsA(
          isA<CaseFailure>().having(
            (e) => e.kind,
            'kind',
            CaseFailureKind.timedOut,
          ),
        ),
      );
      pendingPublication = null;
      expect((await PublishLostCase(repo)('owner', draft)).status, 'active');
      lateResponse.complete(http.Response('[]', 200, headers: headers));
    },
  );
}
