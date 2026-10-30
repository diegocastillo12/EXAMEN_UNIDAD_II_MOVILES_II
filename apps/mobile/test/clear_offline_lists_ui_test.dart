import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/providers/saved_cases_providers.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/presentation/widgets/clear_offline_lists_button.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/presentation/view_models/clear_offline_lists_view_model.dart';
import 'saved_list_offline_ui_test.dart' show MemoryList;
import 'saved_list_offline_test.dart' show card;
import 'alert_preferences_test.dart' show loadFonts;

void main() {
  for (final width in [390.0, 320.0]) {
    testWidgets(
      'Clear action confirms outside protected screen at width $width',
      (tester) async {
        await tester.runAsync(loadFonts);
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final files = MemoryList()..items = [card('Cliente Prueba')];
        final container = ProviderContainer(
          overrides: [
            savedListFileRepositoryProvider.overrideWithValue(files),
            savedCasesSessionProvider.overrideWith(
              (ref) => Stream.value(const AuthSession(userId: 'owner')),
            ),
          ],
        );
        addTearDown(container.dispose);
        final key = GlobalKey();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(width == 320 ? 2 : 1)),
                child: child!,
              ),
              home: Scaffold(
                body: RepaintBoundary(
                  key: key,
                  child: ColoredBox(
                    color: const Color(0xFFF9FAFB),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [Text('Perfil'), ClearOfflineListsButton()],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Borrar datos de este teléfono'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Cancelar'));
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(files.items, isNotNull);
        await tester.tap(find.text('Borrar datos de este teléfono'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Borrar datos'),
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Borrar datos'));
        await tester.pumpAndSettle();
        expect(files.items, isNull);
        expect(
          container.read(clearOfflineListsViewModelProvider).error,
          isFalse,
        );
        expect(
          find.text(
            'Listas sin conexión y claves eliminadas de este teléfono.',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final output = File(
            'build/ui-preview/clear-offline-lists-$width.png',
          );
          await output.parent.create(recursive: true);
          await output.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );
  }
}
