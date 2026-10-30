import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/features/pets/data/data_sources/supabase_pet_data_source.dart';
import 'package:flutter_application_entrehuellas/features/pets/data/repositories/pet_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/failures/pet_failure.dart';

void main() {
  for (final conflict in [false, true]) {
    test(
      'SDK filters ownership, writes RPC fields and maps conflict safely; conflict=$conflict',
      () async {
        const headers = {'content-type': 'application/json'};
        var calls = 0;
        final client = MockClient((request) async {
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
                  'app_metadata': {},
                  'user_metadata': {},
                  'created_at': '2026-10-08T00:00:00Z',
                },
              }),
              200,
              headers: headers,
              request: request,
            );
          }
          calls++;
          final row = {
            'id': 'pet-id',
            'owner_id': 'owner',
            'name': 'Luna',
            'species': 'cat',
            'sex': null,
            'age_months': null,
            'traits': null,
            'version': 1,
          };
          if (request.method == 'GET') {
            expect(request.url.path, '/rest/v1/pets');
            expect(request.url.queryParameters['owner_id'], 'eq.owner');
            expect(
              request.url.queryParameters['select'],
              SupabasePetDataSource.columns,
            );
            if (request.url.queryParameters.containsKey('id')) {
              expect(request.url.queryParameters['id'], 'eq.pet-id');
              return http.Response(
                jsonEncode([row]),
                200,
                headers: headers,
                request: request,
              );
            }
            return http.Response(
              jsonEncode([row]),
              200,
              headers: headers,
              request: request,
            );
          }
          final payload = jsonDecode(request.body) as Map;
          expect(request.method, 'POST');
          expect(
            payload.keys.toSet(),
            request.url.path.endsWith('update_pet_v2')
                ? {
                    'p_id',
                    'p_name',
                    'p_species',
                    'p_sex',
                    'p_age_months',
                    'p_traits',
                    'p_species_detail',
                    'p_size',
                    'p_expected_version',
                  }
                : {
                    'p_id',
                    'p_name',
                    'p_species',
                    'p_sex',
                    'p_age_months',
                    'p_traits',
                    'p_species_detail',
                    'p_size',
                  },
          );
          expect(payload['p_id'], 'pet-id');
          expect(payload['p_name'], 'Luna');
          expect(
            request.url.path,
            anyOf('/rest/v1/rpc/create_pet_v2', '/rest/v1/rpc/update_pet_v2'),
          );
          if (conflict && request.url.path.endsWith('update_pet_v2')) {
            return http.Response(
              '{"code":"40001","message":"sensitive SQL detail"}',
              409,
              headers: headers,
              request: request,
            );
          }
          return http.Response(
            jsonEncode([row]),
            200,
            headers: headers,
            request: request,
          );
        });
        final sdk = SupabaseClient(
          'https://example.supabase.co',
          'sb_publishable_test',
          httpClient: client,
        );
        addTearDown(() async {
          await sdk.dispose();
          client.close();
        });
        final repo = PetRepositoryImpl(SupabasePetDataSource(sdk));
        await expectLater(
          repo.list('owner'),
          throwsA(
            isA<PetFailure>().having(
              (e) => e.kind,
              'kind',
              PetFailureKind.signedOut,
            ),
          ),
        );
        expect(calls, 0);
        await sdk.auth.signInWithPassword(
          email: 'test@example.invalid',
          password: 'fake-password',
        );
        expect((await repo.list('owner')).single.fields.name, 'Luna');
        expect((await repo.read('owner', 'pet-id')).ownerId, 'owner');
        await expectLater(
          repo.read('another-owner', 'pet-id'),
          throwsA(
            isA<PetFailure>().having(
              (e) => e.kind,
              'kind',
              PetFailureKind.forbidden,
            ),
          ),
        );
        expect(calls, 2);
        const fields = PetFields(name: 'Luna', species: PetSpecies.cat);
        expect((await repo.create('owner', 'pet-id', fields)).id, 'pet-id');
        if (conflict) {
          await expectLater(
            repo.update('owner', 'pet-id', 1, fields),
            throwsA(
              isA<PetFailure>().having(
                (e) => e.kind,
                'kind',
                PetFailureKind.conflict,
              ),
            ),
          );
        } else {
          expect(
            (await repo.update('owner', 'pet-id', 1, fields)).fields.species,
            PetSpecies.cat,
          );
        }
      },
    );
  }
}
