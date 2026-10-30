import '../../../pets/domain/entities/pet.dart';

enum CaseFailureKind {
  localStorage,
  unavailable,
  timedOut,
  busy,
  forbidden,
  invalid,
  conflict,
  activeCase,
  photosUnverified,
  incompletePet,
}

enum CaseField { pet, photos, date, point, place }

class CaseFailure implements Exception {
  const CaseFailure(this.kind, {this.fields = const {}});
  final Set<CaseField> fields;
  final CaseFailureKind kind;
}

class LostCaseDraft {
  LostCaseDraft({
    required this.id,
    required this.petId,
    required this.petVersion,
    required this.occurredAt,
    required this.latitude,
    required this.longitude,
    required this.placeReference,
    required List<String> photoIds,
  }) : photoIds = List.unmodifiable(photoIds);
  final String id, petId, placeReference;
  final int petVersion;
  final DateTime occurredAt;
  final double latitude, longitude;
  final List<String> photoIds;
}

class CasePhoto {
  const CasePhoto({required this.id, this.uri});
  final String id;
  final Uri? uri;
}

class PublicLostCase {
  PublicLostCase({
    required this.id,
    this.canResolve = false,
    required this.status,
    required this.occurredAt,
    required this.latitude,
    required this.longitude,
    required this.fields,
    required List<CasePhoto> photos,
  }) : photos = List.unmodifiable(photos);
  final String id, status;
  final bool canResolve;
  final DateTime occurredAt;
  final double latitude, longitude;
  final PetFields fields;
  final List<CasePhoto> photos;
}

class PublishedLostCase {
  const PublishedLostCase({
    required this.id,
    required this.ownerId,
    required this.petId,
    required this.status,
    this.coverUri,
    this.petName = '',
  });
  final Uri? coverUri;
  final String id, ownerId, petId, status, petName;
}
