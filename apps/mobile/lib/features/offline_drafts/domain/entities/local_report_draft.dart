import 'dart:typed_data';
import '../../../pets/domain/entities/pet.dart';
import '../../../pets/domain/entities/pet_photo.dart';
import '../../../found_cases/domain/entities/found_case.dart';

/// One unfinished command per account and editor context. Never a publication.
class LocalReportDraft {
  LocalReportDraft({
    required this.owner,
    required this.slot,
    required this.id,
    this.date,
    this.hour,
    this.minute,
    this.instant,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.place = '',
    this.comment = '',
    this.species = '',
    this.speciesDetail = '',
    this.size = '',
    this.sex = '',
    this.traits = '',
    this.custody = '',
    this.reportKind = 'possible_loss',
    this.target,
    this.pet,
    this.frozen = false,
    this.attempted = false,
    List<Pet> pets = const [],
    List<PetPhoto> petPhotos = const [],
    List<String> selectedPhotos = const [],
    List<FoundPhotoDraft> photos = const [],
    Uint8List? photo,
  }) : pets = List.unmodifiable(pets),
       petPhotos = List.unmodifiable(petPhotos),
       selectedPhotos = List.unmodifiable(selectedPhotos),
       photos = List.unmodifiable(photos),
       photo = photo == null
           ? null
           : Uint8List.fromList(photo).asUnmodifiableView();
  final String owner,
      slot,
      id,
      place,
      comment,
      species,
      speciesDetail,
      size,
      sex,
      traits,
      custody,
      reportKind;
  final DateTime? date, instant;
  final int? hour, minute;
  final double? latitude, longitude, accuracy;
  final bool frozen, attempted;
  final RecoverySearch? target;
  final Pet? pet;
  final List<Pet> pets;
  final List<PetPhoto> petPhotos;
  final List<String> selectedPhotos;
  final List<FoundPhotoDraft> photos;
  final Uint8List? photo;
}

class LocalDraftFailure implements Exception {
  const LocalDraftFailure();
}
