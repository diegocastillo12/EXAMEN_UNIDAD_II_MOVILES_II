import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/features/pets/data/data_sources/supabase_pet_data_source.dart';
import 'package:flutter_application_entrehuellas/features/pets/data/repositories/pet_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/failures/pet_failure.dart';

void main() {
  const owner = '00000000-0000-0000-0000-000000000001';
  const id = '00000000-0000-0000-0000-000000000002';
  Map<String, dynamic> row({bool archived = false}) => {
    'id': id,
    'owner_id': owner,
    'name': 'Luna',
    'species': 'dog',
    'version': 2,
    'archived_at': archived ? '2026-10-09T00:00:00Z' : null,
    'case_history_at': '2026-10-08T00:00:00Z',
    'active_case_count': 0,
  };
  late SupabaseClient client;
  late PetRepositoryImpl repo;
  late http.Response Function(http.Request) reply;
  final requests = <http.Request>[];
  http.Response json(Object data, [int status = 200]) => http.Response(
    jsonEncode(data),
    status,
    headers: {'content-type': 'application/json'},
  );
  setUp(() async {
    requests.clear();
    final transport = MockClient((request) async {
      if (request.url.path == '/auth/v1/token') {
        return json({
          'access_token':
              '${base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256'})))}.${base64Url.encode(utf8.encode(jsonEncode({'sub': owner, 'role': 'authenticated', 'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600})))}.test-signature',
          'refresh_token': 'test-refresh-token',
          'token_type': 'bearer',
          'expires_in': 3600,
          'user': {
            'id': owner,
            'aud': 'authenticated',
            'role': 'authenticated',
            'email': 'one@example.test',
            'created_at': '2026-10-09T00:00:00Z',
          },
        });
      }
      requests.add(request);
      final response = reply(request);
      return http.Response(
        response.body,
        response.statusCode,
        headers: response.headers,
        request: request,
      );
    });
    client = SupabaseClient(
      'https://example.supabase.co',
      'sb_publishable_test',
      httpClient: transport,
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    addTearDown(() async {
      await client.dispose();
      transport.close();
    });
    await client.auth.signInWithPassword(
      email: 'one@example.test',
      password: 'test-password',
    );
    repo = PetRepositoryImpl(SupabasePetDataSource(client));
  });
  test(
    'Active/archived remote queries enforce owner and filter before returning entities',
    () async {
      reply = (_) => json([row()]);
      expect((await repo.list(owner)).single.isArchived, false);
      reply = (_) => json([row(archived: true)]);
      final archived = (await repo.list(owner, archived: true)).single;
      expect(archived.isArchived, true);
      expect(archived.caseHistoryAt, DateTime.utc(2026, 10, 8));
      expect(requests.first.url.queryParameters['archived_at'], 'is.null');
      expect(requests.last.url.queryParameters['archived_at'], 'not.is.null');
      for (final request in requests) {
        expect(request.url.queryParameters['owner_id'], 'eq.$owner');
        expect(
          request.url.queryParameters['select'],
          contains('active_case_count'),
        );
      }
    },
  );
  test(
    'RPC commands use stable id/version and map server protections without SDK messages',
    () async {
      reply = (_) => json([row(archived: true)]);
      final archived = await repo.archive(owner, id, 1);
      expect(archived.isArchived, true);
      expect(requests.last.url.path, '/rest/v1/rpc/archive_pet');
      expect(jsonDecode(requests.last.body), {
        'p_id': id,
        'p_expected_version': 1,
      });
      reply = (_) => json([row()]);
      expect((await repo.restore(owner, id, 2)).isArchived, false);
      expect(requests.last.url.path, '/rest/v1/rpc/restore_pet');
      for (final pair in [
        ('pet_active_case', PetFailureKind.activeCase),
        ('pet_has_case_history', PetFailureKind.caseHistory),
      ]) {
        reply = (_) => json({
          'code': '23514',
          'message': pair.$1,
          'details': 'private SDK detail',
          'hint': null,
        }, 400);
        await expectLater(
          repo.archive(owner, id, 2),
          throwsA(isA<PetFailure>().having((e) => e.kind, 'kind', pair.$2)),
        );
      }
    },
  );
  test(
    'A command response with a different owner never becomes a confirmed pet',
    () async {
      reply = (_) => json([
        {...row(archived: true), 'owner_id': id},
      ]);
      await expectLater(
        repo.archive(owner, id, 1),
        throwsA(
          isA<PetFailure>().having(
            (e) => e.kind,
            'kind',
            PetFailureKind.forbidden,
          ),
        ),
      );
    },
  );
}
