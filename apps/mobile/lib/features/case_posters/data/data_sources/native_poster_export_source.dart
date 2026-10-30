import 'dart:ui' show Rect;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/case_poster.dart';
import 'poster_document_source.dart';

class NativePosterExportSource implements PosterExportSource {
  const NativePosterExportSource();
  @override
  Future<PosterExportResult> export(
    PosterDocument document,
    PosterExportAction action,
  ) async {
    if (action == PosterExportAction.savePdf) {
      final done = await Printing.layoutPdf(
        onLayout: (_) async => document.bytes,
        name: document.fileName,
        format: PdfPageFormat.a4,
        dynamicLayout: false,
      );
      return done ? PosterExportResult.handedOff : PosterExportResult.cancelled;
    }
    final result = await SharePlus.instance.share(
      ShareParams(
        text: document.content.publicUrl.toString(),
        files: action == PosterExportAction.sharePdf
            ? [XFile.fromData(document.bytes, mimeType: 'application/pdf')]
            : null,
        fileNameOverrides: action == PosterExportAction.sharePdf
            ? [document.fileName]
            : null,
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
      ),
    );
    return switch (result.status) {
      ShareResultStatus.dismissed => PosterExportResult.cancelled,
      ShareResultStatus.success => PosterExportResult.handedOff,
      ShareResultStatus.unavailable => PosterExportResult.unconfirmed,
    };
  }
}
