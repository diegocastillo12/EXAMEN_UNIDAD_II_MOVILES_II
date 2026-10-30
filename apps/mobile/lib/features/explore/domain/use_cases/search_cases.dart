import '../entities/explore_query.dart';
import '../entities/explore_page.dart';
import '../failures/explore_failure.dart';
import '../repositories/explore_repository.dart';

class SearchCases {
  const SearchCases(this._repository);
  final ExploreRepository _repository;
  Future<ExplorePage> call(String owner, ExploreQuery query, {String? cursor}) {
    if (owner.trim().isEmpty) {
      throw const ExploreFailure(ExploreFailureKind.forbidden);
    }
    if (!query.valid ||
        query.latitude == null ||
        query.longitude == null ||
        query.radiusMeters == null) {
      throw const ExploreFailure(ExploreFailureKind.invalid);
    }
    return _repository.search(owner, query, cursor: cursor);
  }
}
