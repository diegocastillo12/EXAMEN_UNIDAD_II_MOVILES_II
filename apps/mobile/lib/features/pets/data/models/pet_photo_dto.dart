import '../../domain/entities/pet_photo.dart';

class PetPhotoDto {
  const PetPhotoDto({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.ready,
    this.uri,
    this.thumbnailUri,
    this.isPrimary = false,
    this.selectionVersion = 0,
  });
  final String id;
  final String petId;
  final String ownerId;
  final bool ready;
  final Uri? uri;
  final Uri? thumbnailUri;
  final bool isPrimary;
  final int selectionVersion;
  factory PetPhotoDto.fromMap(
    Map<String, dynamic> row, {
    Uri? uri,
    Uri? thumbnailUri,
  }) => PetPhotoDto(
    id: row['id'] as String,
    petId: row['pet_id'] as String,
    ownerId: row['owner_id'] as String,
    ready: row['status'] == 'published',
    uri: uri,
    thumbnailUri: thumbnailUri,
    isPrimary: row['is_primary'] == true,
    selectionVersion: row['selection_version'] as int? ?? 0,
  );
  PetPhoto toEntity() => PetPhoto(
    id: id,
    petId: petId,
    ownerId: ownerId,
    ready: ready,
    uri: uri,
    thumbnailUri: thumbnailUri,
    isPrimary: isPrimary,
    selectionVersion: selectionVersion,
  );
}
