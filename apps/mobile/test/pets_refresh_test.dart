import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/pull_to_refresh.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pets_section.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pet_skeleton.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/swipe_pet_card.dart';
import 'support/fake_pets.dart';

class CountingPets extends FakePets {
  int listCalls = 0;
  @override
  Future<List<Pet>> list(String ownerId, {bool archived = false}) {
    listCalls++;
    return super.list(ownerId, archived: archived);
  }
}

void main() {
  testWidgets(
    'One pull makes one pet query and retains cards through refresh',
    (tester) async {
      final repo = CountingPets();
      repo.pets['luna'] = const Pet(
        id: 'luna',
        ownerId: 'one',
        fields: PetFields(name: 'Luna', species: PetSpecies.dog),
        version: 1,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            petRepositoryProvider.overrideWithValue(repo),
            petSessionProvider.overrideWith(
              (_) => Stream.value(const AuthSession(userId: 'one')),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PullToRefresh(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: StaggerReveal(
                    enabled: false,
                    count: 2,
                    child: PetsSection(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(repo.listCalls, 1);
      final card = tester.state(find.byType(SwipePetCard));
      repo.pendingList = Completer<void>();
      await tester.dragFrom(const Offset(100, 100), const Offset(0, 400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
      expect(repo.listCalls, 2);
      expect(find.byType(PetSkeleton), findsNothing);
      expect(identical(tester.state(find.byType(SwipePetCard)), card), isTrue);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 400),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(repo.listCalls, 2);
      repo.pendingList!.complete();
      await tester.pumpAndSettle();
      expect(repo.listCalls, 2);
      expect(identical(tester.state(find.byType(SwipePetCard)), card), isTrue);
      expect(find.text('Luna'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
