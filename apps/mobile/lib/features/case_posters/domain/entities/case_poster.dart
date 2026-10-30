import 'dart:typed_data';

enum PosterSource { lost, found }

enum PosterExportAction { savePdf, sharePdf, shareLink }

enum PosterExportResult { cancelled, handedOff, unconfirmed }

enum PosterFailureKind {
  unavailable,
  forbidden,
  inactive,
  notConfigured,
  stale,
}

class PosterFailure implements Exception {
  const PosterFailure(this.kind);
  final PosterFailureKind kind;
}

class PosterCase {
  const PosterCase(this.source, this.id);
  final PosterSource source;
  final String id;
  @override
  bool operator ==(Object other) =>
      other is PosterCase && other.source == source && other.id == id;
  @override
  int get hashCode => Object.hash(source, id);
}

/// Only printable public fields; no coordinates, contact details or SDK paths.
class PosterContent {
  PosterContent({
    required this.target,
    required this.publicUrl,
    required this.revision,
    required this.reportKind,
    required this.name,
    required this.species,
    required this.traits,
    required this.occurredAt,
    required Uint8List photo,
    this.speciesDetail,
    this.size,
    this.sex,
  }) : photo = Uint8List.fromList(photo).asUnmodifiableView();
  final PosterCase target;
  final Uri publicUrl;
  final String revision, reportKind, name, species, traits;
  final String? speciesDetail, size, sex;
  final DateTime occurredAt;
  final Uint8List photo;
}

class PosterDocument {
  PosterDocument({required this.content, required Uint8List bytes})
    : bytes = Uint8List.fromList(bytes).asUnmodifiableView();
  final PosterContent content;
  final Uint8List bytes;
  String get fileName =>
      'entre-huellas-${content.target.source.name}-${content.target.id}.pdf';
}
