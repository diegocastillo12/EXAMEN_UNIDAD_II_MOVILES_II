import '../entities/case_poster.dart';

abstract interface class CasePosterRepository {
  bool get configured;
  Future<PosterDocument> generate(String owner, PosterCase target);

  /// Rechecks ownership, active status, link and public revision before handoff.
  Future<PosterExportResult> export(
    String owner,
    PosterDocument document,
    PosterExportAction action,
  );
}
