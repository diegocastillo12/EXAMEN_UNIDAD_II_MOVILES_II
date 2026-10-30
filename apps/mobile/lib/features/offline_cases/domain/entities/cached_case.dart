import '../../../lost_cases/domain/entities/lost_case.dart';
import '../../../found_cases/domain/entities/found_case.dart';
import '../../../../core/domain/entities/public_case_card.dart';

/// Only a public projection; never a grant to perform an operation.
class CachedCase {
  const CachedCase({required this.storedAt, this.lost, this.found});
  final DateTime storedAt;
  final PublicLostCase? lost;
  final PublicFoundCase? found;
  String get id => lost?.id ?? found!.id;
  String get source => lost == null ? 'found' : 'lost';
  PublicCaseCard get card => PublicCaseCard(
    id: id,
    fromPet: lost != null,
    reportKind: found?.reportKind ?? 'own_loss',
    kind: lost != null || found?.reportKind == 'possible_loss'
        ? PublicCaseKind.lost
        : found?.reportKind == 'sighting'
        ? PublicCaseKind.sighting
        : PublicCaseKind.found,
    status: PublicCaseStatus.active,
    species: lost?.fields.species?.name ?? found?.species ?? 'other',
    name: lost?.fields.name ?? found?.speciesDetail ?? 'Mascota',
    traits: lost?.fields.traits ?? found?.traits ?? '',
    occurredAt: lost?.occurredAt ?? found!.occurredAt,
    latitude: lost?.latitude ?? found!.latitude,
    longitude: lost?.longitude ?? found!.longitude,
    coverUri: lost != null
        ? (lost!.photos.isEmpty ? null : lost!.photos.first.uri)
        : (found!.photos.isEmpty ? null : found!.photos.first.uri),
  );
}

class CaseConsultation<T> {
  const CaseConsultation(
    this.value, {
    this.cachedAt,
    this.storageFailed = false,
  });
  final T? value;
  final DateTime? cachedAt;
  final bool storageFailed;
}
