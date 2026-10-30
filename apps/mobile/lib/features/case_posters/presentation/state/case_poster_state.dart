import '../../domain/entities/case_poster.dart';

class CasePosterState {
  const CasePosterState({
    required this.owner,
    required this.configured,
    this.document,
    this.generating = false,
    this.exporting,
    this.notice,
    this.noticeId = 0,
    this.isError = false,
  });
  final String owner;
  final bool configured, generating, isError;
  final PosterDocument? document;
  final PosterExportAction? exporting;
  final String? notice;
  final int noticeId;
  bool get busy => generating || exporting != null;
}
