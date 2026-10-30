import '../../domain/entities/case_poster.dart';
import '../../domain/entities/case_share.dart';
import '../../domain/repositories/case_share_repository.dart';
import '../data_sources/case_share_source.dart';
import '../data_sources/poster_document_source.dart';
import '../models/poster_payload.dart';

class CaseShareRepositoryImpl implements CaseShareRepository {
  const CaseShareRepositoryImpl(
    this._source,
    this._documents,
    this._actions, {
    required this.webBaseUrl,
    required this.publicWebReady,
  });
  final CaseShareSource _source;
  final PosterDocumentSource _documents;
  final CaseShareActionSource _actions;
  final String webBaseUrl;
  final bool publicWebReady;

  Uri _base() {
    final base = Uri.tryParse(webBaseUrl);
    if (!publicWebReady ||
        base == null ||
        base.scheme != 'https' ||
        base.host.isEmpty ||
        base.userInfo.isNotEmpty ||
        base.hasQuery ||
        base.hasFragment ||
        base.toString().length > 180) {
      throw const PosterFailure(PosterFailureKind.notConfigured);
    }
    return base;
  }

  Uri _url(PosterPayload payload, PosterCase target, Uri base) {
    if (payload.row['id'] != target.id ||
        payload.row['source'] != target.source.name ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(payload.slug)) {
      throw const PosterFailure(PosterFailureKind.forbidden);
    }
    return base.replace(
      path: '${base.path.replaceFirst(RegExp(r'/+$'), '')}/c/${payload.slug}',
    );
  }

  @override
  Future<CaseShareResult> execute(
    String actor,
    PosterCase target,
    CaseShareChannel channel,
  ) async {
    try {
      final base = _base();
      final payload = await _source.prepare(actor, target);
      final url = _url(payload, target, base);
      PosterDocument? document;
      if (channel == CaseShareChannel.download) {
        final photo = await _source.photo(actor, target, payload.photoPath);
        final content = payload.toContent(target, url, photo);
        document = PosterDocument(
          content: content,
          bytes: await _documents.render(content),
        );
      }
      final latest = await _source.prepare(actor, target);
      if (latest.revision != payload.revision ||
          _url(latest, target, base) != url) {
        throw const PosterFailure(PosterFailureKind.stale);
      }
      _source.checkSession(actor);
      return await _actions.handoff(channel, url, document);
    } on PosterFailure {
      rethrow;
    } catch (_) {
      throw const PosterFailure(PosterFailureKind.unavailable);
    }
  }
}

class UnavailableCaseShareRepository implements CaseShareRepository {
  const UnavailableCaseShareRepository();
  @override
  Future<CaseShareResult> execute(
    String actor,
    PosterCase target,
    CaseShareChannel channel,
  ) async => throw const PosterFailure(PosterFailureKind.notConfigured);
}
