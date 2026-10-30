import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_entrehuellas/app/navigation/entity_editor_page.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter_application_entrehuellas/features/home/presentation/widgets/home_content.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/case_matching/domain/entities/case_match.dart';
import 'package:flutter_application_entrehuellas/features/case_matching/domain/repositories/case_matching_repository.dart';
import 'package:flutter_application_entrehuellas/features/case_matching/domain/use_cases/case_match_actions.dart';
import 'package:flutter_application_entrehuellas/features/case_matching/providers/case_matching_providers.dart';
import 'package:flutter_application_entrehuellas/features/case_matching/presentation/view_models/matching_view_model.dart';
import 'package:flutter_application_entrehuellas/features/case_matching/presentation/screens/matching_screen.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/use_cases/found_case_actions.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'found_cases_test.dart' show FakeFoundCases;

const owner = 'a0000000-0000-4000-8000-000000000001';
const target = MatchReference('lost', 'a0000000-0000-4000-8000-000000000002');
final candidate = CaseMatchCandidate(
  reference: const MatchReference(
    'found',
    'a0000000-0000-4000-8000-000000000003',
  ),
  revision: 'b' * 32,
  name: 'Mascota encontrada',
  distanceMeters: 1500,
  daysApart: 2,
);
CaseMatchResult result() => CaseMatchResult(
  anchor: target,
  revision: 'a' * 32,
  model: 'clip-vit-b32-d15189d-q8-v1',
  candidates: [candidate],
  pendingPhotos: 0,
  complete: true,
);

class FakeMatching implements CaseMatchingRepository {
  final commands = <MatchReviewCommand>[];
  bool fail = false;
  int searchesCount = 0;
  Completer<void>? barrier;
  @override
  Future<List<MatchSearch>> searches(String owner) async => [
    const MatchSearch(target, 'Luna', 'dog'),
  ];
  @override
  Future<CaseMatchResult> search(String owner, MatchReference reference) async {
    searchesCount++;
    await barrier?.future;
    return result();
  }

  @override
  Future<void> review(String owner, MatchReviewCommand command) async {
    commands.add(command);
    if (fail) throw const MatchFailure(MatchIssue.unavailable);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final file = File('.dart_tool/package_config.json');
    final config =
        jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final flutter = (config['packages'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((p) => p['name'] == 'flutter');
    final fonts = file.uri
        .resolve('${flutter['rootUri']}/')
        .resolve('../../bin/cache/artifacts/material_fonts/');
    for (final entry in {
      'sans-serif': [
        'roboto-regular.ttf',
        'roboto-medium.ttf',
        'roboto-bold.ttf',
      ],
      'MaterialIcons': ['materialicons-regular.otf'],
    }.entries) {
      final loader = FontLoader(entry.key);
      for (final name in entry.value) {
        loader.addFont(
          File.fromUri(
            fonts.resolve(name),
          ).readAsBytes().then(ByteData.sublistView),
        );
      }
      await loader.load();
    }
    await (FontLoader('Poppins')..addFont(
          File(
            'assets/fonts/Poppins-Regular.ttf',
          ).readAsBytes().then(ByteData.sublistView),
        ))
        .load();
  });
  test(
    'matching domain rejects invalid references and reviews absent from a result',
    () async {
      final fake = FakeMatching();
      expect(
        () =>
            FindCaseMatches(fake)(owner, const MatchReference('other', 'bad')),
        throwsA(isA<MatchFailure>()),
      );
      final absent = CaseMatchCandidate(
        reference: const MatchReference(
          'found',
          'a0000000-0000-4000-8000-000000000004',
        ),
        revision: 'c' * 32,
        name: 'Otro',
        distanceMeters: 0,
        daysApart: 0,
      );
      expect(
        () => ReviewCaseMatch(fake)(
          owner,
          MatchReviewCommand(
            id: 'command',
            result: result(),
            candidate: absent,
            decision: 'confirmed',
          ),
        ),
        throwsA(isA<MatchFailure>()),
      );
    },
  );
  test(
    'matching VM preserves ambiguous review ID, prevents double requests and clears changed identity',
    () async {
      final fake = FakeMatching(), sessions = StreamController<AuthSession?>();
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith((ref) => sessions.stream),
          caseMatchingRepositoryProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(sessions.close);
      final subscription = container.listen(
        matchingViewModelProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      sessions.add(const AuthSession(userId: owner));
      await container.read(matchingViewModelProvider.future);
      final model = container.read(matchingViewModelProvider.notifier);
      await model.search();
      fake.fail = true;
      await model.decide(candidate, 'confirmed');
      expect(
        container
            .read(matchingViewModelProvider)
            .requireValue
            .result!
            .candidates
            .single
            .review,
        null,
      );
      fake.fail = false;
      await model.decide(candidate, 'confirmed');
      expect(fake.commands[0].id, fake.commands[1].id);
      expect(container.read(matchingViewModelProvider).requireValue.saved, 1);
      fake.barrier = Completer<void>();
      final work = model.search();
      await model.search();
      expect(fake.searchesCount, 2);
      sessions.add(null);
      await Future<void>.delayed(Duration.zero);
      fake.barrier!.complete();
      await work;
      await expectLater(
        container.read(matchingViewModelProvider.future),
        throwsA(isA<MatchFailure>()),
      );
      expect(container.read(matchingViewModelProvider).asData, null);
    },
  );
  test('independent found uses photos and description without a target', () {
    final publish = PublishFoundCase(FakeFoundCases());
    FoundCaseDraft draft({String? targetId, List<FoundPhotoDraft>? photos}) =>
        FoundCaseDraft(
          id: 'id',
          reportKind: 'independent_found',
          targetId: targetId,
          occurredAt: DateTime.utc(2026, 1, 1),
          latitude: -18,
          longitude: -70,
          placeReference: 'Parque',
          species: 'dog',
          traits: 'Orejas blancas',
          custody: 'with_me',
          photos:
              photos ??
              [
                FoundPhotoDraft(
                  'photo',
                  Uint8List.fromList([255, 216, 255, 217]),
                ),
              ],
        );
    publish.validate(draft(), DateTime.utc(2026, 10, 25));
    expect(
      () =>
          publish.validate(draft(targetId: 'case'), DateTime.utc(2026, 10, 25)),
      throwsA(isA<FoundFailure>()),
    );
    expect(
      () => publish.validate(draft(photos: []), DateTime.utc(2026, 10, 25)),
      throwsA(isA<FoundFailure>()),
    );
  });
  testWidgets(
    'matching navigation expands from its real Home control and contracts on return',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => Scaffold(
              body: Center(
                child: SizedBox(
                  width: 220,
                  height: 100,
                  child: HomeQuickAction(
                    icon: Icons.manage_search_rounded,
                    label: 'Coincidencias',
                    onTap: (source) => openHomeAction(
                      source,
                      '/home/coincidencias',
                      Icons.manage_search_rounded,
                    ),
                  ),
                ),
              ),
            ),
            routes: [
              GoRoute(
                path: 'coincidencias',
                pageBuilder: (context, state) => entityEditorPage(
                  context: context,
                  key: state.pageKey,
                  source: state.extra,
                  child: MatchingScreen(onOpen: (_, _) async {}),
                ),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(
              (ref) => Stream.value(const AuthSession(userId: owner)),
            ),
            caseMatchingRepositoryProvider.overrideWithValue(FakeMatching()),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final source = tester.getRect(find.byType(HomeQuickAction));
      await tester.tap(find.text('Coincidencias'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 160));
      final transition = tester.widget<OriginPageTransition>(
        find.byType(OriginPageTransition),
      );
      expect(transition.source!.bounds, source);
      final positioned = tester.widget<Positioned>(
        find
            .descendant(
              of: find.byType(OriginPageTransition),
              matching: find.byType(Positioned),
            )
            .first,
      );
      expect(positioned.width, greaterThan(source.width));
      expect(positioned.width, lessThan(390));
      expect(positioned.height, greaterThan(source.height));
      await tester.pumpAndSettle();
      expect(find.text('Posibles coincidencias'), findsOneWidget);
      router.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 130));
      expect(find.byType(OriginPageTransition), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Coincidencias'), findsOneWidget);
      expect(tester.takeException(), null);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  for (final config in [(390.0, 844.0, 1.0), (320.0, 500.0, 2.0)]) {
    testWidgets(
      'matching UI real actions and accessible layout ${config.$1}/${config.$3}',
      (tester) async {
        tester.view.physicalSize = Size(config.$1, config.$2);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final fake = FakeMatching();
        MatchReference? opened;
        final boundary = GlobalKey();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authSessionProvider.overrideWith(
                (ref) => Stream.value(const AuthSession(userId: owner)),
              ),
              caseMatchingRepositoryProvider.overrideWithValue(fake),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  disableAnimations: true,
                  textScaler: TextScaler.linear(config.$3),
                ),
                child: child!,
              ),
              home: RepaintBoundary(
                key: boundary,
                child: MatchingScreen(
                  onOpen: (r, origin) async {
                    opened = r;
                    expect(origin, isNotNull);
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Buscar coincidencias'));
        await tester.tap(find.text('Buscar coincidencias'));
        await tester.pumpAndSettle();
        expect(find.text('Posible coincidencia'), findsOneWidget);
        expect(tester.takeException(), null);
        await tester.ensureVisible(find.text('Ver ficha'));
        await tester.tap(find.text('Ver ficha'));
        await tester.pumpAndSettle();
        expect(opened?.key, candidate.reference.key);
        expect(tester.takeException(), null);
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            'build/ui-preview/case-matching/mobile-${config.$1.toInt()}-${config.$3.toInt()}.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
