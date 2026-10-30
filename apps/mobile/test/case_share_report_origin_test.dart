import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_entrehuellas/app/navigation/entity_editor_page.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/domain/entities/case_poster.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/providers/case_poster_providers.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/presentation/widgets/case_share_button.dart';
import 'package:flutter_application_entrehuellas/features/case_posters/presentation/widgets/case_share_sheet.dart';
import 'package:flutter_application_entrehuellas/features/content_reports/providers/content_report_providers.dart';
import 'package:flutter_application_entrehuellas/features/content_reports/presentation/screens/content_report_screen.dart';
import 'case_sharing_test.dart' show ShareRepositoryFake;
import 'content_reports_test.dart' show FakeReports;
import 'alert_preferences_test.dart' show loadFonts;

void main() {
  for (final kind in ['lost', 'found']) {
    for (final small in [false, true]) {
      for (final reduced in [false, true]) {
        testWidgets('Report from share retains panel and reverses to origin '
            '$kind small=$small reduced=$reduced', (tester) async {
          await tester.runAsync(() async {
            await loadFonts();
            await (FontLoader(
                  'Poppins',
                )..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf')))
                .load();
          });
          tester.view.physicalSize = small
              ? const Size(320, 600)
              : const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          const id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa29';
          OriginPageSource? source;
          final boundary = GlobalKey();
          Future<void> capture(String frame) async {
            if (!captureEnabled || reduced || kind != 'lost') return;
            await tester.runAsync(() async {
              final image =
                  await (boundary.currentContext!.findRenderObject()
                          as RenderRepaintBoundary)
                      .toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final folder = Directory('build/ui-preview/share-report-origin')
                ..createSync(recursive: true);
              await File(
                '${folder.path}/${small ? 'small' : 'normal'}-$frame.png',
              ).writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }

          final router = GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, _) => Scaffold(
                  body: Center(
                    child: CaseShareButton(
                      target: PosterCase(
                        kind == 'lost' ? PosterSource.lost : PosterSource.found,
                        id,
                      ),
                      title: 'Bruno',
                      eventLabel: 'Mascota perdida',
                      onReport: (value) {
                        source = value;
                        return context.push<void>('/denounce', extra: value);
                      },
                    ),
                  ),
                ),
              ),
              GoRoute(
                path: '/denounce',
                pageBuilder: (context, state) => entityEditorPage(
                  context: context,
                  key: state.pageKey,
                  source: state.extra,
                  child: ContentReportScreen(target: (kind: kind, id: id)),
                ),
              ),
            ],
          );
          addTearDown(router.dispose);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                caseShareRepositoryProvider.overrideWithValue(
                  ShareRepositoryFake(),
                ),
                posterSessionProvider.overrideWith(
                  (ref) => Stream.value(const AuthSession(userId: 'actor')),
                ),
                contentReportRepositoryProvider.overrideWithValue(
                  FakeReports(),
                ),
                reportSessionProvider.overrideWith(
                  (ref) => Stream.value(const AuthSession(userId: 'actor')),
                ),
              ],
              child: MaterialApp.router(
                theme: AppTheme.light,
                routerConfig: router,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(small ? 2 : 1),
                    disableAnimations: reduced,
                  ),
                  child: RepaintBoundary(key: boundary, child: child!),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Compartir ficha'));
          await tester.pumpAndSettle();
          final report = find.byTooltip('Denunciar contenido');
          await tester.ensureVisible(report);
          await tester.pumpAndSettle();
          final origin = tester.getRect(report);
          final sheet = tester.element(find.byType(CaseShareSheet));
          final surface = find.byKey(const ValueKey('origin-surface'));
          for (var iteration = 0; iteration < 2; iteration++) {
            await tester.tap(report);
            await tester.pump();
            expect(source!.bounds, origin);
            expect(source!.color, const Color(0xFFEEEEF0));
            expect(source!.radius, 28);
            expect(
              find.byType(CaseShareSheet, skipOffstage: false),
              findsOneWidget,
            );
            if (!reduced) {
              expect(tester.getRect(surface), origin);
              if (iteration == 0) await capture('open-0');
              await tester.pump(const Duration(milliseconds: 16));
              if (iteration == 0) await capture('open-5');
              await tester.pump(const Duration(milliseconds: 32));
              if (iteration == 0) await capture('open-15');
              expect(tester.getRect(surface).width, greaterThan(origin.width));
              expect(
                tester.getRect(surface).width,
                lessThan(tester.view.physicalSize.width),
              );
              expect(
                find.byKey(const ValueKey('origin-page-source')),
                findsOneWidget,
              );
              await tester.pump(const Duration(milliseconds: 96));
              if (iteration == 0) await capture('open-45');
              await tester.pump(const Duration(milliseconds: 173));
              if (iteration == 0) await capture('open-99');
            } else {
              expect(surface, findsNothing);
            }
            await tester.pumpAndSettle();
            if (iteration == 0) await capture('open-100');
            expect(find.byType(ContentReportScreen), findsOneWidget);
            // Back from the real form must pop the page above the pageless sheet.
            await tester.tap(find.byTooltip('Volver'));
            await tester.pump();
            // The form waits for endOfFrame before committing its guarded pop.
            await tester.pump();
            if (!reduced) {
              await tester.pump(const Duration(milliseconds: 130));
              if (iteration == 0) await capture('close-50');
              await tester.pump(const Duration(milliseconds: 65));
              if (iteration == 0) await capture('close-75');
              expect(
                tester.getRect(surface).width,
                inExclusiveRange(origin.width, tester.view.physicalSize.width),
              );
              expect(
                find.byKey(const ValueKey('origin-page-source')),
                findsOneWidget,
              );
              await tester.pump(const Duration(milliseconds: 52));
              if (iteration == 0) await capture('close-95');
            }
            await tester.pumpAndSettle();
            expect(find.byType(ContentReportScreen), findsNothing);
            expect(tester.element(find.byType(CaseShareSheet)), same(sheet));
            expect(tester.getRect(report), origin);
            expect(tester.takeException(), isNull);
          }
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.byType(CaseShareSheet), findsNothing);
        });
      }
    }
  }
}

final captureEnabled =
    Platform.environment['CAPTURE_SHARE_REPORT_ORIGIN'] == '1';
