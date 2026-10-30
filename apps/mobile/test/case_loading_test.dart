import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_photo.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_public_cards_skeleton.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/glass_navigation_button.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/loading_shimmer.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/skeleton_form_fields.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/providers/lost_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/providers/found_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/presentation/screens/case_detail_screen.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/screens/found_detail_screen.dart';
import 'lost_cases_test.dart' show FakeCases;
import 'found_cases_test.dart' show FakeFoundCases;
import 'alert_preferences_test.dart' show loadFonts;

class _DeferredImage extends ImageProvider<_DeferredImage> {
  final frame = Completer<ImageInfo>();
  @override
  Future<_DeferredImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);
  @override
  ImageStreamCompleter loadImage(
    _DeferredImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(frame.future);
}

void main() {
  for (final found in [false, true]) {
    for (final small in [false, true]) {
      testWidgets(
        'Case loading uses public geometry: found=$found small=$small',
        (tester) async {
          if (Platform.environment['CAPTURE_CASE_LOADING'] == '1') {
            await tester.runAsync(loadFonts);
          }
          tester.view.physicalSize = small
              ? const Size(320, 350)
              : const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final pending = Completer<void>();
          final lost = FakeCases()..pendingRead = pending;
          final reports = FakeFoundCases()..pendingRead = pending;
          final scope = ProviderContainer(
            overrides: [
              lostCaseRepositoryProvider.overrideWithValue(lost),
              foundCaseRepositoryProvider.overrideWithValue(reports),
              caseSessionProvider.overrideWith(
                (ref) => Stream.value(const AuthSession(userId: 'one')),
              ),
              foundSessionProvider.overrideWith(
                (ref) => Stream.value(const AuthSession(userId: 'one')),
              ),
            ],
          );
          addTearDown(scope.dispose);
          final boundary = GlobalKey();
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: scope,
              child: RepaintBoundary(
                key: boundary,
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Builder(
                    builder: (context) => MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(small ? 2 : 1),
                        disableAnimations: small,
                      ),
                      child: found
                          ? const FoundDetailScreen(id: 'case')
                          : const CaseDetailScreen(id: 'case'),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 200));
          expect(find.byType(CasePublicCardsSkeleton), findsOneWidget);
          expect(find.byType(SkeletonFormFields), findsNothing);
          expect(find.text('Ficha pública'), findsOneWidget);
          expect(find.byType(LoadingShimmer), findsOneWidget);
          final semantics = tester.ensureSemantics();
          expect(
            find.bySemanticsLabel('Consultando ficha del caso'),
            findsOneWidget,
          );
          expect(
            tester.getRect(find.byType(GlassNavigationButton)).top,
            greaterThanOrEqualTo(0),
          );
          Future<void> capture(String stage) async {
            if (Platform.environment['CAPTURE_CASE_LOADING'] != '1') return;
            await tester.runAsync(() async {
              final image =
                  await (boundary.currentContext!.findRenderObject()
                          as RenderRepaintBoundary)
                      .toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final folder = Directory('build/ui-preview/case-loading')
                ..createSync(recursive: true);
              await File(
                '${folder.path}/${found ? 'found' : 'lost'}-${small ? 'small' : 'normal'}-$stage.png',
              ).writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }

          await capture('top');
          await tester.ensureVisible(
            find.byKey(const ValueKey('case-skeleton-map')),
          );
          await tester.pump();
          await capture('map');
          expect(tester.takeException(), isNull);
          pending.complete();
          await tester.pumpAndSettle();
          expect(find.byType(CasePublicCardsSkeleton), findsNothing);
          expect(find.byType(LoadingShimmer), findsNothing);
          expect(find.text('Ficha pública'), findsOneWidget);
          expect(tester.takeException(), isNull);
          semantics.dispose();
        },
      );
    }
  }
  for (final fail in [false, true]) {
    testWidgets('Photo shimmer resolves to frame or toast; fail=$fail', (
      tester,
    ) async {
      final provider = _DeferredImage();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: CasePhotoView(
                image: provider,
                semanticLabel: 'Foto de Luna',
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CasePhotoSkeleton), findsOneWidget);
      final before = tester.getRect(find.byType(CasePhotoView));
      if (fail) {
        provider.frame.completeError(StateError('unavailable'));
      } else {
        await tester.runAsync(() async {
          final recorder = ui.PictureRecorder();
          Canvas(recorder).drawRect(
            const Rect.fromLTWH(0, 0, 2, 2),
            Paint()..color = Colors.black,
          );
          final picture = recorder.endRecording();
          final image = await picture.toImage(2, 2);
          picture.dispose();
          provider.frame.complete(ImageInfo(image: image));
        });
      }
      await tester.pumpAndSettle();
      expect(find.byType(CasePhotoSkeleton), findsNothing);
      expect(tester.getRect(find.byType(CasePhotoView)), before);
      expect(
        find.text('Foto no disponible. Vuelve a consultar para reintentar.'),
        fail ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
