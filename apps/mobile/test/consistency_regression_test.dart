import 'support/fake_local_drafts.dart';
import 'package:flutter_application_entrehuellas/features/offline_drafts/providers/local_draft_providers.dart';
import 'dart:async';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/providers/found_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/view_models/found_editor_view_model.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/presentation/state/found_editor_state.dart';
import 'found_cases_test.dart' show FakeFoundCases;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet_photo.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_list_view_model.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_photos_view_model.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/entities/lost_case.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/providers/lost_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/presentation/view_models/case_read_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'support/fake_pets.dart';
import 'lost_cases_test.dart' show FakeCases, fields;

void main() {
  test('Deleting a case refreshes the observed pet list and detail', () async {
    final pets = FakePets()
      ..pets['pet'] = const Pet(
        id: 'pet',
        ownerId: 'one',
        fields: fields,
        version: 2,
        activeCaseCount: 1,
      );
    const item = PublishedLostCase(
      id: 'case',
      ownerId: 'one',
      petId: 'pet',
      status: 'active',
    );
    final cases = FakeCases()..mine.add(item);
    final scope = ProviderContainer(
      overrides: [
        localDraftRepositoryProvider.overrideWithValue(FakeLocalDrafts()),
        petSessionProvider.overrideWith(
          (ref) => Stream.value(const AuthSession(userId: 'one')),
        ),
        caseSessionProvider.overrideWith(
          (ref) => Stream.value(const AuthSession(userId: 'one')),
        ),
        petRepositoryProvider.overrideWithValue(pets),
        lostCaseRepositoryProvider.overrideWithValue(cases),
      ],
    );
    addTearDown(scope.dispose);
    final petSub = scope.listen(petListViewModelProvider, (_, _) {});
    final detailSub = scope.listen(
      petDetailViewModelProvider('pet'),
      (_, _) {},
    );
    addTearDown(detailSub.close);
    final caseSub = scope.listen(myCasesViewModelProvider, (_, _) {});
    addTearDown(petSub.close);
    addTearDown(caseSub.close);
    await scope.read(petListViewModelProvider.future);
    await scope.read(myCasesViewModelProvider.future);
    await scope.read(petDetailViewModelProvider('pet').future);
    cases.failDelete = true;
    await scope.read(myCasesViewModelProvider.notifier).delete(item);
    expect(
      scope.read(petDetailViewModelProvider('pet')).requireValue.version,
      2,
    );
    cases.failDelete = false;
    // Represents the committed server transaction: version increases and active count decreases.
    pets.pets['pet'] = const Pet(
      id: 'pet',
      ownerId: 'one',
      fields: fields,
      version: 3,
      activeCaseCount: 0,
    );
    await scope.read(myCasesViewModelProvider.notifier).delete(item);
    await scope.pump();
    await scope.read(petListViewModelProvider.future);
    await scope.read(petDetailViewModelProvider('pet').future);
    expect(
      scope.read(petDetailViewModelProvider('pet')).requireValue.version,
      3,
    );
    expect(scope.read(myCasesViewModelProvider).requireValue.cases, isEmpty);
    expect(
      scope.read(petListViewModelProvider).requireValue.single.activeCaseCount,
      0,
    );
    expect(scope.read(petListViewModelProvider).requireValue.single.version, 3);
  });
  for (final discarding in [false, true]) {
    test(
      'Found timeout keeps frozen request and retries; discard=$discarding',
      () async {
        final cases = FakeFoundCases()..pending = Completer<void>();
        final scope = ProviderContainer(
          overrides: [
            localDraftRepositoryProvider.overrideWithValue(FakeLocalDrafts()),
            foundCaseRepositoryProvider.overrideWithValue(cases),
            foundSessionProvider.overrideWith(
              (ref) => Stream.value(const AuthSession(userId: 'one')),
            ),
            foundEditorViewModelProvider.overrideWith(
              () => FoundEditorViewModel(
                operationTimeout: const Duration(milliseconds: 10),
              ),
            ),
          ],
        );
        addTearDown(scope.dispose);
        final sub = scope.listen(foundEditorViewModelProvider, (_, _) {});
        addTearDown(sub.close);
        await scope.read(foundEditorViewModelProvider.future);
        final model = scope.read(foundEditorViewModelProvider.notifier);
        model.edit(
          species: 'dog',
          traits: 'Blanca',
          placeReference: 'Parque',
          occurredAt: DateTime.utc(2026, 10, 9),
          latitude: -12,
          longitude: -77,
        );
        await model.choosePhoto();
        model.preview();
        await model.publish();
        final timedOut = scope.read(foundEditorViewModelProvider).requireValue;
        expect(timedOut.issue, FoundFailureKind.timedOut);
        expect(timedOut.busy, isFalse);
        expect(timedOut.lockedDraft, isNotNull);
        model.edit(traits: 'Cambio prohibido');
        expect(
          scope.read(foundEditorViewModelProvider).requireValue.traits,
          'Blanca',
        );
        final late = cases.pending!;
        if (discarding) {
          expect(await model.discardLocalDraft(timedOut.draftId), isFalse);
          expect(cases.discards, isEmpty);
          expect(
            scope.read(foundEditorViewModelProvider).requireValue.stage,
            FoundStage.preview,
          );
          late.complete();
          await Future<void>.delayed(Duration.zero);
          expect(
            scope.read(foundEditorViewModelProvider).requireValue.stage,
            FoundStage.confirmed,
          );
          expect(
            scope.read(foundEditorViewModelProvider).requireValue.published!.id,
            timedOut.draftId,
          );
          expect(await model.discardLocalDraft(timedOut.draftId), isFalse);
          expect(cases.discards, isEmpty);
        } else {
          final retry = model.publish();
          await Future<void>.delayed(Duration.zero);
          expect(cases.attempts, hasLength(1));
          expect(
            scope.read(foundEditorViewModelProvider).requireValue.published,
            isNull,
          );
          late.complete();
          await retry;
          expect(cases.attempts, hasLength(1));
          expect(cases.attempts.single.id, timedOut.draftId);
          expect(
            cases.attempts.single.photos.first.bytes,
            timedOut.lockedDraft!.photos.first.bytes,
          );
          expect(
            scope.read(foundEditorViewModelProvider).requireValue.stage,
            FoundStage.confirmed,
          );
          expect(
            scope.read(foundEditorViewModelProvider).requireValue.issue,
            isNull,
          );
        }
      },
    );
  }

  test('Photo snapshots and draft bytes cannot be changed externally', () {
    final photos = <PetPhoto>[];
    final snapshot = PetPhotosState(photos: photos);
    photos.add(
      const PetPhoto(id: 'p', petId: 'pet', ownerId: 'one', ready: true),
    );
    expect(snapshot.photos, isEmpty);
    expect(() => snapshot.photos.add(photos.single), throwsUnsupportedError);
    final bytes = Uint8List.fromList([255, 216, 255, 0]);
    final draft = PetPhotoDraft(id: 'draft', bytes: bytes);
    bytes[0] = 0;
    expect(draft.bytes[0], 255);
    expect(() => draft.bytes[0] = 0, throwsUnsupportedError);
  });
}
