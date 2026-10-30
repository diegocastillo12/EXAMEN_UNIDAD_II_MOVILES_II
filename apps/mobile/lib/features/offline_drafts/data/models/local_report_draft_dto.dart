import 'dart:convert';
import '../../domain/entities/local_report_draft.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../../pets/domain/entities/pet_photo.dart';
import '../../../found_cases/domain/entities/found_case.dart';

class LocalReportDraftDto {
  static Map<String, Object?> _pet(Pet p) => {
    'id': p.id, 'owner': p.ownerId, 'version': p.version,
    'name': p.fields.name, 'species': p.fields.species?.name,
    'sex': p.fields.sex?.name, 'age': p.fields.ageMonths,
    'traits': p.fields.traits, 'detail': p.fields.speciesDetail,
    'size': p.fields.size?.name, 'archived': p.archivedAt?.toIso8601String(),
    'history': p.caseHistoryAt?.toIso8601String(), 'active': p.activeCaseCount,
    // Signed URLs are deliberately excluded; photo IDs are the evidence references.
  };
  static Pet _readPet(Map<String, dynamic> p) => Pet(
    id: p['id'] as String,
    ownerId: p['owner'] as String,
    version: p['version'] as int,
    fields: PetFields(
      name: p['name'] as String,
      species: PetSpecies.values
          .where((v) => v.name == p['species'])
          .firstOrNull,
      sex: PetSex.values.where((v) => v.name == p['sex']).firstOrNull,
      size: PetSize.values.where((v) => v.name == p['size']).firstOrNull,
      ageMonths: p['age'] as int?,
      traits: p['traits'] as String?,
      speciesDetail: p['detail'] as String?,
    ),
    archivedAt: _date(p['archived']),
    caseHistoryAt: _date(p['history']),
    activeCaseCount: p['active'] as int,
  );
  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.parse(value as String);
  static double? _double(dynamic value) => (value as num?)?.toDouble();
  static String encode(LocalReportDraft d) => jsonEncode({
    'v': 1,
    'owner': d.owner,
    'slot': d.slot,
    'id': d.id,
    'date': d.date?.toIso8601String(),
    'hour': d.hour,
    'minute': d.minute,
    'instant': d.instant?.toIso8601String(),
    'lat': d.latitude,
    'lng': d.longitude,
    'accuracy': d.accuracy,
    'place': d.place,
    'comment': d.comment,
    'species': d.species,
    'detail': d.speciesDetail,
    'size': d.size,
    'sex': d.sex,
    'traits': d.traits,
    'custody': d.custody,
    'kind': d.reportKind,
    'frozen': d.frozen,
    'attempted': d.attempted,
    'target': d.target == null
        ? null
        : {
            'id': d.target!.id,
            'community': d.target!.community,
            'name': d.target!.name,
            'species': d.target!.species,
            'detail': d.target!.speciesDetail,
            'size': d.target!.size,
            'sex': d.target!.sex,
          },
    'pet': d.pet == null ? null : _pet(d.pet!),
    'pets': d.pets.map(_pet).toList(),
    'petPhotos': d.petPhotos
        .map(
          (p) => {
            'id': p.id,
            'petId': p.petId,
            'owner': p.ownerId,
            'ready': p.ready,
            'primary': p.isPrimary,
            'version': p.selectionVersion,
          },
        )
        .toList(),
    'selected': d.selectedPhotos,
    'photos': d.photos
        .map((p) => {'id': p.id, 'bytes': base64Encode(p.bytes)})
        .toList(),
    'photo': d.photo == null ? null : base64Encode(d.photo!),
  });

  static LocalReportDraft decode(String payload) {
    final p = jsonDecode(payload) as Map<String, dynamic>;
    if (p['v'] != 1) throw const FormatException('Unsupported draft schema');
    final t = p['target'] as Map<String, dynamic>?;
    return LocalReportDraft(
      owner: p['owner'] as String,
      slot: p['slot'] as String,
      id: p['id'] as String,
      date: _date(p['date']),
      hour: p['hour'] as int?,
      minute: p['minute'] as int?,
      instant: _date(p['instant']),
      latitude: _double(p['lat']),
      longitude: _double(p['lng']),
      accuracy: _double(p['accuracy']),
      place: p['place'] as String,
      comment: p['comment'] as String,
      species: p['species'] as String,
      speciesDetail: p['detail'] as String,
      size: p['size'] as String,
      sex: p['sex'] as String,
      traits: p['traits'] as String,
      custody: p['custody'] as String,
      reportKind: p['kind'] as String,
      frozen: p['frozen'] as bool,
      attempted: p['attempted'] as bool,
      target: t == null
          ? null
          : RecoverySearch(
              id: t['id'] as String,
              community: t['community'] as bool,
              name: t['name'] as String,
              species: t['species'] as String,
              speciesDetail: t['detail'] as String?,
              size: t['size'] as String?,
              sex: t['sex'] as String?,
            ),
      pet: p['pet'] == null ? null : _readPet(p['pet'] as Map<String, dynamic>),
      pets: (p['pets'] as List)
          .map((v) => _readPet(v as Map<String, dynamic>))
          .toList(),
      petPhotos: (p['petPhotos'] as List)
          .map(
            (v) => PetPhoto(
              id: v['id'] as String,
              petId: v['petId'] as String,
              ownerId: v['owner'] as String,
              ready: v['ready'] as bool,
              isPrimary: v['primary'] as bool,
              selectionVersion: v['version'] as int,
            ),
          )
          .toList(),
      selectedPhotos: (p['selected'] as List).cast<String>(),
      photos: (p['photos'] as List)
          .map(
            (v) => FoundPhotoDraft(
              v['id'] as String,
              base64Decode(v['bytes'] as String),
            ),
          )
          .toList(),
      photo: p['photo'] == null ? null : base64Decode(p['photo'] as String),
    );
  }
}
