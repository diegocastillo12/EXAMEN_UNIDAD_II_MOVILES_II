import '../../domain/entities/case_poster.dart';
import '../../domain/repositories/case_poster_repository.dart';

class UnavailableCasePosterRepository implements CasePosterRepository {
  const UnavailableCasePosterRepository();
  @override
  bool get configured => false;
  @override
  Future<PosterDocument> generate(String owner, PosterCase target) async =>
      throw const PosterFailure(PosterFailureKind.notConfigured);
  @override
  Future<PosterExportResult> export(
    String owner,
    PosterDocument document,
    PosterExportAction action,
  ) async => throw const PosterFailure(PosterFailureKind.notConfigured);
}
