import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/core/data_sources/photo_gallery_source.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/use_cases/found_case_actions.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/data/data_sources/supabase_found_case_data_source.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/data/repositories/found_case_repository_impl.dart';

class NoGallery implements PhotoGallerySource {
  @override
  Future<Uint8List?> choose(
    String owner,
    String id,
    bool existing, {
    bool camera = false,
  }) async => null;
  @override
  Future<Uint8List?> recover(String owner, String id, bool existing) async =>
      null;
}

void main() {
  test(
    'SDK reserves found IDs, uploads without pet headers, normalizes errors and exposes only the public projection',
    () async {
      final calls = <String>[];
      bool failUpload = false, failPublish = false, missing = false;
      Completer<void>? pendingPrepare;
      String publishFailureCode = '40001';
      const headers = {'content-type': 'application/json'};
      final mock = MockClient((request) async {
        final path = request.url.path;
        calls.add(path);
        Object? response;
        if (path == '/auth/v1/token') {
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
        } else if (path == '/rest/v1/rpc/prepare_recovery_report') {
          await pendingPrepare?.future;
          expect(jsonDecode(request.body), {
            'p_id': 'case',
            'p_photo_ids': ['photo'],
            'p_report_kind': 'possible_loss',
            'p_target_id': null,
            'p_community_target': false,
          });
          response = null;
        } else if (path == '/rest/v1/rpc/list_found_photo_cleanup') {
          response = [];
        } else if (path == '/functions/v1/pet-photo-process') {
          expect(request.headers['x-found-case-id'], 'case');
          expect(request.headers['x-photo-id'], 'photo');
          expect(request.headers.containsKey('x-pet-id'), false);
          expect(request.bodyBytes, [255, 216, 255, 217]);
          if (failUpload) {
            return http.Response(
              '{"error":"sensitive internal detail"}',
              503,
              headers: headers,
              request: request,
            );
          }
          response = {
            'id': 'photo',
            'case_id': 'case',
            'owner_id': 'owner',
            'status': 'ready',
            'processed_at': '2026-10-10T00:00:00Z',
          };
        } else if (path == '/rest/v1/rpc/publish_recovery_report') {
          final command = jsonDecode(request.body) as Map;
          expect(command.containsKey('p_owner'), false);
          expect(command.containsKey('p_pet_id'), false);
          expect(command['p_custody'], null);
          expect(command['p_traits'], 'Blanca');
          expect(command['p_place_reference'], 'Privada');
          if (failPublish) {
            return http.Response(
              jsonEncode({
                'code': publishFailureCode,
                'message': 'sensitive internal detail',
              }),
              409,
              headers: headers,
              request: request,
            );
          }
          response = [
            {
              'id': 'case',
              'owner_id': 'owner',
              'status': 'active',
              'report_kind': 'possible_loss',
              'species': 'dog',
            },
          ];
        } else if (path == '/rest/v1/rpc/read_recovery_report') {
          response = missing
              ? []
              : [
                  {
                    'id': 'case',
                    'status': 'active',
                    'report_kind': 'possible_loss',
                    'occurred_at': '2026-10-09T00:00:00Z',
                    'latitude': -12.045,
                    'longitude': -77.045,
                    'species': 'dog',
                    'traits': 'Blanca',
                    'photos': [
                      {'id': 'photo', 'path': 'opaque/photo.jpg'},
                    ],
                  },
                ];
        } else if (path == '/rest/v1/rpc/list_my_recovery_reports') {
          expect(request.method, 'POST');
          if (request.body.isNotEmpty) {
            expect(jsonDecode(request.body), anyOf(isNull, isEmpty));
          }
          response = [
            {
              'id': 'case',
              'owner_id': 'owner',
              'status': 'active',
              'report_kind': 'possible_loss',
              'species': 'dog',
              'cover_path': 'opaque/photo.jpg',
            },
          ];
        } else if (path == '/rest/v1/rpc/delete_found_case') {
          expect(jsonDecode(request.body), {'p_id': 'case'});
          response = null;
        } else if (path == '/rest/v1/rpc/begin_found_case_discard') {
          response = [
            {'path': 'owner/case/photo.jpg'},
          ];
        } else if (path == '/rest/v1/rpc/finish_found_case_discard') {
          response = null;
        } else if (path.startsWith(
          '/storage/v1/object/sign/found-photo-renditions/',
        )) {
          expect(jsonDecode(request.body), {'expiresIn': 300});
          response = {
            'signedURL':
                '/object/sign/found-photo-renditions/opaque/photo.jpg?token=fake',
          };
        } else if (path.startsWith('/storage/v1/object/found-photo-')) {
          expect(request.method, 'DELETE');
          expect(jsonDecode(request.body), {
            'prefixes': ['owner/case/photo.jpg'],
          });
          response = [];
        } else {
          fail('Unexpected path $path');
        }
        if (response == null) {
          return http.Response('', 204, headers: headers, request: request);
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
      final repo = FoundCaseRepositoryImpl(
        SupabaseFoundCaseDataSource(client),
        NoGallery(),
      );
      final draft = FoundCaseDraft(
        id: 'case',
        occurredAt: DateTime.utc(2026, 10, 9),
        latitude: -12.0464,
        longitude: -77.0428,
        placeReference: ' Privada ',
        species: 'dog',
        traits: ' Blanca ',
        photos: [
          FoundPhotoDraft('photo', Uint8List.fromList([255, 216, 255, 217])),
        ],
      );
      await expectLater(
        PublishFoundCase(repo)('owner', draft),
        throwsA(
          isA<FoundFailure>().having(
            (e) => e.kind,
            'kind',
            FoundFailureKind.forbidden,
          ),
        ),
      );
      expect(calls, isEmpty);
      await client.auth.signInWithPassword(
        email: 'fake@example.test',
        password: 'fake',
      );
      calls.clear();
      failUpload = true;
      await expectLater(
        PublishFoundCase(repo)('owner', draft),
        throwsA(
          isA<FoundFailure>().having(
            (e) => e.kind,
            'kind',
            FoundFailureKind.unavailable,
          ),
        ),
      );
      expect(calls.contains('/rest/v1/rpc/publish_recovery_report'), false);
      failUpload = false;
      failPublish = true;
      await expectLater(
        PublishFoundCase(repo)('owner', draft),
        throwsA(
          isA<FoundFailure>().having(
            (e) => e.kind,
            'kind',
            FoundFailureKind.conflict,
          ),
        ),
      );
      publishFailureCode = 'PT409';
      await expectLater(
        PublishFoundCase(repo)('owner', draft),
        throwsA(
          isA<FoundFailure>().having(
            (error) => error.kind,
            'kind',
            FoundFailureKind.conflict,
          ),
        ),
      );
      publishFailureCode = '55P03';
      await expectLater(
        PublishFoundCase(repo)('owner', draft),
        throwsA(
          isA<FoundFailure>().having(
            (e) => e.kind,
            'kind',
            FoundFailureKind.timedOut,
          ),
        ),
      );
      failPublish = false;
      pendingPrepare = Completer<void>();
      calls.clear();
      final bounded = FoundCaseRepositoryImpl(
        SupabaseFoundCaseDataSource(
          client,
          requestTimeout: const Duration(milliseconds: 10),
        ),
        NoGallery(),
      );
      await expectLater(
        PublishFoundCase(bounded)('owner', draft),
        throwsA(
          isA<FoundFailure>().having(
            (e) => e.kind,
            'kind',
            FoundFailureKind.timedOut,
          ),
        ),
      );
      expect(calls, ['/rest/v1/rpc/prepare_recovery_report']);
      pendingPrepare.complete();
      await Future<void>.delayed(Duration.zero);
      expect(calls, ['/rest/v1/rpc/prepare_recovery_report']);
      pendingPrepare = null;
      expect((await PublishFoundCase(repo)('owner', draft)).id, 'case');
      final public = await ReadPublicFoundCase(repo)('case');
      expect(public!.photos.single.uri, isNotNull);
      expect(public.latitude, -12.045);
      final cards = await ListMyFoundCases(repo)('owner');
      expect(cards.single.species, 'dog');
      expect(cards.single.coverUri, isNotNull);
      await repo.delete('owner', 'case');
      expect(calls.contains('/rest/v1/rpc/delete_found_case'), true);
      missing = true;
      expect(await ReadPublicFoundCase(repo)('case'), null);
      await DiscardFoundDraft(repo)('owner', 'case');
      expect(calls.contains('/rest/v1/rpc/finish_found_case_discard'), true);
    },
  );
}
