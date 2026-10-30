import 'dart:typed_data';
import 'package:image/image.dart' as image;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/case_poster.dart';
import 'poster_document_source.dart';

/// One-page, print-first public template. Fonts are supplied as bundled bytes.
class PdfPosterDocumentSource implements PosterDocumentSource {
  const PdfPosterDocumentSource({
    required this.regularFont,
    required this.boldFont,
  });
  final Future<ByteData> Function() regularFont, boldFont;
  @override
  Future<Uint8List> render(PosterContent content) async {
    // Re-encode only the verified derivative to keep embedded JPEG metadata out.
    final decoded = image.decodeImage(content.photo);
    if (decoded == null) {
      throw const PosterFailure(PosterFailureKind.unavailable);
    }
    final sanitized = image.Image(
      width: decoded.width,
      height: decoded.height,
      numChannels: 3,
    );
    image.fill(sanitized, color: image.ColorRgb8(255, 255, 255));
    image.compositeImage(sanitized, decoded);
    final photo = pw.MemoryImage(
      Uint8List.fromList(image.encodeJpg(sanitized, quality: 90)),
    );
    final regular = pw.Font.ttf(await regularFont());
    final bold = pw.Font.ttf(await boldFont());
    final title =
        {'legacy_found', 'independent_found'}.contains(content.reportKind)
        ? 'MASCOTA ENCONTRADA'
        : 'MASCOTA PERDIDA';
    final species = switch (content.species) {
      'dog' => 'Perro',
      'cat' => 'Gato',
      _ => content.speciesDetail ?? 'Otra especie',
    };
    final name = content.name.isEmpty ? species : content.name;
    final date = content.occurredAt.toLocal();
    final dateLabel =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final description = [
      species,
      switch (content.size) {
        'small' => 'Pequeño',
        'medium' => 'Mediano',
        'large' => 'Grande',
        _ => null,
      },
      switch (content.sex) {
        'male' => 'Macho',
        'female' => 'Hembra',
        _ => null,
      },
    ].whereType<String>().join(' · ');
    final document = pw.Document(
      title: 'Entre Huellas - cartel público',
      author: 'Entre Huellas',
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              'ENTRE HUELLAS',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 27, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              width: double.infinity,
              height: 280,
              alignment: pw.Alignment.center,
              color: PdfColors.grey100,
              child: pw.Image(photo, fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              height: 80,
              child: pw.FittedBox(
                fit: pw.BoxFit.scaleDown,
                alignment: pw.Alignment.centerLeft,
                child: pw.SizedBox(
                  width: PdfPageFormat.a4.width - 64,
                  child: pw.Text(
                    name,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            pw.Text(description, style: const pw.TextStyle(fontSize: 15)),
            pw.SizedBox(height: 4),
            pw.Text(
              '${{'legacy_found', 'independent_found'}.contains(content.reportKind) ? 'Encuentro' : 'Desaparición'}: $dateLabel',
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 6),
            pw.Container(
              height: 64,
              child: pw.FittedBox(
                fit: pw.BoxFit.scaleDown,
                alignment: pw.Alignment.topLeft,
                child: pw.SizedBox(
                  width: PdfPageFormat.a4.width - 64,
                  child: pw.Text(
                    content.traits,
                    style: const pw.TextStyle(fontSize: 14, lineSpacing: 3),
                  ),
                ),
              ),
            ),
            pw.Spacer(),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  color: PdfColors.white,
                  padding: const pw.EdgeInsets.all(14),
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(
                      errorCorrectLevel: pw.BarcodeQRCorrectionLevel.high,
                    ),
                    data: content.publicUrl.toString(),
                    width: 130,
                    height: 130,
                    drawText: false,
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '¿Tienes información?',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Escanea para consultar el estado actual y la ubicación aproximada del caso.',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'No necesitas instalar la app.',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.UrlLink(
              destination: content.publicUrl.toString(),
              child: pw.Text(
                content.publicUrl.toString(),
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'La información impresa puede cambiar. Consulta siempre la ficha del QR.',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
    );
    return document.save();
  }
}
