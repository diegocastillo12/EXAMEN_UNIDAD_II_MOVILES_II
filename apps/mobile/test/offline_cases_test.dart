import 'dart:async';
import 'dart:convert';
import 'dart:ffi' show DynamicLibrary;
import 'dart:io';
import 'package:drift/native.dart';
import 'package:sqlite3/open.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_entrehuellas/features/offline_cases/data/data_sources/case_cache_database.dart';
import 'package:flutter_application_entrehuellas/features/offline_cases/data/data_sources/case_cache_photo_source.dart';
import 'package:flutter_application_entrehuellas/features/offline_cases/data/repositories/case_cache_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/offline_cases/domain/entities/cached_case.dart';
import 'package:flutter_application_entrehuellas/features/offline_cases/domain/use_cases/consult_cached_case.dart';
import 'package:flutter_application_entrehuellas/features/offline_cases/providers/case_cache_providers.dart';
import 'package:flutter_application_entrehuellas/features/offline_cases/presentation/view_models/cached_cases_view_model.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/entities/lost_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/providers/lost_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/presentation/view_models/case_read_view_model.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/presentation/screens/case_detail_screen.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/zone_map_picker.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_photo.dart';
import 'lost_cases_test.dart' show FakeCases;
import 'alert_preferences_test.dart' show loadFonts;
import 'package:flutter/services.dart';

final instant = DateTime.utc(2026, 10, 24, 16);
final png = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jR1EAAAAASUVORK5CYII=',
  ),
);
PublicLostCase lost({
  String id = 'case',
  String status = 'active',
  String name = 'Luna',
}) => PublicLostCase(
  id: id,
  status: status,
  canResolve: true,
  occurredAt: instant,
  latitude: -12.04,
  longitude: -77.03,
  fields: PetFields(
    name: name,
    species: PetSpecies.dog,
    size: PetSize.small,
    ageMonths: 12,
    traits: 'Blanca',
  ),
  photos: [
    CasePhoto(
      id: 'photo',
      uri: Uri.parse('https://example.test/photo?token=secret'),
    ),
  ],
);
PublicFoundCase found({String status = 'active'}) => PublicFoundCase(
  id: 'case',
  status: status,
  canResolve: true,
  canGeneratePoster: true,
  occurredAt: instant,
  latitude: -12.04,
  longitude: -77.03,
  species: 'cat',
  traits: 'Gris',
  reportKind: 'possible_loss',
  targetId: 'private-target',
  photos: [FoundPhoto('photo', Uri.parse('https://example.test/photo'))],
);

class Photos extends CaseCachePhotoSource {
  bool fail = false;
  Completer<void>? pending;
  @override
  Future<Uri?> download(Uri? uri) async {
    await pending?.future;
    return fail ? null : Uri.dataFromBytes(png, mimeType: 'image/png');
  }
}

void main() {
  setUpAll(() {
    if (Platform.isWindows) {
      open.overrideFor(
        OperatingSystem.windows,
        () => DynamicLibrary.open('winsqlite3.dll'),
      );
    }
  });
  late CaseCacheDatabase db;
  late CaseCacheRepositoryImpl cache;
  late Photos photos;
  setUp(() {
    db = CaseCacheDatabase(NativeDatabase.memory());
    photos = Photos();
    cache = CaseCacheRepositoryImpl(db, photos: photos);
  });
  tearDown(() => db.close());

  test(
    'SQLite reopen preserves public fields and photo bytes, never URLs or permissions',
    () async {
      final directory = await Directory.systemTemp.createTemp('eh-case-cache-');
      final file = File('${directory.path}/case_cache.sqlite');
      var disk = CaseCacheDatabase(NativeDatabase(file));
      await CaseCacheRepositoryImpl(
        disk,
        photos: photos,
      ).put('A', CachedCase(storedAt: instant, lost: lost()));
      final payload = (await disk.rows('A')).single;
      expect(payload, isNot(contains('secret')));
      expect(payload, isNot(contains('https:')));
      expect(payload, isNot(contains('can_resolve')));
      await disk.close();
      disk = CaseCacheDatabase(NativeDatabase(file));
      final reopened = CaseCacheRepositoryImpl(disk, photos: photos);
      final entry = await reopened.read('A', 'lost', 'case');
      expect(entry!.lost!.fields.name, 'Luna');
      expect(entry.lost!.canResolve, isFalse);
      expect(entry.lost!.photos.single.uri!.data!.contentAsBytes(), png);
      expect(await reopened.list('B'), isEmpty);
      await disk.close();
      await directory.delete(recursive: true);
    },
  );
  test(
    'same UUID in found/lost and different owners remains isolated',
    () async {
      await cache.put('A', CachedCase(storedAt: instant, lost: lost()));
      await cache.put('A', CachedCase(storedAt: instant, found: found()));
      await cache.put(
        'B',
        CachedCase(
          storedAt: instant,
          lost: lost(name: 'B'),
        ),
      );
      expect((await cache.list('A')).length, 2);
      expect((await cache.read('B', 'lost', 'case'))!.lost!.fields.name, 'B');
      final f = (await cache.read('A', 'found', 'case'))!.found!;
      expect(f.canResolve, isFalse);
      expect(f.canGeneratePoster, isFalse);
      expect(f.targetId, isNull);
    },
  );
  test(
    'cache fallback carries original timestamp and cannot authorize actions',
    () async {
      await cache.put('A', CachedCase(storedAt: instant, lost: lost()));
      final result = await ConsultCachedCase(cache)<PublicLostCase>(
        owner: 'A',
        source: 'lost',
        id: 'case',
        load: () async => throw const CaseFailure(CaseFailureKind.unavailable),
      );
      expect(result.cachedAt, instant);
      expect(result.value!.canResolve, isFalse);
      expect(result.value!.photos.single.uri!.scheme, 'data');
    },
  );
  test('signed out or other account never receives fallback', () async {
    await cache.put('A', CachedCase(storedAt: instant, lost: lost()));
    for (final owner in [null, '', 'B']) {
      await expectLater(
        ConsultCachedCase(cache)<PublicLostCase>(
          owner: owner,
          source: 'lost',
          id: 'case',
          load: () async =>
              throw const CaseFailure(CaseFailureKind.unavailable),
        ),
        throwsA(isA<CaseFailure>()),
      );
    }
  });
  test(
    'server absence purges copy, and later network failure cannot resurrect it',
    () async {
      await cache.put('A', CachedCase(storedAt: instant, lost: lost()));
      final consult = ConsultCachedCase(cache);
      expect(
        (await consult<PublicLostCase>(
          owner: 'A',
          source: 'lost',
          id: 'case',
          load: () async => null,
        )).value,
        isNull,
      );
      expect(await cache.list('A'), isEmpty);
      await expectLater(
        consult<PublicLostCase>(
          owner: 'A',
          source: 'lost',
          id: 'case',
          load: () async =>
              throw const CaseFailure(CaseFailureKind.unavailable),
        ),
        throwsA(isA<CaseFailure>()),
      );
    },
  );
  test('server closed and denied lost/found remove cached copies', () async {
    for (final kind in ['closed', 'denied']) {
      await cache.put('A', CachedCase(storedAt: instant, lost: lost()));
      await cache.put('A', CachedCase(storedAt: instant, found: found()));
      final consult = ConsultCachedCase(cache);
      final l = await consult<PublicLostCase>(
        owner: 'A',
        source: 'lost',
        id: 'case',
        load: () async {
          if (kind == 'denied') {
            throw const CaseFailure(CaseFailureKind.forbidden);
          }
          return lost(status: 'resolved');
        },
      );
      final f = await consult<PublicFoundCase>(
        owner: 'A',
        source: 'found',
        id: 'case',
        load: () async {
          if (kind == 'denied') {
            throw const FoundFailure(FoundFailureKind.blocked);
          }
          return found(status: 'resolved');
        },
      );
      expect(l.value, isNull);
      expect(f.value, isNull);
      expect(await cache.list('A'), isEmpty);
    }
  });
  test(
    'reconnection replaces snapshot and timestamp with fresh server projection',
    () async {
      await cache.put('A', CachedCase(storedAt: instant, lost: lost()));
      final result = await ConsultCachedCase(cache)<PublicLostCase>(
        owner: 'A',
        source: 'lost',
        id: 'case',
        load: () async => lost(name: 'Actualizada'),
      );
      expect(result.cachedAt, isNull);
      expect(result.value!.fields.name, 'Actualizada');
      expect(
        (await cache.read('A', 'lost', 'case'))!.lost!.fields.name,
        'Actualizada',
      );
    },
  );
  test(
    'photo transport failure preserves only matching previous bytes',
    () async {
      await cache.put('A', CachedCase(storedAt: instant, lost: lost()));
      photos.fail = true;
      await cache.put(
        'A',
        CachedCase(
          storedAt: instant,
          lost: lost(name: 'Nueva'),
        ),
      );
      expect(
        (await cache.read(
          'A',
          'lost',
          'case',
        ))!.lost!.photos.single.uri!.data!.contentAsBytes(),
        png,
      );
    },
  );
  test('late photo download cannot recreate an invalidated case', () async {
    photos.pending = Completer<void>();
    final write = cache.put('A', CachedCase(storedAt: instant, lost: lost()));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await cache.remove('A', 'lost', 'case');
    photos.pending!.complete();
    await write;
    expect(await cache.list('A'), isEmpty);
  });

  test(
    'an earlier remote reply cannot restore a newer confirmed absence',
    () async {
      final consult = ConsultCachedCase(cache);
      final remote = Completer<PublicLostCase?>();
      final earlier = consult<PublicLostCase>(
        owner: 'A',
        source: 'lost',
        id: 'case',
        load: () => remote.future,
      );
      await consult<PublicLostCase>(
        owner: 'A',
        source: 'lost',
        id: 'case',
        load: () async => null,
      );
      remote.complete(lost());
      expect((await earlier).value, isNull);
      expect(await cache.list('A'), isEmpty);
    },
  );

  test(
    'SQLite write failure preserves online result and reports missing durable copy',
    () async {
      await db.customStatement('PRAGMA query_only=ON');
      final result = await ConsultCachedCase(cache)<PublicLostCase>(
        owner: 'A',
        source: 'lost',
        id: 'case',
        load: () async => lost(),
      );
      expect(result.value!.fields.name, 'Luna');
      expect(result.cachedAt, isNull);
      expect(result.storageFailed, isTrue);
      expect(await cache.list('A'), isEmpty);
      await db.customStatement('PRAGMA query_only=OFF');
    },
  );
  test(
    'failed invalidation still hides the revoked copy for this process',
    () async {
      await cache.put('A', CachedCase(storedAt: instant, lost: lost()));
      await db.customStatement('PRAGMA query_only=ON');
      final result = await ConsultCachedCase(cache)<PublicLostCase>(
        owner: 'A',
        source: 'lost',
        id: 'case',
        load: () async => null,
      );
      expect(result.value, isNull);
      expect(result.storageFailed, isTrue);
      expect(await cache.read('A', 'lost', 'case'), isNull);
      expect(await cache.list('A'), isEmpty);
      await db.customStatement('PRAGMA query_only=OFF');
      await ConsultCachedCase(cache)<PublicLostCase>(
        owner: 'A',
        source: 'lost',
        id: 'case',
        load: () async => lost(name: 'Nueva autorización'),
      );
      expect(
        (await cache.read('A', 'lost', 'case'))!.lost!.fields.name,
        'Nueva autorización',
      );
    },
  );

  test('device cache bounded to 30 most recent cases', () async {
    for (var i = 0; i < 32; i++) {
      await cache.put(
        'A',
        CachedCase(
          storedAt: instant.add(Duration(seconds: i)),
          lost: lost(id: '$i'),
        ),
      );
    }
    final entries = await cache.list('A');
    expect(entries.length, 30);
    expect(entries.first.id, '31');
    expect(await cache.read('A', 'lost', '0'), isNull);
  });
  test(
    'ViewModel clears local list immediately on account change and logout',
    () async {
      await cache.put('A', CachedCase(storedAt: instant, lost: lost()));
      final sessions = StreamController<AuthSession?>();
      final c = ProviderContainer(
        overrides: [
          caseCacheRepositoryProvider.overrideWithValue(cache),
          cachedCasesSessionProvider.overrideWith((ref) => sessions.stream),
        ],
      );
      final sub = c.listen(cachedCasesViewModelProvider, (_, _) {});
      sessions.add(const AuthSession(userId: 'A'));
      expect((await c.read(cachedCasesViewModelProvider.future)).length, 1);
      sessions.add(const AuthSession(userId: 'B'));
      await Future<void>.delayed(Duration.zero);
      expect(await c.read(cachedCasesViewModelProvider.future), isEmpty);
      sessions.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(await c.read(cachedCasesViewModelProvider.future), isEmpty);
      sub.close();
      c.dispose();
      await sessions.close();
    },
  );
  for (final small in [false, true]) {
    testWidgets(
      'offline detail shows timestamp, local photo, refresh and no remote actions; small=$small',
      (tester) async {
        await tester.runAsync(() async {
          await loadFonts();
          await (FontLoader('Poppins')
                ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf')))
              .load();
        });
        await tester.runAsync(
          () => cache.put('A', CachedCase(storedAt: instant, lost: lost())),
        );
        final cases = FakeCases()..failRead = true;
        final c = ProviderContainer(
          overrides: [
            caseCacheRepositoryProvider.overrideWithValue(cache),
            lostCaseRepositoryProvider.overrideWithValue(cases),
            caseSessionProvider.overrideWith(
              (ref) => Stream.value(const AuthSession(userId: 'A')),
            ),
          ],
        );
        final key = GlobalKey();
        await tester.binding.setSurfaceSize(
          small ? const Size(320, 500) : const Size(390, 844),
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: c,
            child: MaterialApp(
              theme: AppTheme.light,
              home: MediaQuery(
                data: MediaQueryData(
                  size: small ? const Size(320, 500) : const Size(390, 844),
                  disableAnimations: true,
                  textScaler: TextScaler.linear(small ? 2 : 1),
                ),
                child: RepaintBoundary(
                  key: key,
                  child: CaseDetailScreen(
                    id: 'case',
                    contact: const Text('PRIVATE CONTACT'),
                    timelineAction: const Text('REMOTE TIMELINE'),
                    shareActionBuilder: (_, _, _) => const Text('SHARE'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.runAsync(
          () => c.read(publicCaseViewModelProvider('case').future),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('Copia sin conexión'), findsOneWidget);
        expect(find.text('Actualizar'), findsOneWidget);
        expect(find.text('PRIVATE CONTACT'), findsNothing);
        expect(find.text('REMOTE TIMELINE'), findsNothing);
        expect(find.text('SHARE'), findsNothing);
        expect(find.byType(ZoneMapPicker), findsNothing);
        expect(
          tester.widget<CasePhotoView>(find.byType(CasePhotoView).first).image,
          isA<MemoryImage>(),
        );
        expect(tester.takeException(), isNull);
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final img = await boundary.toImage(pixelRatio: 1);
          final data = await img.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'build/offline-case-${small ? 'small' : 'normal'}.png',
          ).writeAsBytes(data!.buffer.asUint8List());
          img.dispose();
        });
        await tester.pumpWidget(const SizedBox());
        c.dispose();
        await tester.binding.setSurfaceSize(null);
      },
    );
  }
}
