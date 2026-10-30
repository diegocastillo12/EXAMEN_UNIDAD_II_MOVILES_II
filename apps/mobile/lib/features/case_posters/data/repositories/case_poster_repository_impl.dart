import '../../domain/entities/case_poster.dart';
import '../../domain/repositories/case_poster_repository.dart';
import '../data_sources/poster_case_source.dart';
import '../data_sources/poster_document_source.dart';

class CasePosterRepositoryImpl implements CasePosterRepository {
  const CasePosterRepositoryImpl(
    this._source,
    this._documents,
    this._exports, {
    required this.webBaseUrl,
    required this.publicWebReady,
  });
  final PosterCaseSource _source;
  final PosterDocumentSource _documents;
  final PosterExportSource _exports;
  final String webBaseUrl;
  final bool publicWebReady;
  Uri? get _base {
    final base = Uri.tryParse(webBaseUrl);
    return publicWebReady &&
            base != null &&
            base.scheme == 'https' &&
            base.host.isNotEmpty &&
            base.userInfo.isEmpty &&
            !base.hasQuery &&
            !base.hasFragment &&
            base.toString().length <= 180
        ? base
        : null;
  }

  @override
  bool get configured => _base != null;
  Uri _url(String slug) {
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(slug)) {
      throw const PosterFailure(PosterFailureKind.unavailable);
    }
    final base = _base;
    if (base == null) {
      throw const PosterFailure(PosterFailureKind.notConfigured);
    }
    return base.replace(
      path: '${base.path.replaceFirst(RegExp(r'/+$'), '')}/c/$slug',
    );
  }

  @override
  Future<PosterDocument> generate(String owner, PosterCase target) async {
    try {
      if (!configured) {
        throw const PosterFailure(PosterFailureKind.notConfigured);
      }
      final payload = await _source.prepare(owner, target);
      if (payload.row['source'] != target.source.name ||
          payload.row['id'] != target.id) {
        throw const PosterFailure(PosterFailureKind.forbidden);
      }
      final photo = await _source.photo(owner, target, payload.photoPath);
      final content = payload.toContent(target, _url(payload.slug), photo);
      final bytes = await _documents.render(content);
      _source.checkOwner(owner);
      return PosterDocument(content: content, bytes: bytes);
    } on PosterFailure {
      rethrow;
    } catch (_) {
      throw const PosterFailure(PosterFailureKind.unavailable);
    }
  }

  @override
  Future<PosterExportResult> export(
    String owner,
    PosterDocument document,
    PosterExportAction action,
  ) async {
    try {
      if (!configured) {
        throw const PosterFailure(PosterFailureKind.notConfigured);
      }
      final latest = await _source.prepare(owner, document.content.target);
      if (latest.revision != document.content.revision ||
          _url(latest.slug) != document.content.publicUrl) {
        throw const PosterFailure(PosterFailureKind.stale);
      }
      _source.checkOwner(owner);
      return await _exports.export(document, action);
    } on PosterFailure {
      rethrow;
    } catch (_) {
      throw const PosterFailure(PosterFailureKind.unavailable);
    }
  }
}
