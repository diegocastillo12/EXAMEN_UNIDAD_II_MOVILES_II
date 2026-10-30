import '../entities/case_poster.dart';
import '../repositories/case_poster_repository.dart';

final class ExportCasePoster {
  const ExportCasePoster(this._repository);
  final CasePosterRepository _repository;
  Future<PosterExportResult> call(
    String owner,
    PosterDocument document,
    PosterExportAction action,
  ) {
    if (owner.isEmpty) throw const PosterFailure(PosterFailureKind.forbidden);
    if (!_repository.configured) {
      throw const PosterFailure(PosterFailureKind.notConfigured);
    }
    return _repository.export(owner, document, action);
  }
}
