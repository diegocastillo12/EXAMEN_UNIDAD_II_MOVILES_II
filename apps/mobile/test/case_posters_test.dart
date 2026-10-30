import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/domain/entities/case_poster.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/data/models/poster_payload.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/data/data_sources/poster_case_source.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/data/data_sources/poster_document_source.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/data/data_sources/pdf_poster_document_source.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/data/repositories/case_poster_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/providers/case_poster_providers.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/presentation/view_models/case_poster_view_model.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/presentation/screens/case_poster_screen.dart';
import 'alert_preferences_test.dart' show loadFonts;
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'access_test.dart' show FakeAccess;
import 'support/fake_password_recovery.dart';
import 'support/fake_profile.dart';

const target = PosterCase(
  PosterSource.lost,
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa90',
);

class CaseSourceFake implements PosterCaseSource {
  Uint8List? loadedPhoto;
  String owner = 'a', revision = 'revision-one';
  PosterFailure? failure;
  int calls = 0;
  Completer<PosterPayload>? pending;
  @override
  void checkOwner(String value) {
    if (value != owner) throw const PosterFailure(PosterFailureKind.forbidden);
  }

  @override
  Future<PosterPayload> prepare(String owner, PosterCase target) async {
    checkOwner(owner);
    calls++;
    if (failure != null) throw failure!;
    if (pending != null) return pending!.future;
    return PosterPayload({
      'id': target.id,
      'source': target.source.name,
      'public_slug': 'a' * 64,
      'revision': revision,
      'name': 'Luna',
      'species': 'dog',
      'report_kind': target.source == PosterSource.lost
          ? 'own_loss'
          : 'legacy_found',
      'traits': 'Collar rojo y una mancha blanca en el pecho.',
      'occurred_at': '2026-10-15T12:00:00Z',
      'photo_path': 'PUBLIC_PROCESSED_ONLY.jpg',
    });
  }

  @override
  Future<Uint8List> photo(String owner, PosterCase target, String path) async {
    checkOwner(owner);
    expect(path, 'PUBLIC_PROCESSED_ONLY.jpg');
    return loadedPhoto ??
        await File('assets/onboarding/dog_with_map.png').readAsBytes();
  }
}

class ExportSourceFake implements PosterExportSource {
  int calls = 0;
  PosterExportResult result = PosterExportResult.cancelled;
  PosterDocument? last;
  @override
  Future<PosterExportResult> export(
    PosterDocument document,
    PosterExportAction action,
  ) async {
    calls++;
    last = document;
    return result;
  }
}

class FastDocumentSource implements PosterDocumentSource {
  @override
  Future<Uint8List> render(PosterContent value) async =>
      Uint8List.fromList([37, 80, 68, 70]);
}

PdfPosterDocumentSource realRenderer() => PdfPosterDocumentSource(
  regularFont: () async => ByteData.sublistView(
    await File('assets/fonts/Roboto-Regular.ttf').readAsBytes(),
  ),
  boldFont: () async => ByteData.sublistView(
    await File('assets/fonts/Roboto-Bold.ttf').readAsBytes(),
  ),
);
CasePosterRepositoryImpl repository(
  CaseSourceFake source,
  ExportSourceFake exporter, {
  bool ready = true,
  PosterDocumentSource? renderer,
  String base = 'https://qr.example.test',
}) => CasePosterRepositoryImpl(
  source,
  renderer ?? FastDocumentSource(),
  exporter,
  webBaseUrl: base,
  publicWebReady: ready,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Poster route follows session/onboarding guards and rejects invalid origins',
    (tester) async {
      final auth = FakeAuthRepository()
        ..current = const AuthSession(userId: 'a');
      final recovery = FakePasswordRecovery();
      final container = ProviderContainer(
        overrides: [
          startupStateProvider.overrideWithValue(
            const StartupState(StartupStatus.ready),
          ),
          authRepositoryProvider.overrideWithValue(auth),
          accessRepositoryProvider.overrideWithValue(FakeAccess()),
          onboardingRepositoryProvider.overrideWithValue(
            FakeOnboarding(auth)..completed.add('a'),
          ),
          passwordRecoveryRepositoryProvider.overrideWithValue(recovery),
          profileRepositoryProvider.overrideWithValue(FakeProfile()),
          casePosterRepositoryProvider.overrideWithValue(
            repository(CaseSourceFake(), ExportSourceFake()),
          ),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const EntreHuellasApp(),
        ),
      );
      await tester.pumpAndSettle();
      final router = container.read(routerProvider);
      router.go('/home/posters/lost/${target.id}');
      await tester.pumpAndSettle();
      expect(find.byType(CasePosterScreen), findsOneWidget);
      router.go('/home/posters/invalid/${target.id}');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/home');
      auth.emit(null);
      await tester.pumpAndSettle();
      router.go('/home/posters/lost/${target.id}');
      await tester.pumpAndSettle();
      expect(find.byType(CasePosterScreen), findsNothing);
      expect(find.text('Iniciar sesión'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      container.dispose();
      await auth.controller.close();
      await recovery.events.close();
    },
  );
  test(
    'No poster or durable link is created before a real HTTPS website is enabled',
    () async {
      final source = CaseSourceFake(), exporter = ExportSourceFake();
      for (final repo in [
        repository(source, exporter, ready: false),
        repository(source, exporter, base: ''),
        repository(source, exporter, base: 'http://unsafe.test'),
        repository(
          source,
          exporter,
          base: 'https://example.test/?token=secret',
        ),
      ]) {
        expect(repo.configured, false);
        await expectLater(
          repo.generate('a', target),
          throwsA(isA<PosterFailure>()),
        );
      }
      expect(source.calls, 0);
    },
  );
  test(
    'Generation reuses opaque URL, exports only generated public PDF, cancellation retries, and stale/closed/revoked states block handoff',
    () async {
      final source = CaseSourceFake(), exporter = ExportSourceFake();
      final repo = repository(source, exporter);
      final doc = await repo.generate('a', target),
          again = await repo.generate('a', target);
      expect(doc.content.publicUrl, again.content.publicUrl);
      expect(doc.content.publicUrl.path, '/c/${'a' * 64}');
      expect(doc.content.publicUrl.toString(), isNot(contains(target.id)));
      expect(
        await repo.export('a', doc, PosterExportAction.sharePdf),
        PosterExportResult.cancelled,
      );
      exporter.result = PosterExportResult.handedOff;
      expect(
        await repo.export('a', doc, PosterExportAction.shareLink),
        PosterExportResult.handedOff,
      );
      expect(exporter.last, same(doc));
      expect(exporter.calls, 2);
      source.revision = 'changed';
      await expectLater(
        repo.export('a', doc, PosterExportAction.savePdf),
        throwsA(
          isA<PosterFailure>().having(
            (e) => e.kind,
            'kind',
            PosterFailureKind.stale,
          ),
        ),
      );
      source.failure = const PosterFailure(PosterFailureKind.inactive);
      await expectLater(
        repo.export('a', doc, PosterExportAction.sharePdf),
        throwsA(isA<PosterFailure>()),
      );
      source.failure = const PosterFailure(PosterFailureKind.forbidden);
      await expectLater(
        repo.export('a', doc, PosterExportAction.shareLink),
        throwsA(isA<PosterFailure>()),
      );
      expect(exporter.calls, 2);
      expect(() => doc.bytes[0] = 0, throwsUnsupportedError);
      expect(() => doc.content.photo[0] = 0, throwsUnsupportedError);
    },
  );
  test(
    'A4 PDF renders both origins, embeds printable public fields and keeps long names/traits',
    () async {
      final dir = Directory('build/poster-preview')
        ..createSync(recursive: true);
      final source = CaseSourceFake(), exporter = ExportSourceFake();
      for (final sourceKind in PosterSource.values) {
        final doc = await repository(
          source,
          exporter,
          renderer: realRenderer(),
        ).generate('a', PosterCase(sourceKind, target.id));
        expect(String.fromCharCodes(doc.bytes.take(4)), '%PDF');
        File('${dir.path}/${sourceKind.name}.pdf').writeAsBytesSync(doc.bytes);
      }
      final normal = await repository(source, exporter).generate('a', target);
      final long = PosterContent(
        target: target,
        publicUrl: normal.content.publicUrl,
        revision: 'long',
        reportKind: 'own_loss',
        name: 'W' * 80,
        species: 'other',
        speciesDetail: 'Mascota de especie distinta',
        traits: 'W' * 200,
        occurredAt: normal.content.occurredAt,
        photo: normal.content.photo,
      );
      File(
        '${dir.path}/long.pdf',
      ).writeAsBytesSync(await realRenderer().render(long));
    },
  );
  test(
    'ViewModel blocks duplicate generation, recovers failure and drops previous account document',
    () async {
      final sessions = StreamController<AuthSession?>();
      final source = CaseSourceFake(), exporter = ExportSourceFake();
      final container = ProviderContainer(
        overrides: [
          casePosterRepositoryProvider.overrideWithValue(
            repository(source, exporter),
          ),
          posterSessionProvider.overrideWith((_) => sessions.stream),
        ],
      );
      final subscription = container.listen(
        casePosterViewModelProvider(target),
        (_, _) {},
      );
      sessions.add(const AuthSession(userId: 'a'));
      await container.read(casePosterViewModelProvider(target).future);
      final vm = container.read(casePosterViewModelProvider(target).notifier);
      source.pending = Completer<PosterPayload>();
      final work = vm.generate();
      await vm.generate();
      expect(source.calls, 1);
      source.pending!.completeError(
        const PosterFailure(PosterFailureKind.unavailable),
      );
      await work;
      expect(
        container
            .read(casePosterViewModelProvider(target))
            .requireValue
            .isError,
        true,
      );
      source.pending = null;
      await vm.generate();
      expect(
        container
            .read(casePosterViewModelProvider(target))
            .requireValue
            .document,
        isNotNull,
      );
      sessions.add(const AuthSession(userId: 'b'));
      source.owner = 'b';
      await Future<void>.delayed(Duration.zero);
      final next = await container.read(
        casePosterViewModelProvider(target).future,
      );
      expect(next.owner, 'b');
      expect(next.document, isNull);
      subscription.close();
      container.dispose();
      await sessions.close();
    },
  );
  for (final small in [false, true]) {
    testWidgets(
      'Poster generation/save/share actions and retry stay reachable with enlarged text; small=$small',
      (tester) async {
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.runAsync(loadFonts);
        final source = CaseSourceFake(), exporter = ExportSourceFake();
        final key = GlobalKey();
        await tester.runAsync(() async {
          source.loadedPhoto = await File(
            'assets/onboarding/dog_with_map.png',
          ).readAsBytes();
        });
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              casePosterRepositoryProvider.overrideWithValue(
                repository(source, exporter),
              ),
              posterSessionProvider.overrideWith(
                (_) => Stream.value(const AuthSession(userId: 'a')),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: MediaQuery(
                data: MediaQueryData(
                  size: tester.view.physicalSize,
                  textScaler: TextScaler.linear(small ? 2 : 1),
                  disableAnimations: small,
                ),
                child: RepaintBoundary(
                  key: key,
                  child: const CasePosterScreen(target: target),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Generar cartel'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Generar cartel'));
        await tester.pump();
        final scope = ProviderScope.containerOf(
          tester.element(find.byType(CasePosterScreen)),
        );
        final generated = scope
            .read(casePosterViewModelProvider(target))
            .requireValue
            .document!;
        await tester.runAsync(
          () => precacheImage(
            MemoryImage(generated.content.photo),
            tester.element(find.byType(CasePosterScreen)),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 7));
        await tester.pumpAndSettle();
        for (final label in [
          'Imprimir o guardar PDF',
          'Compartir PDF',
          'Compartir enlace',
        ]) {
          await tester.ensureVisible(find.text(label));
          await tester.pumpAndSettle();
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 7));
          await tester.pumpAndSettle();
        }
        expect(exporter.calls, 3);
        await Scrollable.ensureVisible(
          tester.element(find.text('Compartir enlace')),
          alignment: .5,
        );
        await tester.pumpAndSettle();
        if (const bool.fromEnvironment('CAPTURE_POSTERS')) {
          await tester.runAsync(() async {
            final snapshot =
                await (key.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await snapshot.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final dir = Directory('build/ui-preview/posters')
              ..createSync(recursive: true);
            File(
              '${dir.path}/${small ? 'small' : 'normal'}.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            snapshot.dispose();
          });
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}
