import 'dart:typed_data';
import '../../domain/entities/case_poster.dart';

abstract interface class PosterDocumentSource {
  Future<Uint8List> render(PosterContent content);
}

abstract interface class PosterExportSource {
  Future<PosterExportResult> export(
    PosterDocument document,
    PosterExportAction action,
  );
}
