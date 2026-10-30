import 'dart:async';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/international_phone_field.dart';
import 'package:flutter_application_entrehuellas/features/case_contacts/data/models/case_contact_dto.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/case_public_screen_shell.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/case_contacts/domain/entities/case_contact.dart';
import 'package:flutter_application_entrehuellas/features/case_contacts/domain/repositories/case_contact_repository.dart';
import 'package:flutter_application_entrehuellas/features/case_contacts/domain/use_cases/case_contact_actions.dart';
import 'package:flutter_application_entrehuellas/features/case_contacts/providers/case_contact_providers.dart';
import 'package:flutter_application_entrehuellas/features/case_contacts/presentation/widgets/case_contact_panel.dart';
import 'package:flutter_application_entrehuellas/features/case_contacts/presentation/view_models/case_contact_view_model.dart';
import 'alert_preferences_test.dart' show loadFonts;

const target = (source: 'lost', id: 'case');

class FakeContactRepository implements CaseContactRepository {
  CaseContact? contact;
  int version = 0, failures = 0, opened = 0;
  Completer<void>? pending;
  final drafts = <CaseContactDraft>[];
  @override
  Future<CaseContactAccess> read(
    String owner,
    CaseContactTarget target,
  ) async => CaseContactAccess(
    contact: contact,
    canEdit: owner == 'one',
    version: version,
    suggestedName: owner == 'one' ? 'Lucía Torres' : '',
    suggestedPhone: owner == 'one' ? '+51911111111' : '',
  );
  @override
  Future<CaseContactAccess> save(
    String owner,
    CaseContactTarget target,
    CaseContactDraft draft,
  ) async {
    drafts.add(draft);
    if (pending != null) await pending!.future;
    if (failures-- > 0) {
      throw const CaseContactFailure(CaseContactFailureKind.unavailable);
    }
    if (owner != 'one') {
      throw const CaseContactFailure(CaseContactFailureKind.forbidden);
    }
    version++;
    contact = draft.enabled
        ? CaseContact(
            name: draft.name,
            phone: draft.phone,
            sharePhoto: draft.sharePhoto,
          )
        : null;
    return read(owner, target);
  }

  @override
  Future<void> open(String phone, {required bool message}) async {
    opened++;
  }
}

void main() {
  test(
    'Private profile suggestions are accepted only in the author projection',
    () {
      final owner = CaseContactDto.fromMap({
        'can_edit': true,
        'suggested_phone': '+51900000000',
      });
      expect(owner.suggestedPhone, '+51900000000');
      final viewer = CaseContactDto.fromMap({
        'can_edit': false,
        'suggested_name': 'Private',
        'suggested_phone': '+51900000000',
      });
      expect(viewer.suggestedPhone, isEmpty);
      expect(viewer.suggestedName, isEmpty);
    },
  );

  test(
    'Contact validation normalizes before persistence; no unconsented fields',
    () async {
      final repo = FakeContactRepository();
      final save = SaveCaseContact(repo);
      await expectLater(
        () => save(
          'one',
          target,
          const CaseContactDraft(
            enabled: true,
            name: 'A',
            phone: '+51900000000',
            sharePhoto: true,
            version: 0,
          ),
        ),
        throwsA(isA<CaseContactFailure>()),
      );
      expect(repo.drafts, isEmpty);
      await save(
        'one',
        target,
        const CaseContactDraft(
          enabled: true,
          name: '  Lucía Torres  ',
          phone: '+51 (900) 000-000',
          sharePhoto: true,
          version: 0,
        ),
      );
      expect(repo.drafts.last.name, 'Lucía Torres');
      expect(repo.drafts.last.phone, '+51900000000');
      await save(
        'one',
        target,
        const CaseContactDraft(
          enabled: false,
          name: 'No compartir',
          phone: 'privado',
          sharePhoto: true,
          version: 1,
        ),
      );
      expect(repo.drafts.last.name, '');
      expect(repo.drafts.last.phone, '');
      expect(repo.drafts.last.sharePhoto, isFalse);
    },
  );

  test(
    'Ambiguous contact retry freezes payload, blocks duplicates and ignores old identity completion',
    () async {
      final repo = FakeContactRepository()..failures = 1;
      final session = StreamController<AuthSession?>();
      final container = ProviderContainer(
        overrides: [
          caseContactRepositoryProvider.overrideWithValue(repo),
          caseContactSessionProvider.overrideWith((ref) => session.stream),
        ],
      );
      final subscription = container.listen(
        caseContactViewModelProvider(target),
        (_, _) {},
      );
      addTearDown(() async {
        subscription.close();
        container.dispose();
        await session.close();
      });
      session.add(const AuthSession(userId: 'one'));
      await container.read(caseContactViewModelProvider(target).future);
      final vm = container.read(caseContactViewModelProvider(target).notifier);
      const first = CaseContactDraft(
        enabled: true,
        name: 'Lucía Torres',
        phone: '+51900000000',
        sharePhoto: false,
        version: 0,
      );
      await vm.save(first);
      expect(
        container
            .read(caseContactViewModelProvider(target))
            .requireValue
            .pending,
        first,
      );
      await vm.save(
        const CaseContactDraft(
          enabled: true,
          name: 'Cambio tardío',
          phone: '+51911111111',
          sharePhoto: true,
          version: 0,
        ),
      );
      expect(repo.drafts.last.name, first.name);
      expect(repo.drafts.last.phone, first.phone);
      expect(
        container
            .read(caseContactViewModelProvider(target))
            .requireValue
            .confirmed,
        isTrue,
      );
      repo.contact = null;
      await vm.open(message: false);
      expect(repo.opened, 0); // consent was withdrawn after loading the card
      expect(
        container
            .read(caseContactViewModelProvider(target))
            .requireValue
            .access
            .contact,
        isNull,
      );
      vm.retry();
      await container.read(caseContactViewModelProvider(target).future);
      repo.pending = Completer<void>();
      final request = vm.save(first);
      await vm.save(first);
      final attempts = repo.drafts.length;
      session.add(const AuthSession(userId: 'two'));
      await Future<void>.delayed(Duration.zero);
      await container.read(caseContactViewModelProvider(target).future);
      repo.pending!.complete();
      await request;
      expect(repo.drafts.length, attempts);
      expect(
        container.read(caseContactViewModelProvider(target)).requireValue.owner,
        'two',
      );
      expect(
        container
            .read(caseContactViewModelProvider(target))
            .requireValue
            .access
            .canEdit,
        isFalse,
      );
      expect(
        container
            .read(caseContactViewModelProvider(target))
            .requireValue
            .confirmed,
        isFalse,
      );
    },
  );

  for (final small in [false, true]) {
    testWidgets(
      'Reporter contact real actions and consent editing fit; small=$small',
      (tester) async {
        await tester.runAsync(loadFonts);
        tester.view.physicalSize = small
            ? const Size(320, 350)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = FakeContactRepository();
        final scope = ProviderContainer(
          overrides: [
            caseContactRepositoryProvider.overrideWithValue(repo),
            caseContactSessionProvider.overrideWith(
              (ref) => Stream.value(const AuthSession(userId: 'one')),
            ),
          ],
        );
        addTearDown(scope.dispose);
        final boundary = GlobalKey();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: scope,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(small ? 2 : 1),
                  disableAnimations: small,
                ),
                child: child!,
              ),
              home: RepaintBoundary(
                key: boundary,
                child: const CasePublicScreenShell(
                  loading: false,
                  child: CaseContactPanel(target: target),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Compartir mi contacto'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Compartir mi contacto'));
        await tester.pumpAndSettle();
        // A profile phone is only a suggestion; neither consent is automatic.
        final consent = find.widgetWithText(
          SwitchListTile,
          'Compartir contacto en esta ficha',
        );
        expect(tester.widget<SwitchListTile>(consent).value, isFalse);
        expect(repo.contact, isNull);
        await tester.ensureVisible(consent);
        await tester.tap(consent);
        await tester.pumpAndSettle();
        final phone = find.widgetWithText(
          InternationalPhoneField,
          'Teléfono de contacto',
        );
        expect(
          tester.widget<InternationalPhoneField>(phone).controller.text,
          '+51911111111',
        );
        expect(
          tester
              .widget<SwitchListTile>(
                find.widgetWithText(
                  SwitchListTile,
                  'Compartir mi foto de perfil',
                ),
              )
              .value,
          isFalse,
        );
        await tester.ensureVisible(phone);
        await tester.enterText(
          find.descendant(of: phone, matching: find.byType(TextField)),
          '900 000 000',
        );
        final button = find.widgetWithText(FilledButton, 'Guardar contacto');
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(repo.contact!.name, 'Lucía Torres');
        expect(repo.contact!.phone, '+51900000000');
        expect(repo.contact!.sharePhoto, isFalse);
        await tester.pump(const Duration(seconds: 7));
        await tester.pumpAndSettle();
        final call = find.byTooltip('Llamar al reportante');
        await tester.ensureVisible(call);
        await tester.pumpAndSettle();
        await tester.tap(call);
        await tester.pumpAndSettle();
        expect(repo.opened, 1);
        expect(tester.takeException(), isNull);
        if (Platform.environment['CAPTURE_PUBLIC_CARDS'] == '1') {
          await tester.runAsync(() async {
            final image =
                await (boundary.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final folder = Directory('build/ui-preview/public-cards')
              ..createSync(recursive: true);
            await File(
              '${folder.path}/contact-${small ? 'small' : 'normal'}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      },
    );
  }
}
