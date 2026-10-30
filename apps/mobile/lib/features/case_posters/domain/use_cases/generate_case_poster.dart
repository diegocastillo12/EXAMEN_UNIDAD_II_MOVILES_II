import '../entities/case_poster.dart';
import '../repositories/case_poster_repository.dart';

final class GenerateCasePoster {
  const GenerateCasePoster(this._repository);
  final CasePosterRepository _repository;
  Future<PosterDocument> call(String owner, PosterCase target) {
    if (owner.isEmpty ||
        !RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        ).hasMatch(target.id)) {
      throw const PosterFailure(PosterFailureKind.forbidden);
    }
    if (!_repository.configured) {
      throw const PosterFailure(PosterFailureKind.notConfigured);
    }
    return _repository.generate(owner, target);
  }
}
