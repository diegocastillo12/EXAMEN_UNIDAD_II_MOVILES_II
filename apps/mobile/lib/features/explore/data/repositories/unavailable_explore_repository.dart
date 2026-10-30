import '../../domain/entities/explore_query.dart';
import '../../domain/entities/explore_page.dart';
import '../../domain/failures/explore_failure.dart';
import '../../domain/repositories/explore_repository.dart';

class UnavailableExploreRepository implements ExploreRepository {
  const UnavailableExploreRepository();
  @override
  Future<ExplorePage> search(
    String owner,
    ExploreQuery query, {
    String? cursor,
  }) async => throw const ExploreFailure(ExploreFailureKind.unavailable);
}
