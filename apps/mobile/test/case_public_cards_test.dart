import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/case_contacts/domain/entities/case_contact.dart';
import 'package:flutter_application_entrehuellas/features/case_contacts/providers/case_contact_providers.dart';
import 'package:flutter_application_entrehuellas/features/case_contacts/presentation/widgets/case_contact_panel.dart';
import 'case_contacts_test.dart' show FakeContactRepository;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_public_cards.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_public_screen_shell.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/collection_add_button.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/glass_navigation_button.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/zone_map_picker.dart';
import 'alert_preferences_test.dart' show loadFonts;

void main() {
  for (final small in [false, true]) {
    for (final reduced in [false, true]) {
      testWidgets(
        'Public cards gallery, public map and actions; small=$small reduced=$reduced',
        (tester) async {
          await tester.runAsync(() async {
            await loadFonts();
            final font = FontLoader('Poppins')
              ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
            await font.load();
          });
          tester.view.physicalSize = small
              ? const Size(320, 350)
              : const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          tester.view.padding = const FakeViewPadding(top: 24, bottom: 34);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPadding);
          final boundary = GlobalKey();
          var shares = 0, sightings = 0, backs = 0;
          final contacts = FakeContactRepository()
            ..contact = const CaseContact(
              name: 'Lucía Torres',
              phone: '+51900000000',
            );
          await tester.pumpWidget(
            MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              builder: (context, child) => ProviderScope(
                overrides: [
                  caseContactRepositoryProvider.overrideWithValue(contacts),
                  caseContactSessionProvider.overrideWith(
                    (ref) => Stream.value(const AuthSession(userId: 'two')),
                  ),
                ],
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(small ? 2 : 1),
                    disableAnimations: reduced,
                  ),
                  child: child!,
                ),
              ),
              home: RepaintBoundary(
                key: boundary,
                child: CasePublicScreenShell(
                  loading: false,
                  onBack: () => backs++,
                  shareAction: GlassNavigationButton(
                    tooltip: 'Compartir ficha',
                    icon: Icons.ios_share_rounded,
                    onPressed: () => shares++,
                  ),
                  child: CasePublicCards(
                    contact: const CaseContactPanel(
                      target: (source: 'lost', id: 'case'),
                    ),
                    name: small
                        ? 'Bruno de nombre extraordinariamente largo'
                        : 'Bruno',
                    eventLabel: 'Perdido',
                    photos: [
                      Image.asset(
                        'assets/illustrations/community_pets.png',
                        fit: BoxFit.cover,
                      ),
                      const ColoredBox(color: Color(0xFF8C9CAC)),
                    ],
                    facts: const [
                      CasePublicFact('Especie', 'Perro'),
                      CasePublicFact('Sexo', 'Macho'),
                      CasePublicFact('Tamaño', 'Mediano'),
                      CasePublicFact('Edad', '24 meses'),
                    ],
                    description:
                        'Pelaje dorado, pecho blanco y collar azul. Tiene una pequeña marca en la oreja izquierda y suele esconderse cerca de los árboles cuando escucha ruidos fuertes.',
                    occurredAt: 'Desaparición: 20/10/2026 09:30',
                    locationLabel: 'Ubicación de desaparición',
                    latitude: -12.045,
                    longitude: -77.045,
                    privacy:
                        'Ubicación pública aproximada de unos 1 km. El punto exacto y la referencia permanecen privados.',
                    createMapTileProvider: () => NetworkTileProvider(
                      httpClient: MockClient((request) async {
                        return http.Response.bytes(
                          TileProvider.transparentImage,
                          200,
                          request: request,
                        );
                      }),
                      cachingProvider: const DisabledMapCachingProvider(),
                    ),
                    actions: CollectionAddButton(
                      label: 'Reportar avistamiento',
                      icon: Icons.visibility_outlined,
                      accented: true,
                      onAction: (_) => sightings++,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.runAsync(
            () => precacheImage(
              const AssetImage('assets/illustrations/community_pets.png'),
              boundary.currentContext!,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text('Búsqueda activa'), findsNothing);
          expect(find.text('Lucía Torres'), findsOneWidget);
          expect(find.byType(DraggableScrollableSheet), findsNothing);
          expect(find.byType(GlassNavigationButton), findsNWidgets(4));
          final header = tester.getRect(find.byTooltip('Compartir ficha'));
          if (!small) {
            final name = tester.getRect(
              find.byKey(const ValueKey('public-case-photo-name')),
            );
            final status = tester.getRect(
              find.byKey(const ValueKey('public-case-photo-status')),
            );
            final photo = tester.getRect(find.byType(PageView));
            final pagination = tester.getRect(
              find.byKey(const ValueKey('public-case-photo-pagination')),
            );
            expect(status.center.dy, closeTo(name.center.dy, 1));
            expect(status.right, closeTo(photo.right - 16, 1));
            expect(pagination.center.dx, closeTo(photo.center.dx, 1));
            expect(pagination.top, greaterThan(status.bottom));
          }
          await _capture(tester, boundary, small, reduced, 'top');
          final gallery = find.byType(PageView);
          final semantics = tester.ensureSemantics();
          await tester.ensureVisible(gallery);
          await tester.pumpAndSettle();
          final galleryRect = tester.getRect(gallery);
          final visibleTop = galleryRect.top.clamp(
            90.0,
            tester.view.physicalSize.height - 60,
          );
          await tester.dragFrom(
            Offset(260, visibleTop + 20),
            const Offset(-240, 0),
          );
          await tester.pumpAndSettle();
          expect(find.bySemanticsLabel('Foto 2 de 2'), findsOneWidget);
          await tester.ensureVisible(find.text('Ver descripción completa'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Ver descripción completa'));
          await tester.pumpAndSettle();
          expect(find.text('Mostrar menos'), findsOneWidget);
          await tester.ensureVisible(find.byType(ZoneMapPicker));
          await tester.pumpAndSettle();
          final map = tester.widget<ZoneMapPicker>(find.byType(ZoneMapPicker));
          expect(map.latitude, -12.045);
          expect(map.longitude, -77.045);
          expect(map.readOnly, isTrue);
          expect(map.onSelect, isNull);
          expect(map.radiusMeters, 1000);
          expect(map.showAttribution, isTrue);
          expect(map.compactAttribution, isTrue);
          expect(map.showCenterMarker, isFalse);
          expect(map.showRadius, isFalse);
          expect(map.markers.single.point.latitude, -12.045);
          expect(map.fitRadius, isTrue);
          await _capture(tester, boundary, small, reduced, 'map');
          final action = find.widgetWithText(
            FilledButton,
            'Reportar avistamiento',
          );
          await tester.ensureVisible(action);
          await tester.pumpAndSettle();
          expect(
            tester.getRect(action).bottom,
            lessThanOrEqualTo(tester.view.physicalSize.height - 34),
          );
          await tester.tap(action);
          await tester.tap(find.byTooltip('Compartir ficha'));
          expect(tester.getRect(find.byTooltip('Compartir ficha')), header);
          await tester.tap(find.byTooltip('Volver'));
          expect((sightings, shares, backs), (1, 1, 1));
          expect(tester.takeException(), isNull);
          await _capture(tester, boundary, small, reduced, 'actions');
          semantics.dispose();
        },
      );
    }
  }
}

Future<void> _capture(
  WidgetTester tester,
  GlobalKey key,
  bool small,
  bool reduced,
  String stage,
) async {
  if (Platform.environment['CAPTURE_PUBLIC_CARDS'] != '1') return;
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
            .toImage(pixelRatio: 1.5);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final folder = Directory('build/ui-preview/public-cards')
      ..createSync(recursive: true);
    await File(
      '${folder.path}/${small ? 'small' : 'normal'}-${reduced ? 'reduced' : 'motion'}-$stage.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
