import 'dart:typed_data';
import '../../domain/entities/case_poster.dart';

class PosterPayload {
  const PosterPayload(this.row);
  final Map<String, dynamic> row;
  String get revision => row['revision'] as String;
  String get photoPath => row['photo_path'] as String;
  String get slug => row['public_slug'] as String;
  PosterContent toContent(PosterCase target, Uri publicUrl, Uint8List photo) =>
      PosterContent(
        target: target,
        publicUrl: publicUrl,
        revision: revision,
        reportKind: row['report_kind'] as String,
        name: row['name'] as String,
        species: row['species'] as String,
        speciesDetail: row['species_detail'] as String?,
        size: row['size'] as String?,
        sex: row['sex'] as String?,
        traits: row['traits'] as String,
        occurredAt: DateTime.parse(row['occurred_at'] as String),
        photo: photo,
      );
}
