import '../entities/case_poster.dart';
import '../entities/case_share.dart';

abstract interface class CaseShareRepository {
  Future<CaseShareResult> execute(
    String actor,
    PosterCase target,
    CaseShareChannel channel,
  );
}
