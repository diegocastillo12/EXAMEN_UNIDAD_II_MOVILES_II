import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/user_blocks/domain/entities/user_block.dart';
import 'package:flutter_application_entrehuellas/features/user_blocks/domain/repositories/user_block_repository.dart';
import 'package:flutter_application_entrehuellas/features/user_blocks/domain/use_cases/user_block_actions.dart';
import 'package:flutter_application_entrehuellas/features/user_blocks/data/data_sources/user_block_source.dart';
import 'package:flutter_application_entrehuellas/features/user_blocks/data/repositories/user_block_repository_impl.dart';
import 'package:flutter_application_entrehuellas/features/user_blocks/providers/user_block_providers.dart';
import 'package:flutter_application_entrehuellas/features/user_blocks/presentation/view_models/user_block_view_model.dart';
import 'package:flutter_application_entrehuellas/features/user_blocks/presentation/screens/user_blocks_screen.dart';
import 'package:flutter_application_entrehuellas/features/user_blocks/presentation/widgets/user_block_controls.dart';
import 'alert_preferences_test.dart' show loadFonts;
import 'case_contacts_test.dart' show FakeContactRepository;
import 'package:flutter_application_entrehuellas/features/case_contacts/domain/entities/case_contact.dart';
import 'package:flutter_application_entrehuellas/features/case_contacts/providers/case_contact_providers.dart';
import 'package:flutter_application_entrehuellas/features/case_contacts/presentation/widgets/case_contact_panel.dart';
import 'package:flutter_application_entrehuellas/features/case_contacts/presentation/view_models/case_contact_view_model.dart';
import 'package:flutter_application_entrehuellas/app/entre_huellas_app.dart';
import 'package:flutter_application_entrehuellas/app/router.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state.dart';
import 'package:flutter_application_entrehuellas/core/config/startup_state_provider.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/password_recovery_providers.dart';
import 'package:flutter_application_entrehuellas/features/onboarding/providers/onboarding_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'app_test.dart' show FakeAuthRepository, FakeOnboarding;
import 'support/fake_password_recovery.dart';
import 'support/fake_profile.dart';

const actor = '11111111-1111-4111-8111-111111111142',
    other = '22222222-2222-4222-8222-222222222242';
const target = (kind: 'lost', id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa42');
const entry = UserBlock(
  id: 'cccccccc-cccc-4ccc-8ccc-cccccccccc42',
  label: 'Reportante de Luna',
  enabled: false,
  version: 0,
);
UserBlock changed(UserBlock b, bool enabled) => UserBlock(
  id: b.id,
  label: b.label,
  enabled: enabled,
  version: b.version + 1,
);

class FakeBlocks implements UserBlockRepository {
  UserBlock? current = entry;
  List<UserBlock> items = [];
  String? next;
  final attempts = <BlockChange>[];
  final cursors = <String?>[];
  Completer<void>? gate;
  BlockIssue? readIssue, setIssue;
  @override
  Future<UserBlock?> prepare(String actor, BlockTarget target) async {
    if (readIssue != null) throw BlockFailure(readIssue!);
    return current;
  }

  @override
  Future<UserBlockPage> list(String actor, String? before) async {
    cursors.add(before);
    if (readIssue != null) throw BlockFailure(readIssue!);
    return UserBlockPage(
      List.unmodifiable(items),
      before == null ? next : null,
    );
  }

  @override
  Future<UserBlock> set(String actor, BlockChange change) async {
    attempts.add(change);
    await gate?.future;
    if (setIssue != null) throw BlockFailure(setIssue!);
    current = changed(change.entry, change.enabled);
    items = current!.enabled ? [current!] : [];
    return current!;
  }
}

ProviderContainer container(
  FakeBlocks repo, {
  Stream<AuthSession?>? sessions,
  FakeContactRepository? contacts,
}) => ProviderContainer(
  overrides: [
    userBlockRepositoryProvider.overrideWithValue(repo),
    if (contacts != null) ...[
      caseContactRepositoryProvider.overrideWithValue(contacts),
      caseContactSessionProvider.overrideWith(
        (ref) => Stream.value(const AuthSession(userId: actor)),
      ),
    ],
    blockSessionProvider.overrideWith(
      (ref) => sessions ?? Stream.value(const AuthSession(userId: actor)),
    ),
  ],
);

class FakeBlockSource implements UserBlockSource {
  Object? raw;
  String? failure;
  String? operation;
  Map<String, dynamic>? params;
  @override
  Future<Object?> rpc(
    String actor,
    String operation,
    Map<String, dynamic> params,
  ) async {
    this.operation = operation;
    this.params = params;
    if (failure != null) throw BlockSourceFailure(failure!);
    return raw;
  }
}

class BlockAwareContactRepository extends FakeContactRepository {
  BlockAwareContactRepository(this.blocks);
  final FakeBlocks blocks;
  @override
  Future<CaseContactAccess> read(
    String owner,
    CaseContactTarget target,
  ) async => CaseContactAccess(
    contact: blocks.current?.enabled == true
        ? null
        : const CaseContact(name: 'Lucía Torres', phone: '+51900000000'),
  );
}

void main() {
  for (final stage in ['guest', 'onboarding', 'ready']) {
    testWidgets(
      'HU14.2 real router gates blocked accounts by account stage: $stage',
      (tester) async {
        final auth = FakeAuthRepository();
        if (stage != 'guest') auth.current = const AuthSession(userId: actor);
        final onboarding = FakeOnboarding(auth);
        if (stage == 'ready') onboarding.completed.add(actor);
        final c = ProviderContainer(
          overrides: [
            startupStateProvider.overrideWithValue(
              const StartupState(StartupStatus.ready),
            ),
            authRepositoryProvider.overrideWithValue(auth),
            onboardingRepositoryProvider.overrideWithValue(onboarding),
            passwordRecoveryRepositoryProvider.overrideWithValue(
              FakePasswordRecovery(),
            ),
            profileRepositoryProvider.overrideWithValue(FakeProfile()),
            userBlockRepositoryProvider.overrideWithValue(FakeBlocks()),
          ],
        );
        addTearDown(() async {
          c.dispose();
          await auth.controller.close();
        });
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: c,
            child: const EntreHuellasApp(),
          ),
        );
        await tester.pumpAndSettle();
        c.read(routerProvider).go('/home/blocked-users');
        await tester.pumpAndSettle();
        expect(
          c.read(routerProvider).routeInformationProvider.value.uri.path,
          switch (stage) {
            'guest' => '/access',
            'onboarding' => '/onboarding',
            _ => '/home/blocked-users',
          },
        );
        expect(
          find.byType(UserBlocksScreen),
          stage == 'ready' ? findsOneWidget : findsNothing,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
  test(
    'Domain rejects invalid references/cursors/versions before repository access',
    () async {
      final repo = FakeBlocks();
      expect(
        () => PrepareUserBlock(repo)(actor, (kind: 'profile', id: target.id)),
        throwsA(isA<BlockFailure>()),
      );
      expect(
        () => ReadUserBlocks(repo)(actor, before: 'bad'),
        throwsA(isA<BlockFailure>()),
      );
      expect(
        () => SetUserBlock(repo)(
          actor,
          const BlockChange(
            UserBlock(id: 'bad', label: '', enabled: false, version: 0),
            true,
          ),
        ),
        throwsA(isA<BlockFailure>()),
      );
      expect(repo.attempts, isEmpty);
      expect(repo.cursors, isEmpty);
    },
  );
  test(
    'DTOs strip private fields, reject malformed receipts, bind exact retry parameters and map source failures',
    () async {
      final source = FakeBlockSource(),
          repo = UserBlockRepositoryImpl(FakeBlockSource());
      final actual = UserBlockRepositoryImpl(source);
      source.raw = {
        'id': entry.id,
        'label': entry.label,
        'enabled': true,
        'version': 1,
        'blocked_id': other,
      };
      final result = await actual.set(actor, const BlockChange(entry, true));
      expect(result.enabled, true);
      expect(source.params, {
        'p_id': entry.id,
        'p_enabled': true,
        'p_version': 0,
      });
      source.raw = {
        'id': entry.id,
        'label': entry.label,
        'enabled': false,
        'version': 1,
      };
      await expectLater(
        actual.set(actor, const BlockChange(entry, true)),
        throwsA(
          isA<BlockFailure>().having(
            (e) => e.issue,
            'issue',
            BlockIssue.unavailable,
          ),
        ),
      );
      for (final issue in ['invalid', 'forbidden', 'conflict', 'unavailable']) {
        source.failure = issue;
        await expectLater(
          actual.prepare(actor, target),
          throwsA(isA<BlockFailure>()),
        );
      }
      await expectLater(repo.list(actor, null), throwsA(isA<BlockFailure>()));
    },
  );
  test(
    'Double submission is suppressed; ambiguous response freezes exact command until acknowledged',
    () async {
      final repo = FakeBlocks();
      final c = container(repo);
      addTearDown(c.dispose);
      final provider = userBlockViewModelProvider(target),
          subscription = c.listen(
            userBlockViewModelProvider(target),
            (_, _) {},
          );
      addTearDown(subscription.close);
      await c.read(provider.future);
      final model = c.read(provider.notifier);
      repo.gate = Completer<void>();
      repo.setIssue = BlockIssue.unavailable;
      final first = model.change(entry, true);
      await model.change(entry, true);
      expect(repo.attempts.length, 1);
      repo.gate!.complete();
      expect(await first, false);
      expect(c.read(provider).requireValue.pending, isNotNull);
      await model.change(entry, false);
      expect(repo.attempts.length, 1);
      repo.setIssue = null;
      expect(await model.change(entry, true), true);
      expect(identical(repo.attempts[0], repo.attempts[1]), true);
      expect(c.read(provider).requireValue.target!.enabled, true);
      expect(c.read(provider).requireValue.pending, isNull);
    },
  );
  test(
    'Session replacement and disposal discard a late successful write',
    () async {
      final sessions = StreamController<AuthSession?>.broadcast(),
          repo = FakeBlocks();
      final scope = container(repo, sessions: sessions.stream),
          provider = userBlockViewModelProvider(target);
      final sub = scope.listen(provider, (_, _) {});
      addTearDown(sub.close);
      addTearDown(scope.dispose);
      addTearDown(sessions.close);
      sessions.add(const AuthSession(userId: actor));
      await scope.read(provider.future);
      repo.gate = Completer<void>();
      final writing = scope.read(provider.notifier).change(entry, true);
      sessions.add(const AuthSession(userId: other));
      await Future<void>.delayed(Duration.zero);
      await scope.read(provider.future);
      repo.gate!.complete();
      expect(await writing, false);
      expect(scope.read(provider).requireValue.actor, other);
      expect(scope.read(provider).requireValue.target!.enabled, false);
      repo.gate = Completer<void>();
      final disposed = scope.read(provider.notifier).change(entry, true);
      sub.close();
      scope.dispose();
      repo.gate!.complete();
      expect(await disposed, false);
    },
  );
  test(
    'Refresh failure preserves confirmed list and cursor; conflict requires consulting actual state',
    () async {
      final repo = FakeBlocks()
        ..items = [changed(entry, true)]
        ..next = entry.id;
      final scope = container(repo),
          provider = userBlockViewModelProvider(null);
      addTearDown(scope.dispose);
      final sub = scope.listen(provider, (_, _) {});
      addTearDown(sub.close);
      await scope.read(provider.future);
      final model = scope.read(provider.notifier);
      repo.readIssue = BlockIssue.unavailable;
      await model.load(more: true);
      expect(scope.read(provider).requireValue.items.length, 1);
      expect(scope.read(provider).requireValue.next, entry.id);
      repo.setIssue = BlockIssue.conflict;
      await model.change(repo.items.first, false);
      await model.change(repo.items.first, false);
      expect(repo.attempts.length, 1);
      repo.readIssue = null;
      model.retry();
      await scope.read(provider.future);
      expect(scope.read(provider).requireValue.issue, isNull);
    },
  );
  test('An authorization failure hides confirmed private choices', () async {
    final repo = FakeBlocks()..items = [changed(entry, true)];
    final c = container(repo), provider = userBlockViewModelProvider(null);
    addTearDown(c.dispose);
    final sub = c.listen(provider, (_, _) {});
    addTearDown(sub.close);
    await c.read(provider.future);
    repo.readIssue = BlockIssue.forbidden;
    await c.read(provider.notifier).load();
    expect(c.read(provider).hasError, true);
  });
  for (final small in [false, true]) {
    testWidgets(
      'Blocking confirmation and management ${small ? 'small text200' : 'normal motion'}',
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
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = FakeBlocks();
        final contacts = BlockAwareContactRepository(repo);
        final scope = container(repo, contacts: contacts);
        addTearDown(scope.dispose);
        final contactTarget = (source: 'lost', id: target.id);
        final contactProvider = caseContactViewModelProvider(contactTarget);
        final contactSubscription = scope.listen(contactProvider, (_, _) {});
        addTearDown(contactSubscription.close);
        void refreshContacts() =>
            scope.invalidate(caseContactViewModelProvider);
        Future<void> show(Widget child) async {
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: scope,
              child: MaterialApp(
                theme: AppTheme.light,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(small ? 2 : 1),
                    disableAnimations: small,
                  ),
                  child: RepaintBoundary(
                    key: const ValueKey('capture'),
                    child: child!,
                  ),
                ),
                home: child,
              ),
            ),
          );
          await tester.pumpAndSettle();
        }

        Future<void> capture(String name) async {
          await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
                  find.byKey(const ValueKey('capture')),
                ),
                image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final directory = Directory('build/ui-preview/user-blocks')
              ..createSync(recursive: true);
            File(
              '${directory.path}/${small ? 'small' : 'normal'}-$name.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        await show(
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CaseContactPanel(target: contactTarget),
                    UserBlockPanel(target: target, onSettled: refreshContacts),
                  ],
                ),
              ),
            ),
          ),
        );
        expect(find.text('+51900000000'), findsOneWidget);
        await tester.ensureVisible(find.text('Bloquear cuenta del reportante'));
        await tester.tap(find.text('Bloquear cuenta del reportante'));
        await tester.pumpAndSettle();
        await capture('confirmation');
        await tester.ensureVisible(find.text('Bloquear'));
        await tester.tap(find.text('Bloquear'));
        await tester.pumpAndSettle();
        expect(repo.attempts.length, 1);
        expect(find.text('Desbloquear cuenta'), findsOneWidget);
        expect(find.text('+51900000000'), findsNothing);
        expect(
          (await scope.read(contactProvider.future)).access.contact,
          isNull,
        );
        await show(UserBlocksScreen(onSettled: refreshContacts));
        await capture('list');
        expect(find.text(entry.label), findsOneWidget);
        await tester.ensureVisible(find.text('Desbloquear cuenta'));
        await tester.pumpAndSettle();
        await capture('list-action');
        await tester.tap(find.text('Desbloquear cuenta'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Desbloquear'));
        await tester.tap(find.text('Desbloquear'));
        await tester.pumpAndSettle();
        expect(find.text('No tienes cuentas bloqueadas.'), findsOneWidget);
        expect(
          (await scope.read(contactProvider.future)).access.contact?.phone,
          '+51900000000',
        );
        expect(contacts.opened, 0);
        await capture('empty');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
