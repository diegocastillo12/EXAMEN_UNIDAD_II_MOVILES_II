import '../entities/case_poster.dart';
import '../entities/case_share.dart';
import '../repositories/case_share_repository.dart';

class SharePublicCase {
  const SharePublicCase(this._repository);
  final CaseShareRepository _repository;
  Future<CaseShareResult> call(
    String actor,
    PosterCase target,
    CaseShareChannel channel,
  ) {
    if (actor.isEmpty ||
        !RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        ).hasMatch(target.id)) {
      throw const PosterFailure(PosterFailureKind.forbidden);
    }
    return _repository.execute(actor, target, channel);
  }
}
