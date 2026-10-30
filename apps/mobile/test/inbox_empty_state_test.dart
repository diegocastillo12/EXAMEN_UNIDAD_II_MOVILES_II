import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/collection_empty_state.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/notifications/domain/entities/notification.dart';
import 'package:flutter_application_entrehuellas/features/notifications/presentation/screens/inbox_screen.dart';
import 'notifications_test.dart' show FakeNotifications, scope;
import 'alert_preferences_test.dart' show loadFonts;

class _EmptyNotifications extends FakeNotifications {
  @override
  Future<NotificationPage> list(String owner, String? before) async {
    await pending?.future;
    if (issue != null) throw NotificationFailure(issue!);
    return NotificationPage([], null);
  }
}

void main() {
  for (final small in [false, true]) {
    for (final failure in [false, true]) {
      testWidgets(
        'Inbox confirms empty only after successful read; small=$small failure=$failure',
        (tester) async {
          await tester.runAsync(loadFonts);
          tester.view.physicalSize = small
              ? const Size(320, 350)
              : const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final repo = _EmptyNotifications()..pending = Completer<void>();
          final container = scope(repo);
          addTearDown(container.dispose);
          final boundary = GlobalKey();
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: RepaintBoundary(
                key: boundary,
                child: MaterialApp(
                  theme: AppTheme.light,
                  debugShowCheckedModeBanner: false,
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(small ? 2 : 1),
                      disableAnimations: small,
                    ),
                    child: child!,
                  ),
                  home: const InboxScreen(),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(find.byType(CollectionEmptyState), findsNothing);
          if (failure) repo.issue = NotificationIssue.unavailable;
          repo.pending!.complete();
          await tester.pumpAndSettle();
          expect(
            find.byType(CollectionEmptyState),
            failure ? findsNothing : findsOneWidget,
          );
          if (failure) {
            repo.issue = null;
            await tester.ensureVisible(find.text('Reintentar').last);
            await tester.tap(find.text('Reintentar').last);
            await tester.pumpAndSettle();
            expect(find.byType(CollectionEmptyState), findsOneWidget);
          }
          if (!failure) {
            await tester.runAsync(() async {
              final render =
                  boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary;
              final image = await render.toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final dir = Directory('build/ui-preview/notifications')
                ..createSync(recursive: true);
              File(
                '${dir.path}/${small ? '320' : '390'}-empty-inbox.png',
              ).writeAsBytesSync(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
          await tester.ensureVisible(
            find.text(
              'Sigue casos o ubicaciones y activa tus preferencias para recibir novedades.',
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        },
      );
    }
  }
}
