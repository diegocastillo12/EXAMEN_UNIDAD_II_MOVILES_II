import 'dart:typed_data';

enum FoundFailureKind {
  localStorage,
  unavailable,
  timedOut,
  forbidden,
  blocked,
  invalid,
  conflict,
  photos,
  photoInvalid,
  gallery,
  draftLimit,
  targetClosed,
}

enum FoundField { target, species, traits, photos, date, point, place }

class FoundFailure implements Exception {
  const FoundFailure(this.kind, {this.fields = const {}});
  final FoundFailureKind kind;
  final Set<FoundField> fields;
}

class FoundPhotoDraft {
  FoundPhotoDraft(this.id, Uint8List bytes)
    : bytes = Uint8List.fromList(bytes).asUnmodifiableView();
  final String id;
  final Uint8List bytes;
}

class FoundCaseDraft {
  FoundCaseDraft({
    required this.id,
    this.reportKind = 'possible_loss',
    this.targetId,
    this.communityTarget = false,
    required this.occurredAt,
    required this.latitude,
    required this.longitude,
    required this.placeReference,
    required this.species,
    this.speciesDetail,
    this.size,
    this.sex,
    required this.traits,
    this.custody,
    required List<FoundPhotoDraft> photos,
  }) : photos = List.unmodifiable(photos);
  final String reportKind;
  final String? targetId;
  final bool communityTarget;
  final String id, placeReference, species, traits;
  final String? speciesDetail, size, sex, custody;
  final DateTime occurredAt;
  final double latitude, longitude;
  final List<FoundPhotoDraft> photos;
}

class FoundPublication {
  const FoundPublication({
    required this.id,
    this.reportKind = 'possible_loss',
    this.targetId,
    this.communityTarget = false,
    required this.ownerId,
    required this.status,
    this.coverUri,
    this.species,
  });
  final String reportKind;
  final String? targetId;
  final bool communityTarget;
  final Uri? coverUri;
  final String id, ownerId, status;
  final String? species;
}

class FoundPhoto {
  const FoundPhoto(this.id, this.uri);
  final String id;
  final Uri? uri;
}

class PublicFoundCase {
  PublicFoundCase({
    required this.id,
    this.reportKind = 'possible_loss',
    this.canResolve = false,
    this.canGeneratePoster = false,
    this.targetId,
    this.communityTarget = false,
    required this.status,
    required this.occurredAt,
    required this.latitude,
    required this.longitude,
    required this.species,
    this.speciesDetail,
    this.size,
    this.sex,
    required this.traits,
    this.custody,
    required List<FoundPhoto> photos,
  }) : photos = List.unmodifiable(photos);
  final String reportKind;
  final String? targetId;
  final bool communityTarget;
  final bool canResolve;
  final bool canGeneratePoster;
  final String id, status, species, traits;
  final String? speciesDetail, size, sex, custody;
  final DateTime occurredAt;
  final double latitude, longitude;
  final List<FoundPhoto> photos;
}

class RecoverySearch {
  const RecoverySearch({
    required this.id,
    required this.community,
    required this.name,
    required this.species,
    this.speciesDetail,
    this.size,
    this.sex,
  });
  final String id, name, species;
  final bool community;
  final String? speciesDetail, size, sex;
  String get key => '${community ? 'community' : 'pet'}:$id';
}

class FoundEditorContext {
  const FoundEditorContext({
    this.communitySearch = true,
    this.independentFound = false,
    this.targetId,
    this.communityTarget = false,
  });
  final bool communitySearch, communityTarget, independentFound;
  final String? targetId;
}
