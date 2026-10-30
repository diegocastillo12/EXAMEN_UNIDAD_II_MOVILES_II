import 'support/fake_local_drafts.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/providers/local_draft_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/providers/found_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/view_models/found_editor_view_model.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/providers/lost_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/entities/lost_case.dart';
import 'app_test.dart' show FakeAuthRepository;
import 'found_cases_test.dart' show FakeFoundCases;
import 'lost_cases_test.dart' show FakeCases, fields;

class BoundFound extends FakeFoundCases {
  int reads = 0, catalogues = 0, publishes = 0;
  bool closed = false;
  @override
  Future<PublicFoundCase?> readPublic(String id) {
    reads++;
    return super.readPublic(id);
  }

  @override
  Future<List<RecoverySearch>> listOpenSearches(String owner) async {
    catalogues++;
    throw StateError('A notice must not read the catalogue');
  }

  @override
  Future<FoundPublication> publish(String owner, FoundCaseDraft draft) {
    publishes++;
    if (closed) throw const FoundFailure(FoundFailureKind.targetClosed);
    return super.publish(owner, draft);
  }
}

class BoundLost extends FakeCases {
  int reads = 0;
  @override
  Future<PublicLostCase?> readPublic(String id) {
    reads++;
    return super.readPublic(id);
  }
}

void main() {
  for (final community in [false, true]) {
    test(
      'Notice reads one bound case, no catalogue; closed publication preserves draft and blocks retry; community=$community',
      () async {
        final auth = FakeAuthRepository()
          ..current = const AuthSession(userId: 'one');
        final found = BoundFound()
          ..publicCase = PublicFoundCase(
            id: 'case',
            status: 'active',
            occurredAt: DateTime(2026, 10, 9),
            latitude: -12.04,
            longitude: -77.04,
            species: 'dog',
            traits: 'Collar azul',
            photos: [],
          );
        // Large catalogue exists, but isn't requested, iterated or selected.
        found.searches.addAll(
          List.generate(
            1000,
            (i) => RecoverySearch(
              id: 'other-$i',
              community: true,
              name: 'Otra mascota',
              species: 'dog',
            ),
          ),
        );
        final lost = BoundLost()
          ..publicCase = PublicLostCase(
            id: 'case',
            status: 'active',
            occurredAt: DateTime(2026, 10, 9),
            latitude: -12.04,
            longitude: -77.04,
            fields: fields,
            photos: [],
          );
        final scope = ProviderContainer(
          overrides: [
            localDraftRepositoryProvider.overrideWithValue(FakeLocalDrafts()),
            authRepositoryProvider.overrideWithValue(auth),
            foundCaseRepositoryProvider.overrideWithValue(found),
            lostCaseRepositoryProvider.overrideWithValue(lost),
            foundEditorContextProvider.overrideWithValue(
              FoundEditorContext(
                communitySearch: false,
                targetId: 'case',
                communityTarget: community,
              ),
            ),
          ],
        );
        final listener = scope.listen(foundEditorViewModelProvider, (_, _) {});
        addTearDown(() async {
          listener.close();
          scope.dispose();
          await auth.controller.close();
        });
        final initial = await scope.read(foundEditorViewModelProvider.future);
        expect(initial.targetId, 'case');
        expect(initial.communityTarget, community);
        expect(found.catalogues, 0);
        expect(found.reads + lost.reads, 1);
        final model = scope.read(foundEditorViewModelProvider.notifier);
        model.edit(
          traits: 'La vi junto al parque',
          occurredAt: DateTime(2026, 10, 9, 12),
          latitude: -12.045,
          longitude: -77.045,
          placeReference: 'Parque',
        );
        model.preview();
        final before = scope.read(foundEditorViewModelProvider).requireValue;
        found.closed = true;
        await model.publish();
        final after = scope.read(foundEditorViewModelProvider).requireValue;
        expect(after.issue, FoundFailureKind.targetClosed);
        expect(after.draftId, before.draftId);
        expect(after.traits, before.traits);
        expect(after.targetId, before.targetId);
        expect(after.photos, before.photos);
        await model.publish();
        model.chooseObservation('with_reporter');
        expect(found.publishes, 1);
        expect(
          scope.read(foundEditorViewModelProvider).requireValue.reportKind,
          'sighting',
        );
        expect(found.catalogues, 0);
      },
    );
  }
}
