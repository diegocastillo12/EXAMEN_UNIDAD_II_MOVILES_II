import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/case_poster.dart';
import '../../domain/entities/case_share.dart';
import 'case_share_source.dart';
import 'poster_document_source.dart';

class NativeCaseShareActionSource implements CaseShareActionSource {
  const NativeCaseShareActionSource(this._exports, {required this.copyText});
  final PosterExportSource _exports;
  final Future<void> Function(String) copyText;
  @override
  Future<CaseShareResult> handoff(
    CaseShareChannel channel,
    Uri publicUrl,
    PosterDocument? document,
  ) async {
    if (channel == CaseShareChannel.copyLink) {
      await copyText(publicUrl.toString());
      return CaseShareResult.copied;
    }
    if (channel == CaseShareChannel.download) {
      if (document == null) {
        throw const PosterFailure(PosterFailureKind.unavailable);
      }
      final result = await _exports.export(
        document,
        PosterExportAction.savePdf,
      );
      return switch (result) {
        PosterExportResult.cancelled => CaseShareResult.cancelled,
        PosterExportResult.handedOff => CaseShareResult.opened,
        PosterExportResult.unconfirmed => CaseShareResult.unconfirmed,
      };
    }
    final uri = channel == CaseShareChannel.whatsapp
        ? Uri.https('wa.me', '/', {'text': publicUrl.toString()})
        : Uri.https('www.facebook.com', '/sharer/sharer.php', {
            'u': publicUrl.toString(),
          });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw const PosterFailure(PosterFailureKind.unavailable);
    }
    return CaseShareResult.opened;
  }
}
