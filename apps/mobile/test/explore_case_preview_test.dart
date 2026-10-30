import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/failures/explore_failure.dart';
import 'package:flutter_application_entrehuellas/features/explore/domain/use_cases/read_explore_case_preview.dart';
import 'package:flutter_application_entrehuellas/features/explore/presentation/view_models/explore_case_preview_view_model.dart';
import 'package:flutter_application_entrehuellas/features/explore/providers/explore_providers.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/providers/lost_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/providers/found_case_providers.dart';
import 'package:flutter_application_entrehuellas/features/lost_cases/domain/entities/lost_case.dart';
import 'package:flutter_application_entrehuellas/features/found_cases/domain/entities/found_case.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet.dart';
import 'lost_cases_test.dart' show FakeCases;
import 'found_cases_test.dart' show FakeFoundCases;
import 'explore_test.dart' show item;

class PreviewLostCases extends FakeCases {
  final reads = <String>[];
  @override
  Future<PublicLostCase?> readPublic(String id) {
    reads.add(id);
    return super.readPublic(id);
  }
}

PublicLostCase lost(String id) => PublicLostCase(
  id: id,
  status: 'active',
  occurredAt: DateTime(2026, 10, 14, 12),
  latitude: -12.05,
  longitude: -77.04,
  fields: const PetFields(
    name: 'Luna',
    species: PetSpecies.dog,
    size: PetSize.medium,
  ),
  photos: [
    CasePhoto(id: 'primary', uri: Uri.parse('https://example.com/primary.jpg')),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Bundled marker is an exact copy of the black SVG source', () async {
    expect(
      await rootBundle.loadString('assets/branding/only-black.svg'),
      await File('../../logo/only-black.svg').readAsString(),
    );
  });
  test('Preview reads public lost detail and its primary photo only', () async {
    final repository = PreviewLostCases()..publicCase = lost('same');
    final read = ReadExploreCasePreview(repository, FakeFoundCases());
    final result = await read(item('same'));
    expect(result.size, 'medium');
    expect(result.photoUri, Uri.parse('https://example.com/primary.jpg'));
    expect(result.occurredAt, DateTime(2026, 10, 14, 12));
    expect(repository.reads, ['same']);
  });
  test(
    'Coincident found origin reads its own size and never a private pet',
    () async {
      final repository = PreviewLostCases();
      final found = FakeFoundCases()
        ..publicCase = PublicFoundCase(
          id: 'same',
          status: 'active',
          occurredAt: DateTime(2026, 10, 15),
          latitude: -12.05,
          longitude: -77.04,
          species: 'dog',
          size: 'large',
          traits: 'Blanca',
          photos: [],
        );
      final result = await ReadExploreCasePreview(repository, found)(
        item('same', fromPet: false),
      );
      expect(result.size, 'large');
      expect(repository.reads, isEmpty);
      expect(result.photoUri, isNull);
    },
  );
  test(
    'Unavailable, mismatched and failed detail return a safe domain failure',
    () async {
      final repository = PreviewLostCases();
      final read = ReadExploreCasePreview(repository, FakeFoundCases());
      for (final mismatch in [false, true]) {
        repository.publicCase = mismatch ? lost('other') : null;
        await expectLater(read(item('same')), throwsA(isA<ExploreFailure>()));
      }
      repository.failRead = true;
      await expectLater(read(item('same')), throwsA(isA<ExploreFailure>()));
    },
  );
  test(
    'Preview hides old account data and reloads safely on identity changes',
    () async {
      final sessions = StreamController<AuthSession?>();
      final repository = PreviewLostCases()..publicCase = lost('same');
      final container = ProviderContainer(
        overrides: [
          exploreSessionProvider.overrideWith((_) => sessions.stream),
          lostCaseRepositoryProvider.overrideWithValue(repository),
          foundCaseRepositoryProvider.overrideWithValue(FakeFoundCases()),
        ],
      );
      final provider = exploreCasePreviewViewModelProvider(item('same'));
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(() async {
        subscription.close();
        container.dispose();
        await sessions.close();
      });
      final first = container.read(provider.future);
      sessions.add(const AuthSession(userId: 'one'));
      expect((await first).size, 'medium');
      sessions.add(null);
      await Future<void>.delayed(Duration.zero);
      await expectLater(
        container.read(provider.future),
        throwsA(isA<ExploreFailure>()),
      );
      expect(container.read(provider).asData, isNull);
      expect(repository.reads, ['same']);
      sessions.add(const AuthSession(userId: 'two'));
      await Future<void>.delayed(Duration.zero);
      expect((await container.read(provider.future)).size, 'medium');
      expect(repository.reads, ['same', 'same']);
    },
  );
  test(
    'Failed preview can retry the same public detail without a catalogue query',
    () async {
      final repository = PreviewLostCases()..failRead = true;
      final container = ProviderContainer(
        overrides: [
          exploreSessionProvider.overrideWith(
            (_) => Stream.value(const AuthSession(userId: 'one')),
          ),
          lostCaseRepositoryProvider.overrideWithValue(repository),
          foundCaseRepositoryProvider.overrideWithValue(FakeFoundCases()),
        ],
      );
      final provider = exploreCasePreviewViewModelProvider(item('same'));
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      addTearDown(container.dispose);
      await expectLater(
        container.read(provider.future),
        throwsA(isA<ExploreFailure>()),
      );
      repository
        ..failRead = false
        ..publicCase = lost('same');
      container.invalidate(provider);
      expect((await container.read(provider.future)).size, 'medium');
      expect(repository.reads, ['same', 'same']);
    },
  );
}
