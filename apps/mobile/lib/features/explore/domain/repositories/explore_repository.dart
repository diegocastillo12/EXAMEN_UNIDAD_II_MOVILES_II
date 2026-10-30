import '../entities/explore_query.dart';
import '../entities/explore_page.dart';

abstract interface class ExploreRepository {
  /// Cursor belongs to this exact query. A refresh starts a new pagination window.
  Future<ExplorePage> search(
    String owner,
    ExploreQuery query, {
    String? cursor,
  });
}
