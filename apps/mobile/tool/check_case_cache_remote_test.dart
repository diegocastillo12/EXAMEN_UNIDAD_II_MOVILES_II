import 'dart:convert';
import 'dart:ffi' show DynamicLibrary;
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:sqlite3/open.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_entrehuellas/core/domain/utils/new_entity_id.dart';
import 'package:flutter_application_entrehuellas/core/data_sources/photo_gallery_source.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/data/data_sources/supabase_found_case_data_source.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/data/repositories/found_case_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/use_cases/found_case_actions.dart';
import 'package:flutter_application_entrehuellas/features/offline_cases/data/data_sources/case_cache_database.dart';
import 'package:flutter_application_entrehuellas/features/offline_cases/data/repositories/case_cache_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/offline_cases/domain/use_cases/consult_cached_case.dart';

class CacheFaultClient extends http.BaseClient {
  final inner = http.Client();
  bool offline = false;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (offline) throw http.ClientException('Offline QA');
    return inner.send(request);
  }

  @override
  void close() => inner.close();
}

void main() {
  test(
    'real server/photo → durable cache → offline reopen → A/B isolation → server close invalidation',
    () async {
      if (Platform.isWindows) {
        open.overrideFor(
          OperatingSystem.windows,
          () => DynamicLibrary.open('winsqlite3.dll'),
        );
      }
      final config =
          jsonDecode(File('config/profile_test.local.json').readAsStringSync())
              as Map<String, dynamic>;
      final fault = CacheFaultClient();
      final a = SupabaseClient(
        config['SUPABASE_URL'] as String,
        config['SUPABASE_PUBLISHABLE_KEY'] as String,
        httpClient: fault,
      );
      final b = SupabaseClient(
        config['SUPABASE_URL'] as String,
        config['SUPABASE_PUBLISHABLE_KEY'] as String,
      );
      final directory = await Directory.systemTemp.createTemp(
        'eh-remote-cache-',
      );
      final file = File('${directory.path}/cache.sqlite');
      var db = CaseCacheDatabase(NativeDatabase(file));
      final id = newEntityId();
      String? owner;
      var created = false;
      final repo = FoundCaseRepositoryImpl(
        SupabaseFoundCaseDataSource(a),
        NativePhotoGallerySource(ImagePicker()),
      );
      try {
        await a.auth.signInWithPassword(
          email: config['PROFILE_TEST_EMAIL_A'] as String,
          password: config['PROFILE_TEST_PASSWORD_A'] as String,
        );
        final refresh = config['PROFILE_TEST_REFRESH_TOKEN_B'] as String?;
        if (refresh != null && refresh.isNotEmpty) {
          final result = await b.auth.setSession(refresh);
          config['PROFILE_TEST_REFRESH_TOKEN_B'] = result.session!.refreshToken;
          File(
            'config/profile_test.local.json',
          ).writeAsStringSync(jsonEncode(config));
        } else {
          await b.auth.signInWithPassword(
            email: config['PROFILE_TEST_EMAIL_B'] as String,
            password: config['PROFILE_TEST_PASSWORD_B'] as String,
          );
        }
        owner = a.auth.currentUser!.id;
        final other = b.auth.currentUser!.id;
        expect(owner, isNot(other));
        final decoded = image.decodeImage(
          File('assets/onboarding/dog_with_map.png').readAsBytesSync(),
        )!;
        final jpeg = Uint8List.fromList(
          image.encodeJpg(image.copyResize(decoded, width: 320), quality: 85),
        );
        created = true;
        await PublishFoundCase(repo)(
          owner,
          FoundCaseDraft(
            id: id,
            occurredAt: DateTime.now().toUtc().subtract(
              const Duration(minutes: 2),
            ),
            latitude: -12.0464,
            longitude: -77.0428,
            placeReference: 'QA HU-15.3 temporal',
            species: 'dog',
            traits: 'QA caché local temporal',
            photos: [FoundPhotoDraft(newEntityId(), jpeg)],
          ),
        );
        var cache = CaseCacheRepositoryImpl(db);
        var consult = ConsultCachedCase(cache);
        final fresh = await consult<PublicFoundCase>(
          owner: owner,
          source: 'found',
          id: id,
          load: () => ReadPublicFoundCase(repo)(id),
        );
        expect(fresh.cachedAt, isNull);
        expect(fresh.value!.id, id);
        final persisted = await cache.read(owner, 'found', id);
        expect(persisted!.found!.photos.single.uri!.scheme, 'data');
        final bytes = persisted.found!.photos.single.uri!.data!
            .contentAsBytes();
        expect(image.decodeImage(bytes), isNotNull);
        final payload = (await db.rows(owner)).single;
        expect(payload, isNot(contains('https:')));
        expect(payload, isNot(contains('can_resolve')));
        debugPrint(
          'CASE_CACHE_REMOTE_PASS real_rpc_and_decodable_storage_photo',
        );
        await db.close();
        db = CaseCacheDatabase(NativeDatabase(file));
        cache = CaseCacheRepositoryImpl(db);
        consult = ConsultCachedCase(cache);
        fault.offline = true;
        final offline = await consult<PublicFoundCase>(
          owner: owner,
          source: 'found',
          id: id,
          load: () => ReadPublicFoundCase(repo)(id),
        );
        expect(offline.cachedAt, persisted.storedAt);
        expect(offline.value!.canResolve, isFalse);
        expect(offline.value!.canGeneratePoster, isFalse);
        expect(offline.value!.photos.single.uri!.data!.contentAsBytes(), bytes);
        expect(await cache.list(other), isEmpty);
        await expectLater(
          consult<PublicFoundCase>(
            owner: other,
            source: 'found',
            id: id,
            load: () => ReadPublicFoundCase(repo)(id),
          ),
          throwsA(isA<FoundFailure>()),
        );
        await expectLater(
          consult<PublicFoundCase>(
            owner: null,
            source: 'found',
            id: id,
            load: () => ReadPublicFoundCase(repo)(id),
          ),
          throwsA(isA<FoundFailure>()),
        );
        debugPrint(
          'CASE_CACHE_REMOTE_PASS disk_reopen_offline_bytes_account_isolation_logout',
        );
        fault.offline = false;
        final freshAgain = await consult<PublicFoundCase>(
          owner: owner,
          source: 'found',
          id: id,
          load: () => ReadPublicFoundCase(repo)(id),
        );
        expect(freshAgain.cachedAt, isNull);
        await repo.resolveSearch(owner, id, true);
        final closed = await consult<PublicFoundCase>(
          owner: owner,
          source: 'found',
          id: id,
          load: () => ReadPublicFoundCase(repo)(id),
        );
        expect(closed.value, isNull);
        expect(await cache.read(owner, 'found', id), isNull);
        fault.offline = true;
        await expectLater(
          consult<PublicFoundCase>(
            owner: owner,
            source: 'found',
            id: id,
            load: () => ReadPublicFoundCase(repo)(id),
          ),
          throwsA(isA<FoundFailure>()),
        );
        debugPrint(
          'CASE_CACHE_REMOTE_PASS reconnect_real_server_closed_no_resurrection',
        );
      } finally {
        fault.offline = false;
        if (created && owner != null) {
          final mine = await repo.listMine(owner);
          final entry = mine.where((v) => v.id == id).firstOrNull;
          if (entry != null && {'draft', 'discarded'}.contains(entry.status)) {
            await repo.discard(owner, id);
          } else if (entry != null) {
            await repo.delete(owner, id);
          }
        }
        await db.close();
        await a.dispose();
        await b.dispose();
        await directory.delete(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
