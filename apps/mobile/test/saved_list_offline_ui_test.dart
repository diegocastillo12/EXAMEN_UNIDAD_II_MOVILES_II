import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/core/domain/entities/public_case_card.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/domain/repositories/saved_list_file_repository.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/data/models/saved_list_file_dto.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/providers/saved_cases_providers.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/presentation/widgets/saved_cases_section.dart';
import 'package:flutter_application_entrehuellas/features/saved_cases/presentation/view_models/saved_case_list_view_model.dart';
import 'saved_list_offline_test.dart' show RemoteCases, card;
import 'alert_preferences_test.dart' show loadFonts;

class MemoryList implements SavedListFileRepository {
  List<PublicCaseCard>? items;
  @override
  Future<void> save(String owner, List<PublicCaseCard> items) async {
    this.items = items;
  }

  @override
  Future<List<PublicCaseCard>?> read(String owner) async => items;
  @override
  Future<void> clearAll() async {
    items = null;
  }
}

void main() {
  for (final width in [390.0, 320.0]) {
    testWidgets('Offline list action and fallback at width $width', (
      tester,
    ) async {
      await tester.runAsync(loadFonts);
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final files = MemoryList();
      final remote = RemoteCases()
        ..items = [
          for (final name in ['Luna Prueba', 'Max Prueba'])
            SavedListFileDto.decode(SavedListFileDto.encode(card(name))),
        ];
      final container = ProviderContainer(
        overrides: [
          savedCasesRepositoryProvider.overrideWithValue(remote),
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
                    child: const SavedCasesSection(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Guardar sin conexión'), findsOneWidget);
      await tester.tap(find.text('Guardar sin conexión'));
      await tester.runAsync(() async {
        for (
          var i = 0;
          i < 50 &&
              container
                  .read(savedCaseListViewModelProvider)
                  .requireValue
                  .saving;
          i++
        ) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      });
      await tester.pumpAndSettle();
      expect(
        container
            .read(savedCaseListViewModelProvider)
            .requireValue
            .noticeIsError,
        isFalse,
      );
      remote.offline = true;
      await tester.runAsync(
        () => container.read(savedCaseListViewModelProvider.notifier).refresh(),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Sin conexión'), findsOneWidget);
      expect(find.text('Luna Prueba'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final output = File('build/ui-preview/saved-list-offline-$width.png');
        await output.parent.create(recursive: true);
        await output.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox());
    });
  }
}
